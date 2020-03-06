#!/bin/bash

# Author='Byng.Zeng'
VERSION=1.0.0

NAME=$(basename $BASH_SOURCE)

VERBOSE=0

function print_usage()
{
    echo "===================================="
    echo "    ${NAME%.*} - $VERSION"
    echo "===================================="
    echo "make tar file."
    echo ""
    echo "usage: bash ${NAME} option"
    echo ""
    echo "option: "
    echo "[ -s src ]: path of source"
    echo "[ -o oou ]: path of output"
    echo "[ -f fmt ]: format of dist, bz2 or gz"
}


function do_tar()
{
    local src=($1)
    local dst=$2
    local fmt=$3
    local show=

    IFS=','
    src="${src[@]}"

    for dr in $src
    do
        echo "-----------$dr-------------"
        cd $dr  # enter dir
        # run tar cmd.
        if [[ $fmt == 'bz2' || $fmt == 'br2' ]]; then
            tar -cjf $(basename $dr).tar.$fmt .
        elif [ $fmt == 'gz' ]; then
            tar -czf $(basename $dr).tar.$fmt .
        else
            echo "Error, no support $fmt"
            exit -1
        fi
       
        mv $(basename $dr).tar.$fmt $dst/$(basename $dr).tar.$fmt
        echo "output: $dst/$(basename $dr).tar.$fmt"
        echo ""
    done
}

ARGS=`getopt -o s:o:f:vh --long src=,out==,fmt=,verbpse,help -n "$NAME" -- "$@"`
if [ $? != 0 ]; then
    echo "-h for help!!!"
    exit -1
fi
eval set -- "${ARGS}"



src=$(pwd)
out=$(pwd)
fmt='bz2'
# loop for args
while [ $# -gt 0 ]
do
    case $1 in
    -s | --src )
        src=$2
        shift 2
    ;;
    -o | --out )
        out=$2
        shift 2
    ;;
    -f | --fmt )
        fmt=$2
        shift 2
    ;;
    -v | --verbose )
        VERBOSE=1
        shift 1
    ;;
    --)
        shift 1
    ;;
    -h | --help)
        print_usage
        exit -1
    ;;
    *)
        echo "unknown $1, -h for help"
        exit -1
    ;;
    esac
done

do_tar $src $out $fmt
