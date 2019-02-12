#function days-since-epoch
param($t) 
 ([datetime]$t).Subtract([datetime]"01/01/2017").TotalDays
