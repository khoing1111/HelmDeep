#!/bin/bash
COMMANDS="(import-template|remove-package|list-packages)"

usage () {
    echo "Unknown command $1. Expect $COMMANDS"
    echo "TODO: Add usage here!!"
}

if [[ ! "$1" =~ ^$COMMANDS$ ]]; then
    usage $1 && exit 1
fi

$BIN_HOME/util/$1.sh ${@:2}
