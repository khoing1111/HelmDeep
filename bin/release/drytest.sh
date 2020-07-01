#!/bin/bash
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep release drytest [release-name] [chart/packge-path] "
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi

TMP_DIR=/tmp/_release_drytest
rm -R $TMP_DIR
mkdir $TMP_DIR

RELEASE_NAME=$1
RELEASE_DIR=$(realpath $2)
[ -z $RELEASE_NAME ] && (>&2 echo_error "ERROR: No release name provided!") && usage && exit 1
if [[ ! $RELEASE_DIR =~ ^$CHARTS_HOME/releases/.* ]] && [[ ! $RELEASE_DIR =~ ^$REPO_HOME/releases/.* ]]; then
    echo_error "ERROR: Invalid release directory/package"
    exit 1;
fi

echo_h1 "Rendering local release $RELEASE_DIR"
if [[ $RELEASE_DIR =~ ^$REPO_HOME/releases/.* ]]; then
    echo "Unpacking the release"
    rm -R $TMP_DIR
    mkdir $TMP_DIR
    tar -xvf $RELEASE_DIR --strip-components=1 -C $TMP_DIR
    RELEASE_DIR=$TMP_DIR
fi

rtcode=0
helm template $RELEASE_DIR > $TMP_DIR/_local.yaml
rtcode=$(echo $?)
check_rtcode $rtcode

echo_h1 "Pulling current manifest for release $RELEASE_NAME"
rtcode=0
errormessage=$(helm status $RELEASE_NAME --output=yaml 2>&1 >  $TMP_DIR/_manifest.yaml)
rtcode=$(echo $?)
if [[ $errormessage == *"release: not found" ]]; then
    echo_warning "WARNING: No manifest found. Assume new release!"
    echo "" > $TMP_DIR/_server.yaml
elif [ $rtcode == 0 ]; then
    echo "Manifest pulled!"
    python3 $BIN_HOME/release/parse_manifest.py  $TMP_DIR/_manifest.yaml $TMP_DIR/_server.yaml
else
    echo_error "ERROR: $errormessage"
    exit 1
fi

echo_h1 "############################################################"
git diff --no-index --color=always $TMP_DIR/_server.yaml $TMP_DIR/_local.yaml > $TMP_DIR/_diff.yaml
cat $TMP_DIR/_diff.yaml
