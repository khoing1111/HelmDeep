#!/bin/bash
#################################################################
# This command is used to remove a package inside our helmdeep repo.
# It will delete the tar.gz file
# Then update the repo index
#
# All package will be put into $REPO_HOME redirectory
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep util remove-package [package-path]"
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi

## INITIALZIE VALIDATION
for var in "$@"
do
    PACKAGE_FILE=$var
    PACKAGE_FILE=$(realpath $PACKAGE_FILE)
    echo "Removing package: $PACKAGE_FILE"
    [ -z $PACKAGE_FILE ] && (>&2 echo_error "ERROR: Package not found!") && usage && exit 1

    if [[ ! $PACKAGE_FILE =~ ^$REPO_HOME.* ]]; then
        echo_error "ERROR: Invalid package directory. Expec this package in $REPO_HOME directory"
        exit 1
    fi

    PACKAGE_REPO_PATH=$(dirname "${PACKAGE_FILE}")

    rm $PACKAGE_FILE
    helm repo index $PACKAGE_REPO_PATH
done

helm repo index $REPO_HOME

echo_success
