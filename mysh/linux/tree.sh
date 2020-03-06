#!/bin/bash

# Author='Byng.Zeng'
VERSION=1.0.2

NAME=$(basename $BASH_SOURCE)

VERBOSE=0

MAX_DEPTH=''  # -maxdepth, default is none
TABS='    '  # tabs 4 spaces

function print_usage()
{
    echo "===================================="
    echo "    ${NAME%.*} - $VERSION"
    echo "===================================="
    echo "print path tree"
    echo ""
    echo "usage: bash ${NAME} option"
    echo ""
    echo "option: "
    echo "[ -s src   | --src=src     ]: path of source"
    echo "[ -L level | --level=level ]: print deepth of tree"
}


function tree_tabs()
{
    local ftemp=$1
    local fname=${ftemp##*/}
    local tabs=''

    while [ $ftemp != $fname ]; do
        tabs="${tabs[@]}""${TABS[@]}"
        ftemp=${ftemp#*/}
    done
    echo "${tabs[@]}"
    return 0
}

function tree_tabs2()
{
    local tabs=''
    local n=$(($(echo $1 | awk -F '/' '{print NF}') - 1))

    while [ $n -gt 0 ]; do
        tabs="${tabs[@]}""${TABS[@]}"
        n=$(($n - 1))
    done
    echo "${tabs[@]}"
    return 0
}

function print_tree()
{
    local fs=''
    local rootpath=$1
    local tabs=''
    local d_count=0
    local f_count=0

    if [ $VERBOSE == 0 ]; then  # no hidden files
        fs=$(find ${rootpath} $MAX_DEPTH -not -path '*/\.*' | sed 's/\.\///g' | sed 's/\ /_/g' | sed "s@${rootpath}\(\/\)\?@@g")
    else  # all of files
        fs=$(find ${rootpath} $MAX_DEPTH | sed 's/\.\///g' | sed 's/\ /_/'g | sed "s@${rootpath}\(\/\)\?@@g")
    fi

	echo '.'
    for f in $fs; do
        if [ -d $f ]; then  # directories
            d_count=$((d_count + 1))
        else  # file.
            f_count=$((f_count + 1))
        fi
        # print file.
        local tabs=$(tree_tabs $f)
        echo "$tabs|-- $(basename $f)"
    done
    # print total number.
    echo ''
    echo "$d_count directories, $f_count files"
}


ARGS=`getopt -o s:L:vh --long src=,levlel=,verbpse,help -n "$NAME" -- "$@"`
if [ $? != 0 ]; then
    echo "-h for help!!!"
    exit -1
fi
eval set -- "${ARGS}"


src=$(pwd)  # default to pwd.

while [ $# -gt 0 ]
do
    case $1 in
    -s | --src )
        src=$2
        shift 2
    ;;
    -v | --verbose )
        VERBOSE=1
        shift 1
    ;;
    -L | --level )
        MAX_DEPTH="-maxdepth  $2"
        shift 2
    ;;
    --)
        shift 1
    ;;
    -h | --help)
        print_usage
        exit -1
    ;;
    *)
        #echo "unknown $1, -h for help"
        #exit -1
        src=$1
        shift
    ;;
    esac
done

print_tree $src
