$dates = 1..270 | %{.\epoch-plus-days.ps1 "2017-01-01" ($_ * 3)}

$dates |%{./wkx-crawl -search_date $_ }
