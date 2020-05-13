#!/usr/bin/env sh

set -x
set -e

#KUBECONFIG setup
#TODO support envsubst on values files
envsubst < /.kube/config_template > /.kube/config
rm /.kube/config_template

#Helm preparation
#TODO support chart version specification
#export CHART_VERSION_ARGUMENT="--version 0.1.0"
export CHART_VERSION_ARGUMENT=""
export RELEASE_NAME="${RELEASE_NAME:=${DRONE_REPO_NAME}}"
export TIMEOUT="${TIMEOUT:=5m}"

#If environment-specific (namespace) file exists, then we apply it after the generic 'values.yaml' file, to overlay environment-specific values
ENVIRONMENT_SPECIFIC_FILE=".k8s/values-${NAMESPACE}.yaml"
if test -f "$ENVIRONMENT_SPECIFIC_FILE"; then
  export ENVIRONMENT_VALUES_ARGUMENT="-f ${ENVIRONMENT_SPECIFIC_FILE}"
fi

helm repo add k8s-apps https://rubasace.github.io/k8s-application-chart/

##TODO make Helm fail when deployment fails
helm upgrade "${RELEASE_NAME}"  k8s-apps/kubernetes-application ${CHART_VERSION_ARGUMENT} --install -n ${NAMESPACE} --atomic --debug --wait --timeout ${TIMEOUT} \
--set deployment.tag=${IMAGE_TAG} -f .k8s/values.yaml ${ENVIRONMENT_VALUES_ARGUMENT}
