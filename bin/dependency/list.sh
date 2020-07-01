#!/bin/bash
#################################################################
# SImilar to helm dependency update command, this command is used to update all chart's dependencies
# by packaging them into /charts directory
#
# All charts is located in $CHARTS_HOME directory
#
# All package will be put into $REPO_HOME redirectory
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Similar to helm dependency list!"
    echo "Usage:"
    echo "\$helmdeep dependency list [chart-path] [...flags]"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ] || [ $1 == '-h' ]; then
    usage; helm dependency list -h; exit 0
fi

## INITIALZIE VALIDATION
CHART_DIR=$1
[ -z $CHART_DIR ] && (>&2 echo_error "ERROR: No chart provided!") && usage && exit 1
CHART_DIR=$(realpath $CHART_DIR)

if [[ ! $CHART_DIR =~ ^$CHARTS_HOME.* ]]; then
    echo_error "ERROR: Invalid chart directory. Chart must be in folder $CHARTS_HOME"
    exit 1
fi

## PROCESS
echo_h1 "Listing dependencies using helm command!"
rtcode=0
helm dependency list $CHART_DIR ${@:2}
rtcode=$(echo $?)
check_rtcode $rtcode

echo_h1 "Listing helmdeep dependencies!"
rtcode=0
python3 $BIN_HOME/dependency/list_dependencies.py $CHART_DIR
rtcode=$(echo $?)
check_rtcode $rtcode
