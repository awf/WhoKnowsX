# WhoKnowsX
How many programmers know programming language X?

## Running
Get yourself a github api access token from here: https://github.com/settings/tokens

And paste it into a file called user-access-token.txt in this directory

Run the crawl from this directory:

$dates = 1..270 | %{.\epoch-plus-days.ps1 "2017-01-01" ($_ * 3)}

$dates |%{./wkx-crawl -search_date $_ }
