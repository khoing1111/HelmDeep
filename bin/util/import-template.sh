#!/bin/bash
#################################################################
# This helper command is used to import our template (Mostlikely templates  in common charts ) into
# another chart.
# You must provide:
# 1. The path the the template library chart
# 2. A unique name wrapper for the template that will be used to embed the template and it's variable
# into the destination chart
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep util import-template [library-chart/package] [template-name] [import-chart-path]"
    echo "Usage: \$helmdeep util import-template [library-chart/package] [template-name] [import-chart-path] --fill-data"
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi

## INITIALZIE VALIDATION
TEMPLATE_CHART_PATH=$1
ORIGINAL_TEMPLATE_CHART_PATH=$TEMPLATE_CHART_PATH
TEMPLATE_NAME=$2
IMPORT_CHART_DIR=$3
SHOULD_FILL_DATA="no"
if [ ! -z $4 ]; then
    SHOULD_FILL_DATA="yes"
fi

# If this is a package then unpack it
if [ -f $TEMPLATE_CHART_PATH ]; then
    echo_h1 "Unpacking $TEMPLATE_CHART_PATH package"
    rm -R /tmp/_util_import_templates
    mkdir /tmp/_util_import_templates
    tar -xvf $TEMPLATE_CHART_PATH --strip-components=1 -C /tmp/_util_import_templates
    TEMPLATE_CHART_PATH=/tmp/_util_import_templates
fi

TEMPLATE_USAGE_DIR=$TEMPLATE_CHART_PATH/usage/$TEMPLATE_NAME
if [ ! -d $TEMPLATE_USAGE_DIR ]; then
    echo_error "ERROR: Template usage $TEMPLATE_USAGE_DIR not found!"
    exit 1
fi

if [ ! -f $IMPORT_CHART_DIR/Chart.yaml ]; then
    echo_error "ERROR: Invalid chart $IMPORT_CHART_DIR!"
    exit 1
fi

# Request a unique name for the chart
echo "Please input a unique context name for this component"
read -r -e
CONTEX_UID=$REPLY
COMP_TEMPLATE_NAME=$TEMPLATE_NAME\_$CONTEX_UID.yaml

rtcode=0
python3 $BIN_HOME/util/import_template_check_name.py $IMPORT_CHART_DIR $CONTEX_UID $COMP_TEMPLATE_NAME
rtcode=$(echo $?)
check_rtcode $rtcode

## PROCESS
# 1. Add template chart as dependency into destination chart
echo_h1 "Update dependencies!"
rtcode=0
python3 $BIN_HOME/common/configure_deps.py $IMPORT_CHART_DIR "no" $ORIGINAL_TEMPLATE_CHART_PATH
rtcode=$(echo $?)
check_rtcode $rtcode

$BIN_HOME/dependency/update.sh $IMPORT_CHART_DIR

# 2. Configurate the template
echo_h1 "Configurating template"
rtcode=0
python3 $BIN_HOME/util/import_template.py $TEMPLATE_USAGE_DIR $IMPORT_CHART_DIR $CONTEX_UID $COMP_TEMPLATE_NAME $SHOULD_FILL_DATA
rtcode=$(echo $?)
check_rtcode $rtcode

echo_success
