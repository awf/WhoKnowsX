function vdiff([float[]]$v) 
{ 
    [float[]](0..($v.Length-2) | % { $v[$_+1]-$v[$_]}) 
}

function smooth([float[]]$v) 
{ 
    $e = $v.Length - 1
    $o = 1..($e-1) | % {
        (2.0*$v[0] + $v[1])/3
    } { 
        ($v[$_-1] + 2*$v[$_] + $v[$_+1])/4
    } {
        ($v[$e-1] + 2.0 * $v[$e])/3
    }
    [float[]]$o
}

function nsmooth([int]$n, [float[]]$v) 
{ 
    if ($n -eq 0) {
        $v
    } else {
        smooth (nsmooth ($n-1) $v)
    }
}

function index([float[]]$v, [int]$s, [int]$e) 
{ 
    if ($s -ge 0 -and $e -lt 0) { 
        [float[]]($v[$s..($v.Length+$e)]) 
    } else { 
        throw "ni" 
    } 
}
