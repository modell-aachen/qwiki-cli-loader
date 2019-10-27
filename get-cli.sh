#!/bin/bash

get-cli() {
    IS_VERBOSE=false
    VERBOSE=""

    usage() {
        printf -v text "%s" \
            "get-cli downloads qwiki-cli to the current directory [OPTION...]\n" \
            "    -v, --verbose        shows more info\n" \
            "    -d, --debug          debug API calls by passing verbose flag to curl\n" \
            "    -u, --update         update cli binary in /usr/bin/\n" \
            "    -h, --help           shows this help message\n" \
            "    -r, --release-tag    cli release tag, e.g. 0.1.12, default: latest\n" \
            "    -t, --token          GitHub Token\n"
        printf "$text"
    }

    OPTS=`getopt -o vduhr:t: --long verbose,debug,help,update,release-tag:,token: -- "$@"`
    if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -v | --verbose )
                IS_VERBOSE=true
                shift ;;
            -d | --debug )
                VERBOSE_FLAG="v"
                shift ;;
            -u | --update )
                UPDATE_USR_BIN=true
                shift ;;
            -t | --token )
                TOKEN=$2
                shift 2 ;;
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

    if [ -z "$TOKEN" ]; then
        printf "GitHub token is required, please insert\n"
        read TOKEN
        if [ -z "$TOKEN" ]; then
            exit 1
        fi
    fi

    if [ -z "$RELEASE" ]; then
        RELEASE="latest"
    else
        RELEASE="tags/${RELEASE}"
    fi

    export TOKEN
    export RELEASETAG
    export VERBOSE_FLAG

    ASSETID=$(curl -L${VERBOSE_FLAG}J -H 'Accept: application/json' "https://api.github.com/repos/modell-aachen/qwiki-cli/releases/$RELEASE?access_token=$TOKEN" | grep -Pzo "\"assets\":[\s\S]*?\"id\": \K\d*")
    export ASSETID

    $IS_VERBOSE && printf "\nASSETID: $ASSETID for RELEASE: $RELEASE\n\n"

    curl -L${VERBOSE_FLAG}JO -H 'Accept: application/octet-stream' "https://api.github.com/repos/modell-aachen/qwiki-cli/releases/assets/$ASSETID?access_token=$TOKEN"

    unset TOKEN

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
