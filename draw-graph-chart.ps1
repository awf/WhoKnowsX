start-job { 
    cd $using:pwd
    .\chart.ps1 $using:days $using:perday_by_day -xs2 $using:days2 -ys2 $using:second_visit_by_day `
                -title "WhoKnowsX .$using:ext" 
}

start-job { 
    cd $using:pwd
    . .\vmath
    .\chart.ps1 (index $using:days 0 -2) (nsmooth 3 (vdiff $using:perday_by_day)) `
                -title "WhoKnowsX Delta .$using:ext" 
}
