#!/bin/bash

# Author='Byng.Zeng'
VERSION=1.0.2

NAME=$(basename $BASH_SOURCE)

function print_usage()
{
    echo "===================================="
    echo "    ${NAME%.*} - $VERSION"
    echo "===================================="
    echo "usage: option"
    echo ""
    echo "option: "
    echo "  -c path | --check=path : check git status of path"
}

function argv_parse()
{
    OLD_IFS="$IFS"
    IFS=$2
    local array=($1)
    IFS="$OLD_IFS"
    echo "${array[@]}"
    return ${#array[@]}
}

function check()
{
    gits=$(argv_parse $1 ',')
    for git in $gits
    do
        echo "-----------$git-------------"
        cd $git
        git status
        echo ""
    done
}


ARGS=`getopt -o c:h --long check=,help -n "$NAME" -- "$@"`
if [ $? != 0 ]; then
    echo "-h for help!!!"
    exit 1
fi
eval set -- "${ARGS}"


if [ $# == 1 ]; then
    print_usage
else
    while [ $# -gt 0 ]
    do
        case $1 in
        -c | --check )
            check $2
            shift 2
        ;;
        --)
            shift
        ;;
        -h | --help)
            print_usage
            exit
        ;;
        *)
            echo "unknown $1, -h for help"
            exit 1
        ;;
        esac
    done
fi
