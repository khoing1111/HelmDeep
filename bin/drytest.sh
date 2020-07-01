#!/bin/bash
source $BIN_HOME/common/helpers.sh

usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep drytest <env> <release> <version>"
    echo "# You can get a list of all release using \$helmdeep list <env> [release-name]"
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi

source $BIN_HOME/common/setup-env.sh $1
source $BIN_HOME/common/setup-release.sh "$2" "$3"
source $BIN_HOME/common/setup-gcp.sh

tmp_dir=/tmp/helmdeep-helm-release/$ENV/$RELEASE_NAME
release_package=$RELEASE_NAME-$RELEASE_VERSION
mkdir -p $tmp_dir

echo_h1 "Render release $RELEASE_NAME:$RELEASE_VERSION template"
RELEASE_PACKAGE="$REPO_HOME/releases/_$ENV/$release_package.tgz"
if [ ! -f $RELEASE_PACKAGE ]; then
    echo_error "ERROR: Release package ($RELEASE_PACKAGE) not found!"
    exit 1
fi

helm template $RELEASE_NAME $RELEASE_PACKAGE > $tmp_dir/$release_package.yaml

echo_h1 "Pulling current manifest for release $RELEASE_NAME"
rtcode=0
errormessage=$( helm status $RELEASE_NAME --output=yaml 2>&1 > $tmp_dir/_manifest.yaml)
rtcode=$(echo $?)
if [[ $errormessage == *"release: not found" ]]; then
    echo "WARNING: No manifest found. Assume new release!"
    echo "" > $tmp_dir/_current.yaml
elif [ $rtcode == 0 ]; then
    echo "Manifest pulled!"
    python3 $BIN_HOME/common/parse_manifest.py $tmp_dir
else
    echo_error "ERROR: $errormessage"
    exit 1
fi

echo_h1 "### Diff:"
git diff --no-index --color=always $tmp_dir/_current.yaml $tmp_dir/$release_package.yaml > $tmp_dir/_diff-current-$release_package.yaml
cat $tmp_dir/_diff-current-$release_package.yaml
