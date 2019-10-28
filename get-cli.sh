#!/bin/bash

get-cli() {
    IS_VERBOSE=false
    VERBOSE_FLAG=""

    usage() {
        printf -v text "%s" \
            "get-cli downloads qwiki-cli to the current directory; ask for GitHub token if GITHUB_TOKEN is not set as environmental variable [OPTION...]\n" \
            "    -v, --verbose        shows more info\n" \
            "    -d, --debug          debug API calls by passing verbose flag to curl\n" \
            "    -u, --update         update cli binary in /usr/bin/\n" \
            "    -h, --help           shows this help message\n" \
            "    -r, --release-tag    cli release tag, e.g. 0.1.12, default: latest\n"
        printf "$text"
    }

    OPTS=`getopt -o vduhr: --long verbose,debug,help,update,release-tag: -- "$@"`
    if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -v | --verbose )
                IS_VERBOSE=true
                shift ;;
            -d | --debug )
                DEBUG=true
                shift ;;
            -u | --update )
                UPDATE_USR_BIN=true
                shift ;;
            -r | --release-tag )
                RELEASE=$2
                shift 2 ;;
            -h | --help )
                usage
                return
                shift ;;
            -- )
                shift
                break ;;
            * )
                break ;;
        esac
    done

    if [ -z "$GITHUB_TOKEN" ]; then
        printf "GitHub token is required, please insert\n"
        read TOKEN
        if [ -z "$TOKEN" ]; then
            exit 1
        fi
    else
        TOKEN="$GITHUB_TOKEN"
    fi

    if [ -z "$RELEASE" ]; then
        RELEASE="latest"
    else
        RELEASE="tags/${RELEASE}"
    fi

    ASSETID=$(curl -L${VERBOSE_FLAG}J -H 'Accept: application/json' "https://api.github.com/repos/modell-aachen/qwiki-cli/releases/$RELEASE?access_token=$TOKEN" | grep -Pzo "\"assets\":[\s\S]*?\"id\": \K\d*" | tr -d '\0')
    curl -L${VERBOSE_FLAG}JO -H 'Accept: application/octet-stream' "https://api.github.com/repos/modell-aachen/qwiki-cli/releases/assets/$ASSETID?access_token=$TOKEN"
    unset TOKEN

    $IS_VERBOSE && printf "\nASSETID: $ASSETID for RELEASE: $RELEASE\n\n"

    if [ ! -z "$UPDATE_USR_BIN" ]; then
        $IS_VERBOSE && printf "replacing /usr/bin/qwiki\n"
        mv ./qwiki /usr/bin/qwiki
        chmod +x /usr/bin/qwiki
    else
        $IS_VERBOSE && printf "Update flag not set, not replacing /usr/bin/qwiki\n"
    fi

    printf "\ndone\n"

}

get-cli $@
