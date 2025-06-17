#!/bin/bash

# set -e
export PS4='[$(date "+%Y-%m-%d %H:%M:%S")] ' # logs timestamp for every cmd.

# Define log file names and directories.
LOGFILE="test-log"
export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERALL_RESULT=0


cluster_login() {
    export kubefile=`ls /tmp | grep kube`
    export KUBECONFIG="/tmp/${kubefile}"
timeout --foreground 5m bash <<-"EOF"
    while ! oc login -p `cat $KUBEADMIN_PASSWORD_FILE` -u kubeadmin --insecure-skip-tls-verify=true; do
            sleep 20
    done
EOF
if [ $? -ne 0 ]; then
    echo "Timed out waiting for login"
    exit 1
fi
}

# Define a cleanup function to be executed upon script exit.
cleanup() {
  echo "Cleaning up before exiting"
}

trap cleanup EXIT INT ERR

SCRIPTS=(
    "env_variables.sh"
    "smoke_test.sh"
    "utils.sh"
)

# Source each script dynamically
for SCRIPT in "${SCRIPTS[@]}"; do
    source "${DIR}/${SCRIPT}"
    echo "Loaded ${SCRIPT}"
done

handle_main() {

echo "DAN1"
cluster_login

export HOME=/tmp
export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "DAN2"
export NAME_SPACE="test-pipeline"
export DEPLOYMENT_NAME="redhat-developer-hub"
echo "DAN3"
export HELM_CHART_VALUE_FILE_NAME_BASE="rhdh-helm-values.yaml"
export K8S_CLUSTER_ROUTER_BASE=$(oc get route console -n openshift-console -o=jsonpath='{.spec.host}' | sed 's/^[^.]*\.//')

echo $HELM_CHART_VALUE_FILE_NAME_BASE
echo $K8S_CLUSTER_ROUTER_BASE
echo "DAN4"

export IMAGE_LOC=`git log -p --pretty=format: -- certified-plugins.yaml | grep '^[+-]' | grep -Ev '^\+\+\+|^---' | grep image_loc | awk '{print $3}'`
export IMAGE_VERSION=`git log -p --pretty=format: -- certified-plugins.yaml | grep '^[+-]' | grep -Ev '^\+\+\+|^---' | grep plugin_version | awk '{print $3}'`
export PLUGIN_FILE=`git show --name-only --oneline HEAD | grep publishers`
echo "DAN5"
# Check if PLUGIN_FILE is empty or contains multiple files
if [[ -z "$PLUGIN_FILE" ]]; then
    echo "Plugin file $PLUGIN_FILE is empty!"
    git show
    exit 1
elif [[ $(echo "$PLUGIN_FILE" | wc -l) -ne 1 ]]; then
    echo "PLUGIN_FILE contains multiple filenames:"
    echo "$PLUGIN_FILE"
    exit 1
else
    echo "PLUGIN_FILE is valid: $PLUGIN_FILE"
fi

echo "DAN6"



echo "DAN7"
helm repo add openshift-helm-charts https://charts.openshift.io/
helm repo update

echo "Starting helm install"

helm install \
    -f ${HELM_CHART_VALUE_FILE_NAME_BASE} \
    --set global.clusterRouterBase="$K8S_CLUSTER_ROUTER_BASE" \
    ${DEPLOYMENT_NAME} openshift-helm-charts/redhat-developer-hub \
    --namespace ${NAME_SPACE} --create-namespace

echo "DAN8"
helm_test_until_success ${DEPLOYMENT_NAME} ${NAME_SPACE}

echo "Starting Upgrade"
helm upgrade --reuse-values -f "$PLUGIN_FILE" \
    ${DEPLOYMENT_NAME} openshift-helm-charts/redhat-developer-hub \
    --namespace ${NAME_SPACE}

helm_test_until_success ${DEPLOYMENT_NAME} ${NAME_SPACE}

local url="https://${DEPLOYMENT_NAME}-${NAME_SPACE}.${K8S_CLUSTER_ROUTER_BASE}"

echo "$url"

smoke_test "${DEPLOYMENT_NAME}" "${RELEASE_NAME}" "${NAME_SPACE}" "${url}"
sleep 10000
}

main() {
  echo "Log file: ${LOGFILE}"
  echo "JOB_NAME : $JOB_NAME"

  case "$JOB_NAME" in
    *pull*)
      echo "Calling handle_main"
      handle_main
      ;;
  esac

echo "Main script completed with result: ${OVERALL_RESULT}"
exit "${OVERALL_RESULT}"

}

# Call the main function to start the script
main
