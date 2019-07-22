param($ext = "jl")

$matching_lines = sls ('\.' + $ext + '"') .\data\wkx-* |`
    select -expand line | ConvertFrom-Csv -header (echo time who file)
$nlines = $matching_lines.length
write-host "Found $nlines records"
$n = 0
$ntot = 0
$n_second_visit = 0
$day = 0
$new_joiner_events = $matching_lines |` 
    foreach {
        $hash = @{}
        $perday = @{}
        $second_visit = @{}
      } {  
        ++$n
        $who = $_.who
        $day = ./days-since-epoch $_.time
        $day = [int]$day
        if (!$hash[$who]) {
            ++$ntot
            $hash[$who] = $day
            $perday[$day] = $ntot
        } else {
            $lastday = $hash[$who]
            if ($lastday -ne -1) {
                if ($day - $lastday -gt 1) {
                    # Second visit, on a different day
                    $n_second_visit++
                    $second_visit[$day] = $n_second_visit
                    $hash[$who] = -1
                }
            }
        }
        write-progress "Scanning $ext, total $ntot, day $day" -percent ($n/$nlines*100)
      }

$days = $perday.Keys | sort
$perday_by_day = $days | % { $perday[$_] }

$days2 = $second_visit.Keys | sort
$second_visit_by_day = $days2 | % { $second_visit[$_] }

. ./draw-graph-chart
