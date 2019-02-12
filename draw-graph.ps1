param($ext = "jl")

$matching_lines = sls ('\.' + $ext + '"') .\data\wkx-* |`
    select -expand line | ConvertFrom-Csv -header (echo time who file)
$nlines = $matching_lines.length
write-host "Found $nlines records"
$n = 0
$ntot = 0
$day = 0
$new_joiner_events = $matching_lines |` 
    foreach {
        $hash = @{}
        $perday = @{}
      } {  
        ++$n
        $who = $_.who
        if (!$hash[$who]) {
            $hash[$who] = 1
            ++$ntot
            $day = ./days-since-epoch $_.time
            $day = [int]$day
            $perday[$day] = $ntot
        } else {
            ++$hash[$who]
        }
        write-progress "Scanning $ext, total $ntot, day $day" -percent ($n/$nlines*100)
      }

$days = $perday.Keys | sort
$ys = $days | % { $perday[$_] }
start-job { cd $using:pwd ; .\chart.ps1 $using:days $using:ys -title $using:ext }
