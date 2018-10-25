param($csvs = @("wkx.csv"), 
      $corr = 1.0,   # Overcount correction for subsamples
      $load = $true)

$languages = (cat .\languages.json |ConvertFrom-Json).languages
$languages| ?{$_.type -eq 'programming' } | %{ 
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
  $ext2lang[$ext] = $ext2lang[$ext] -replace '/$',""
}

$lang2ext = @{}
foreach ($ext in $keys) {
  $lang = $ext2lang[$ext]
  if ($lang2ext[$lang]) {
    $lang2ext[$lang] += ",$ext"
  } else {
    $lang2ext[$lang] = $ext
  }
}

if ($load) {
  $data = foreach ($csv in $csvs){ 
    write-host "wkx-make-table: loading $csv"
    Import-Csv $csv
  }
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

$bylang = $data | group file 
$table = $bylang | % {
  $lang = $_.name;
  if (!$lang) { 
    #write-warning "wkx-make-table: Empty lang! [$_]"
  } else {
    $authors = $_.group | group author
    $n_authors = $authors.Length * $corr
    ./awf-new @{lang=$lang;exts=$lang2ext[$lang];n_authors=$n_authors;authors=$authors.name}
  }
} | sort n_authors
$table[-100..-1]  | ft n_authors,lang,exts,authors | out-string | write-host
