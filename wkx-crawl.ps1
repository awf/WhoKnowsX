param($csv = $null, $search_date = "2018-10-23")

if (!$csv) {
  $csv = "data/$search_date.csv"
}

write-host "wkx-crawl: Writing results for $search_date to CSV $csv"
$obj = ./awf-new @{author = "na"; date = "na"; file = "na" }
$obj | export-csv $csv

$start = get-date
$totalreq = 0
$total_commits_according_to_search = 0

$sleep_per_query = 0.3 # roughly 3600/5000 * 0.5
$target_time_per_req = 1.05 * 3600 / 5000 # req/hr, aim for slightly above

$batch_mins = 5   # Search in 5-minute windows
$batch_period = 70 # every 70 mins
$max_commits_per_batch = 500 # search api throttles at 1000, we may want less
$starttimes = (0*60/$batch_period) .. (24*60/$batch_period)
$starttimes | % {
  $t0 = $_ * $batch_period
  $t1 = $t0 + $batch_mins
  $t0str = "{0:D2}:{1:D2}:00" -f [int][math]::floor($t0 / 60),($t0 % 60)
  $t1str = "{0:D2}:{1:D2}:00" -f [int][math]::floor($t1 / 60),($t1 % 60)
  $searchstr = "author-date:${search_date}T${t0str}..${search_date}T${t1str} merge:false"
  $search = ./github-search-commits $searchstr -fields @{page=1;per_page=10}
  $n_total = $search.total_count
  $total_commits_according_to_search += $n_total

  $n_commits = [math]::min($n_total, $max_commits_per_batch) 

  $per_page = 100
  $n_pages = [math]::floor(($n_commits-1) / $per_page) + 1

  write-host "wkx-crawl: ****"
  write-host "wkx-crawl: Search $t0 $t1 $searchstr, returns n=$n_total entries, throttle to $n_commits, $n_pages pages"

  foreach ($page in 1..$n_pages) {
    while($true) {
      write-host -nonewline "wkx-crawl: page $page, "
      $search = ./github-search-commits $searchstr -fields @{sort='author-date';page=$page;per_page=$per_page}
      $n = $search.items.count
      # break
      if (!$search.incomplete_results -and $n -gt 0.98*$per_page -or ($page -eq $n_pages)) {
        #TODO Check last page too
        break
      }
      write-error "search results $n < $per_page, page $page, incomplete=$($search.incomplete_results) -- wait and retry"
      Start-Sleep 10
    }
    write-host "n = $($search.total_count), incomplete $($search.incomplete_results)"

    write-host -nonewline "wkx-crawl: commits:"
    $afiles = $search.items | % {
      $progressPreference = 'silentlyContinue'
      $commit = ./github-api-get $_.url
      $progressPreference = 'Continue'
      ++$totalreq
      $files = $commit.files.filename
      $author = $commit.commit.author.email
      $date = $commit.commit.author.date
      $modified = 0
      foreach ($file in $commit.files) {
        if ($file.status -eq 'modified') {
         ++$modified
         ./awf-new @{author=$author;date=$date;file=$file.filename}
        }
      }
      $msg = " $modified"
      if ($modified -lt $files.count) {
        $msg += "/" + $files.count
      }
      write-host  -nonewline $msg 
      Start-Sleep $sleep_per_query
    }
    write-host " done"
  
    $elapsed = ((get-date) - $start).TotalSeconds
    $target_time = $target_time_per_req * $totalreq
    $sleeptime= ($target_time - $elapsed) * 1.1
  
    write-host "wkx-crawl: totalreq $totalreq/$total_commits_according_to_search, elapsed $elapsed, target $target_time, sleep for $sleeptime"
  
    $names = $afiles.author | Group-Object | select -expand name
    # write-host "names $names"
    write-host "wkx-crawl: appending $($names.count) unique authors to CSV $csv"
    $afiles | export-csv $csv -append
    $estimated_undercount = $totalreq/$total_commits_according_to_search*$batch_mins/($starttimes.count * $batch_period)
    write-host "wkx-crawl: Undercount estimate $totalreq/$total_commits_according_to_search*$batch_mins/($starttimes.count * $batch_period) = $estimated_undercount"

    if ($sleeptime -gt 0) { Start-Sleep $sleeptime }
  }
}

$estimated_undercount = $totalreq/$total_commits_according_to_search*$batch_mins/($starttimes.count * $batch_period)
write-host "wkx-crawl: Undercount estimate $totalreq/$total_commits_according_to_search*$batch_mins/($starttimes.count * $batch_period) = $estimated_undercount"

write-host "wkx-crawl: Now try wkx-make-table"
