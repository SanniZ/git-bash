#!/bin/bash

# Author='Byng.Zeng'
VERSION=1.0.0

NAME=$(basename $BASH_SOURCE)

# Notes:
#   _ADB_PATH is global var.
#   set _ADB_PATH if you needs at local only, otherwise set to other place.


function print_usage()
{
    echo "===================================="
    echo "    ${NAME%.*} - $VERSION"
    echo "===================================="
    echo "adb command set"
    echo ""
    echo "usage: bash ${NAME} option"
    echo ""
    echo "option: "
    echo "[ pwd          ] : print PWD of android"
    echo "[ ls xxx       ] : run adb shell ls  PWD/xxx"
    echo "[ ll xxx       ] : run adb shell ls  -l PWD/xxx"
    echo "[ cd xxx       ] : run adb shell cd PWD/xxx"
    echo "[ rm xxx       ] : run adb shell rm PWD/xxx"
    echo "[ mv xxx1 xxx2 ] : run adb shell mv PWD/xxx1 PWD/xxx2"
    echo "[ pull xxx     ] : run adb pull PWD/xxx"
    echo "[ push xxx     ] : run adb push . PWD/xxx"
    echo "[ mkdir xxx    ] : run adb shell mkdir PWD/xxx"
}

function adb_pwd() {
    echo "/$_ADB_PATH"
}

function adb_ls() {
    if [ -z $_ADB_PATH ]; then
        adb shell ls
    else
        adb shell ls $_ADB_PATH/$@
    fi
}

function adb_ll() {
    if [ -z $_ADB_PATH ]; then
        adb shell ls -l
    else
        adb shell ls -l $_ADB_PATH/$@
    fi
}

function adb_pull() {
    adb pull $_ADB_PATH/$@ .
}

function adb_push() {
    if [ $1 == '-a' ]; then
        shift
        fs=$(find $1 | sed 's/\.\///' | sed 's/\ /_/')
    else
        fs=$(find $1 -not -path '*/\.*' | sed 's/\.\///' | sed 's/\ /_/')
    fi
    for f in $fs; do
        if [ $f == '.' ]; then  # root
            continue
        fi
        adb shell mkdir -p $_ADB_PATH/$(dirname $f)
        adb push $f $_ADB_PATH/$(dirname $f)/$(basename $f)
    done
}

function adb_rm() {
    adb shell rm -rf $_ADB_PATH/$@
}

function adb_mkdir() {
    adb shell mkdir -p $_ADB_PATH/$@
}

function adb_mv() {
    adb shell mv $_ADB_PATH/$1 $_ADB_PATH/$2
}

function adb_cd() {
    if [ $# == 0 ]; then  # root dir.
        _ADB_PATH=
    elif [ $1 == '..' ]; then  # change to last dir.
        if [ -z $_ADB_PATH ]; then  # root path.
            echo "/$_ADB_PATH"
            return 0
        fi
        _ADB_PATH=$(dirname $_ADB_PATH)
        if [ $_ADB_PATH == '.' ]; then  # root path now.
            _ADB_PATH=
        fi
    else
        oldpath=$_ADB_PATH
        if [[ ${1:0:1} == '/' ]]; then  # abs path
            _ADB_PATH=${1:1}
        elif [[ -z $_ADB_PATH ]]; then  # from root dir
            _ADB_PATH=$1
        else
            _ADB_PATH=$_ADB_PATH/$1  # frome non root dir
        fi
        # check new path, return old path if new path is not exist.
        if [[ ! -z $(echo $(adb shell cd $_ADB_PATH) | grep 'No such file or directory') ]]; then
            echo "Error, no found $_ADB_PATH"
            _ADB_PATH=$oldpath
        fi
    fi
    # print new path.
    adb_pwd  
}

function adb_cmds() {
    local cmd=$1
    shift

    local fn=0
    if [ $cmd == 'pwd' ]; then
        fn=adb_pwd
    elif [ $cmd == 'ls' ]; then
        fn=adb_ls
    elif [ $cmd == 'll' ]; then
        fn=adb_ll
    elif [ $cmd == 'push' ]; then
        fn=adb_push
    elif [ $cmd == 'pull' ]; then
        fn=adb_pull
    elif [ $cmd == 'rm' ]; then
        fn=adb_rm
    elif [ $cmd == 'mkdir' ]; then
        fn=adb_mkdir $@
    elif [ $cmd == 'cd' ]; then
        fn=adb_cd
    elif [ $cmd == 'mv' ]; then
        fn=adb_mv
    fi
    # execute fn
    if [ $fn != 0 ]; then
        $fn $@
    fi
}

if [[ $# == 0 || $1 == '-h' ]]; then  # help
    print_usage
else
    adb_cmds $@
fi
