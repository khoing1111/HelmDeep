#!/bin/bash
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep release install [release-name] [chart/packge-path] [...flags]: Install a release. Similar to helm install"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
}

if [ $1 == '--help' ]; then
    usage; helm install --help; exit 0
fi

RELEASE_NAME=$1
RELEASE_DIR=$2
[ -z $RELEASE_NAME ] && (>&2 echo_error "ERROR: No release name provided!") && usage && exit 1
[ -z $RELEASE_DIR ] && (>&2 echo_error "ERROR: No release chart/package provided!") && usage && exit 1
RELEASE_DIR=$(realpath $RELEASE_DIR)
helmdeep dependency update $RELEASE_DIR

source /tmp/.env
echo_h1 "CURRENT ENV: $ENV"

if [[ $RELEASE_DIR =~ ^$CHARTS_HOME/releases/.* ]]; then
    echo_warning "WARNING: You are releasing using a chart. We recommended to release using package instead!"
    promp_confirm
    echo_h1 "Installing from chart!"
elif [[ $RELEASE_DIR =~ ^$REPO_HOME/releases/.* ]]; then
    echo_h1 "Installing from repo!"
    rm -R /tmp/_helmdeep_release_install
    mkdir /tmp/_helmdeep_release_install
    echo "Unpacking the release"
    tar -xvf $RELEASE_DIR --strip-components=1 -C /tmp/_helmdeep_release_install
    RELEASE_DIR=/tmp/_helmdeep_release_install
else
    echo_error "Invalid release!"
    exit 1
fi

helm install $RELEASE_NAME $RELEASE_DIR -f  $RELEASE_DIR/$ENV.values.yaml ${@:3}
