#!/bin/bash
source $BIN_HOME/common/helpers.sh

# CHECK AND SET DEVELOPEMENT ENVIRONMENT
ENV=$1

if [ -z $ENV ]; then
    echo_error "ERROR: Missing environment argument. Please provide [dev|staging|prod]"
    usage
    exit 1
fi

if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
    echo_error "ERROR: Invalid environment argument: $ENV. Please provide [dev|staging|prod]"
    usage
    exit 1
fi

echo_h1 "Switching to $ENV environment"
source $BIN_HOME/environment/$ENV.env

# AUTHENTICATE INTO GCP
echo "Check GCP authentication."
rtcode=0
gcloud auth print-access-token 2> /dev/null
rtcode=$(echo $?)
if [ 0 != $rtcode ]; then
    echo "# Try and login into gcloud."
    rtcode=0
    gcloud auth login
    rtcode=$(echo $?)
    check_rtcode $rtcode
fi

echo "Set GCP project."
rtcode=0
gcloud config set project $GCP_PROJECT
rtcode=$(echo $?)
check_rtcode $rtcode

echo "Set GCP zone."
rtcode=0
gcloud config set compute/zone $GCP_ZONE
rtcode=$(echo $?)
check_rtcode $rtcode

echo "Get K8S credentials."
rtcode=0
gcloud container clusters get-credentials $GCP_K8S_CLUSTER
rtcode=$(echo $?)
check_rtcode $rtcode

echo "Check k8s-configs."
kubectl config current-context | grep $GCP_K8S_CLUSTER
if [ "$?" != "0" ] ; then
    (>&2 echo "Wrong cluster context '$(kubectl config current-context)'!")
    exit 1
fi

echo "Saving current evironment as '${ENV}'. Allow bash coloring!"
cat $BIN_HOME/environment/$ENV.env > /tmp/.env
echo "ENV=$ENV" > /tmp/.gcl_env

echo_success