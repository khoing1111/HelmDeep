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
    echo "Similar to helm dependency update!"
    echo "Usage:"
    echo "\$helmdeep dependency update [chart-path] [...flags]"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ] || [ $1 == '-h' ]; then
    usage; helm dependency update -h; exit 0
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
# NOTE: We need to do this by hand since Helm3 Do not support local tar.gz file dependencies.
rm -Rf $CHART_DIR/charts # Remove dependencies to force refresh
mkdir $CHART_DIR/charts

# Update process
echo_h1 "Updating dependencies using helm command!"
rtcode=0
helm dependency update $CHART_DIR ${@:2}
rtcode=$(echo $?)
check_rtcode $rtcode

echo_h1 "Updating helmdeep dependencies!"
rtcode=0
python3 $BIN_HOME/dependency/update_dependencies.py $CHART_DIR # Update dependencies again
rtcode=$(echo $?)
check_rtcode $rtcode
