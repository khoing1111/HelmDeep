#!/bin/bash
source $BIN_HOME/common/helpers.sh

usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep compare <chart/package> <chart/package>"
    echo "# You can get a list of all release package using \$helmdeep list <env> [release-name]"
}

## HELP
if [ $1 == '--help' ]; then
    usage; exit 0
fi

## INITIALZIE VALIDATION
CHART_1=$1
[ -z $CHART_1 ] && (>&2 echo_error "ERROR: Missing charts or package!") && usage && exit 1
CHART_1=$(realpath $CHART_1)

CHART_2=$2
[ -z $CHART_2 ] && (>&2 echo_error "ERROR: Missing charts or package!") && usage && exit 1
CHART_2=$(realpath $CHART_2)

# PROCESS
tmp_dir=/tmp/helmdeep-helm-compare
mkdir -p $tmp_dir

echo_h1 "Rendering the first chart $CHART_1"
rtcode=0
helm template $CHART_1 $CHART_1 > $tmp_dir/_chart1.yaml
rtcode=$(echo $?)
check_rtcode $rtcode

echo_h1 "Rendering the second chart $CHART_2"
rtcode=0
helm template $CHART_2 $CHART_2 > $tmp_dir/_chart2.yaml
rtcode=$(echo $?)
check_rtcode $rtcode

echo_h1 "### Diff:"
git diff --no-index --color=always $tmp_dir/_chart1.yaml $tmp_dir/_chart2.yaml > $tmp_dir/_diff.yaml
cat $tmp_dir/_diff.yaml
