param($path, $fields=@{}, $headers=@{})
# e.g. github-api-get rate_limit

if ($path -notmatch '^https://') {
  $path = "https://api.github.com/$path"
}

$base = @{
  access_token=cat user-access-token.txt
  'user-agent'="awf"
}
$body = $base + $fields

if ($args) {
  write-host "ARGS[$args]"
}

Invoke-WebRequest $path -body $body -headers $headers @args | ConvertFrom-Json
