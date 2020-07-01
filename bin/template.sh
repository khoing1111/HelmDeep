#!/bin/bash
#################################################################
# SImilar to helm template, render the chart template and show it's content
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Similar to helm template, render the chart template and show it's content"
    echo "Usage: \$helmdeep template [chart/package-path]"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ] || [ $1 == '-h' ]; then
    usage; helm template -h; exit 0
fi

CHART_DIR=$1
CHART_DIR=$(realpath $CHART_DIR)
helmdeep dependency update $CHART_DIR
if  [[ $CHART_DIR =~ ^$CHARTS_HOME/releases/.* ]] || [[ $CHART_DIR =~ ^$REPO_HOME/releases/.* ]]; then
    echo_h1 "Templating a release!"
    source /tmp/.env
    echo_h1 "CURRENT ENV: $ENV"
    RELEASE_DIR=$CHART_DIR

    if [[ $RELEASE_DIR =~ ^$REPO_HOME/releases/.* ]]; then
        echo_h1 "Unpacking the release"
        rm -R /tmp/_helmdeep_release_template
        mkdir /tmp/_helmdeep_release_template
        tar -xvf $RELEASE_DIR --strip-components=1 -C /tmp/_helmdeep_release_template
        RELEASE_DIR=/tmp/_helmdeep_release_template
    fi

    echo_h1 "TEMPLATE BEGIN------------------------------------------------------------------------------------------------------------------"
    helm template $RELEASE_DIR -f $RELEASE_DIR/$ENV.values.yaml ${@:3}
else
    helm template ${@:1}
fi
