#!/bin/bash


function bashrc_bak() {
    ver=$(date "+%Y%m%d-%M%S")
    cp -f $1 $2/$(basename $1)-$ver
    echo "$1 -> $2/$(basename $1)-$ver"
}

function bashrc() {
    if [ $1 == 'bak' ]; then
        shift
        bashrc_bak $@
    fi
}

bashrc $@
