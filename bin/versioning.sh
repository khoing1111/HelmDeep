#!/bin/bash
source $BIN_HOME/common/helpers.sh
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage:"
    echo "\$helmdeep versioning <major|minor|patch> [chart-path]"
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi


UPDATE_TYPE=$1
[ -z $UPDATE_TYPE ] && (>&2 echo_error "ERROR: No versioning update type provided!") && usage && exit 1

CHART=$2
[ -z $CHART ] && (>&2 echo_error "ERROR: No path to chart provided!") && usage && exit 1
CHART=$(realpath $CHART)

rtcode=0
python3 $BIN_HOME/common/versioning.py $UPDATE_TYPE $CHART
rtcode=$(echo $?)
check_rtcode $rtcode

echo "Done!"
