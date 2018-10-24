param($csv = "wkx.csv", $load = $true)

$languages = (cat .\languages.json |ConvertFrom-Json).languages
$languages|%{ 
    $ext2lang = @{} 
  } { 
    $name = $_.name; 
    $exts = $_.extensions
    $exts |% { 
      if ($_){
        $ext2lang[$_] += $name +"/"
      }
    }
    if (!$exts) {
      write-warning "No exts for [$_]"
    }
  }

$keys = @() + $ext2lang.keys
foreach ($ext in $keys) {
  $ext2lang[$ext] = $ext2lang[$ext] -replace '/$'," [$ext]"
}

if ($load) {
  write-host "wkx-make-table: loading $csv"
  $data = Import-Csv $csv
}

write-host "wkx-make-table: processing"
# overwrite "file" field in place to language
$data | % {
  $ext = $_.file -replace '^.*\.','.'
  $lang = $ext2lang[$ext]
  if (!$lang) { 
    #write-warning "wkx-make-table: Unknown extension [$ext]"
    #$lang = $ext
    #$ext2lang[$ext] = $ext -replace '^.',''
  }
  $_.file = $lang
}

$data | group file | % {
  $lang = $_.name;
  if (!$lang) { 
    #write-warning "wkx-make-table: Empty lang! [$_]"
  } else {
    $authors = $_.group | group author;
    ./awf-new @{lang=$lang;n_authors=$authors.count;authors=$authors.name}
  }
} | sort n_authors
