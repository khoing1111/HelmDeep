#!/bin/bash
#################################################################
# This command is used to list all packages in our custom repository.
#
# All package will be put into $REPO_HOME redirectory
#################################################################
source $BIN_HOME/common/helpers.sh

## HELP
usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage: \$helmdeep util list-packages [repo-path] ([entry-filter])"
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi

## INITIALZIE VALIDATION
REPO_PATH=$1
[ -z $REPO_PATH ] && (>&2 echo_error "ERROR: Missing repo path!") && usage && exit 1
REPO_PATH=$(realpath $REPO_PATH)

if [ ! -d "$REPO_PATH" ]; then
    echo_error "Repo directory $REPO_PATH not found!"
    exit 1
fi

ENTRY_FILTER="*"
if [ $# -eq 2 ]; then
    ENTRY_FILTER=$2
fi

python3 $BIN_HOME/util/list_packages.py $REPO_PATH "$ENTRY_FILTER"
