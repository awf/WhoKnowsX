param($q = "hash:019d0e7872c67fdc6996488e2aa6b64a03c87b9b", $fields=@{})

github-abi-get search/commits (@{q=$q}+$fields) -headers @{Accept="application/vnd.github.cloak-preview"}
