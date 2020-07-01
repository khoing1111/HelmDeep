#!/bin/bash
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Similar to helm show command"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ] || [ $1 == '-h' ]; then
    usage; helm show -h; exit 0
fi

helm show ${@:1}
