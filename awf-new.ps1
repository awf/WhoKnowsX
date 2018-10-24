param($hash)
# make an object with those keys
$o = new-object PSObject | select-object ([string[]]$hash.keys)
# fill values from hashtable
foreach ($k in $hash.keys) {
    $o.$k = $hash[$k]
}
$o
