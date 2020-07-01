#!/bin/bash
source $BIN_HOME/common/helpers.sh

usage() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Usage:"
    echo "\$helmdeep release list: List current releases in environment. Similar to helm list command."
    echo "\$helmdeep release history [release-name] [...flags]: Show release history in environment. Similar to helm history command."
    echo "\$helmdeep release drytest [release-name] [chart/packge-path]: dry-run the release and compare it with the current manifest."
    echo "\$helmdeep release install [release-name] [chart/packge-path] [...flags]: Install a release. Similar to helm install"
    echo "\$helmdeep release uninstall [release-name] [...flags]: Uninstall release. SImilar to helm uninstall"
    echo "\$helmdeep release upgrade [release-name] [chart/packge-path] [...flags]: Upgrade a release. Similar to helm upgrade"
    echo "\$helmdeep release rollback [release-name] [reversion] [...flags]: Rollback a release. Similar to helm rollback"
    echo "\$helmdeep release status [release-name] [...flags]: Show a release's status. Similar to helm status"
    echo ""
    echo "# You can get a list of all release using \$helmdeep list <env> [release-name]"
}

if [ $1 == '--help' ]; then
    usage; exit 0
fi

if [ $1 == 'list' ]; then
    helm list ${@:2}
elif [ $1 == 'history' ]; then
    RELEASE_NAME=$2
    [ -z $RELEASE_NAME ] && (>&2 echo_error "ERROR: No release name provided!") && usage && exit 1
    helm history $RELEASE_NAME ${@:3}
elif [ $1 == 'status' ]; then
    RELEASE_NAME=$2
    [ -z $RELEASE_NAME ] && (>&2 echo_error "ERROR: No release name provided!") && usage && exit 1
    helm status $RELEASE_NAME ${@:3}
elif [ $1 == 'uninstall' ]; then
    RELEASE_NAME=$2
    [ -z $RELEASE_NAME ] && (>&2 echo_error "ERROR: No release name provided!") && usage && exit 1
    helm uninstall $RELEASE_NAME ${@:3}
elif [ $1 == 'rollback' ]; then
    RELEASE_NAME=$2
    REVISION=$3
    [ -z $RELEASE_NAME ] && (>&2 echo_error "ERROR: No release name provided!") && usage && exit 1
    helm uninstall $RELEASE_NAME $REVISION ${@:4}
else
    $BIN_HOME/release/$1.sh ${@:2}
fi