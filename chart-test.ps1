
$xs = 1..314
$ys = $xs | % { [math]::sin($_ / 25) }
$ys2 = $xs | % { [math]::sin($_ / 27     ) }
. ./chart -title "Sine Waves" $xs $ys -xs2 $xs -ys2 $ys2
