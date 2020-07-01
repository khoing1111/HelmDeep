#!/bin/bash
#################################################################
# SImilar to helm package, this command is used to packaging charts into packages
# All charts is located in $CHARTS_HOME directory
#
# All package will be put into $REPO_HOME redirectory
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Similar to helm package command!"
    echo "However, the main differences includes:"
    echo "1. This command will always output to our $REPO_HOME directory"
    echo "2. This command will always update dependencies before running"
    echo "Usage:"
    echo "\$helmdeep package [chart-path]"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ] || [ $1 == '-h' ]; then
    usage; helm package -h; exit 0
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
echo_h1 "Update dependencies!"
$BIN_HOME/dependency/update.sh $CHART_DIR

CHART_REPO_PATH=$(dirname "${CHART_DIR}")
CHART_REPO_PATH=${CHART_REPO_PATH#"$CHARTS_HOME"}

CHART_PACKAGE_PATH=$REPO_HOME$CHART_REPO_PATH
echo "Chart package path: $CHART_PACKAGE_PATH"
mkdir -p $CHART_PACKAGE_PATH

# Check if version already exist. If yes then ask for confirmation before rewrite package
rtcode=0
python3 $BIN_HOME/common/safe_guard_versioning.py $CHART_DIR $CHART_PACKAGE_PATH
rtcode=$(echo $?)
check_rtcode $rtcode

# Write package and update repo index
echo_h1 "Packaging chart"
helm package $CHART_DIR --destination $CHART_PACKAGE_PATH ${@:2}
helm repo index $CHART_PACKAGE_PATH
helm repo index $REPO_HOME

echo_success
