param($noload = $false)
$languages = echo js cs hs c cpp m java py sh rb bat go ts R vb fs hs ps1 jl ocaml

if (!$noload) {
  write-host "loading"
  $csv = Import-Csv C:\tmp\github-popularity.csv
}

write-host "processing"
$csv | % {
  $_.file = $_.file -replace '^.*\.','' ; $_
} | group file | % {
  $ext = $_.name;
  if ($ext -in $languages) {
    $authors = $_.group | group author;
    awf-new @{ext=$ext;n_authors=$authors.count;authors=$authors.name}
  }
} | sort n_authors
