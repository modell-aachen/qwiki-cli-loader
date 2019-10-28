# qwiki-cli-loader
Shell script for downloading qwiki-cli using github api

## help ./get-cli.sh --help
```Bash
get-cli downloads qwiki-cli to the current directory; ask for GitHub token if GITHUB_TOKEN is not set as environmental variable [OPTION...]
    -v, --verbose        shows more info
    -d, --debug          debug API calls by passing verbose flag to curl
    -u, --update         update cli binary in /usr/bin/
    -h, --help           shows this help message
    -r, --release-tag    cli release tag, e.g. 0.1.12, default: latest
 ```
 
## Examples

```BASH
# get latest CLI, update /usr/bin/qwiki, get asked for token
./get-cli.sh -u

# get release 0.1.12, update /usr/bin/qwiki
./get-cli.sh -u -r 0.1.12 -t SOME-GITHUB-TOKEN
```
