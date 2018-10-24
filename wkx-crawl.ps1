param($csv = ".\wkx.csv", $search_date = "2018-10-23")

write-host "wkx-crawl: Writing results for $search_date to CSV $csv"
$obj = ./awf-new @{author = "na"; date = "na"; file = "na" }
$obj | export-csv $csv

$start = get-date
$totalreq = 0

$sleep_per_query = 0.3 # roughly 3600/5000 * 0.5
$target_time_per_req = 1.05 * 3600 / 5000 # req/hr, aim for slightly above

$batch_mins = 10   # Search in 10-minute windows
$batch_period = 30 # every 30 mins
$starttimes = (0*60/$batch_period) .. (24*60/$batch_period)
$starttimes | % {
  $t0 = $_ * $batch_period
  $t1 = $t0 + $batch_mins
  $t0str = "{0:D2}:{1:D2}:00" -f [int][math]::floor($t0 / 60),($t0 % 60)
  $t1str = "{0:D2}:{1:D2}:00" -f [int][math]::floor($t1 / 60),($t1 % 60)
  $searchstr = "author-date:${search_date}T${t0str}..${search_date}T${t1str} merge:false"
  $search = ./github-search-commits $searchstr -fields @{page=1;per_page=10}
  $n_total = $search.total_count
  $n = [math]::min($n_total, 1000) # search api throttles at 1000

  $per_page = 100
  $n_pages = [math]::floor(($n-1) / $per_page) + 1

  write-host "Search $t0 $t1 $searchstr, returns n=$n_total entries, throttle to $n, $n_pages pages"

  1..$n_pages | % {
    while($true) {
      $search = ./github-search-commits $searchstr -fields @{sort='author-date';page=$_;per_page=$per_page}
      $n = $search.items.count
      # break
      if ($n -eq $per_page -or ($_ -eq $n_pages)) {
        #TODO Check last page too
        break
      }
      write-error "search results $n < $per_page, -- wait and retry"
      Start-Sleep 10
    }
  
    $afiles = $search.items | % {
      $commit = ./github-api-get $_.url
      ++$totalreq
      $files = $commit.files.filename
      $author = $commit.commit.author.email
      $date = $commit.commit.author.date
      $files | % { ./awf-new @{author=$author;date=$date;file=$_} }
      Start-Sleep $sleep_per_query
    }
  
    $elapsed = ((get-date) - $start).TotalSeconds
    $target_time = $target_time_per_req * $totalreq
    $sleeptime= $target_time - $elapsed
  
    write-host "page $_, n = $($search.total_count), incomp $($search.incomplete_results), totalreq $totalreq, elapsed $elapsed, target $target_time, sleep for $sleeptime"
  
    $names = $afiles.author | Group-Object | selex name
    # write-host "names $names"
    write-host "appending $($names.count) names to CSV $csv"
    $afiles | export-csv $csv -append
  
    if ($sleeptime -gt 0) { Start-Sleep $sleeptime }
  }
}

write-host "wkx-crawl: Now try wkx-make-table"
