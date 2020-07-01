#!/bin/bash
#################################################################
# SImilar to helm create, this command is used to create new charts
# All charts is located in $CHARTS_HOME directory
#
# We already have common chart which contain common templates to be used by other charts
#
# HelmDeep defined our own charts type including:
# - Service chart: This is the actually service charts that contain all information needed to run a service
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Similar to helm create command"
    echo "If the chart directory is in $CHARTS_HOME/releases directory then it will have"
    echo "our release files structure:"
    echo "  > Require to have dependencies"
    echo "  > No templates"
    echo ""
    echo "Usage: \$helmdeep create [chart-directory] [..options]"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ] || [ $1 == '-h' ]; then
    usage; helm create -h; exit 0
fi

## INITIALZIE VALIDATION
CHART_DIR=$1
CHART_DIR=$(realpath $CHART_DIR)
if [ -d $CHART_DIR ]; then
    echo_error "ERROR: $CHART_DIR already exist"
    exit 1
fi

## PROCESS
helm create $CHART_DIR ${@:2}
rm -R $CHART_DIR/templates/*
> $CHART_DIR/values.yaml
IS_RELEASE="no"
if [[ $CHART_DIR =~ ^$CHARTS_HOME/releases/.* ]]; then
    IS_RELEASE="yes"
    rm $CHART_DIR/values.yaml
    touch $CHART_DIR/dev.values.yaml
    touch $CHART_DIR/staging.values.yaml
    touch $CHART_DIR/prod.values.yaml
    rm $CHART_DIR/templates
fi

echo_h1 "Add dependencies"
if [ "$IS_RELEASE" = "yes" ]; then
    echo_h1 "This is a release, expect to have at least one dependencies!"
fi

echo "Dependencies (path to chart or package). Use empty endline to finish selections:"
DEPENDENCIES=""
while true; do
    # Read input
    read -r -e
    reply=$REPLY
    if [ -z $reply ]; then
        break
    else
        echo -ne "Press Enter to with empty line to finish!\r"
    fi

    # Check if valid file or folder
    if [ ! -f $reply ]; then
        if [ ! -d $reply ]; then
            echo_error "ERROR: must provide chart or package path"
            rm -R $CHART_DIR
            exit 1
        fi
    fi

    # If this is a chart directory, expect a Chart.yaml file
    dep=$(realpath $reply)
    if [ -d $dep -a ! -f $dep/Chart.yaml ]; then
        echo_error "ERROR: Invalid chart folder! Missing Chart.yaml."
        rm -R $CHART_DIR
        exit 1
    fi

    # If this is a package then expect to have Chart.yaml inside it when unzip.
    if [ -f $dep ]; then
        tar -tvf $dep | grep -q "Chart.yaml"
        if [ "$?" != "0" ] ; then
            echo_error "ERROR: Invalid package!"
            rm -R $CHART_DIR
            exit 1
        fi
    fi

    DEPENDENCIES=$DEPENDENCIES" "$dep
done

# For aesthetic we override the "Press Enter to with empty line to finish!" message with empty space
echo "                                                                                      "

# Configuring dependencies in chart manifest file (Chart.yaml)
# NOTE: We need to do this because of how our repo work. We store everything under tar.gz file in our own repository.
# And because helm do not support local tar.gz file as dependency, we create our own way to load it.
echo_h1 "Configuring dependencies"
rtcode=0
python3 $BIN_HOME/common/configure_deps.py $CHART_DIR $IS_RELEASE $DEPENDENCIES
rtcode=$(echo $?)
check_rtcode $rtcode
echo_success
