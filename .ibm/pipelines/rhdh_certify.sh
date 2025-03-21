#!/bin/bash

set -e
export PS4='[$(date "+%Y-%m-%d %H:%M:%S")] ' # logs timestamp for every cmd.

# Define log file names and directories.
LOGFILE="test-log"
export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERALL_RESULT=0

# Define a cleanup function to be executed upon script exit.
# shellcheck disable=SC2317
cleanup() {
  echo "Cleaning up before exiting"
}

trap cleanup EXIT INT ERR

SCRIPTS=(
    "env_variables.sh"
    "utils.sh"
)

# Source each script dynamically
for SCRIPT in "${SCRIPTS[@]}"; do
    source "${DIR}/${SCRIPT}"
    echo "Loaded ${SCRIPT}"
done


main() {
  echo "Log file: ${LOGFILE}"
  echo "JOB_NAME : $JOB_NAME"

  case "$JOB_NAME" in
    *aks*)
      echo "Calling handle_aks"
      handle_aks
      ;;
    *gke*)
      echo "Calling handle_gke"
      handle_gke
      ;;
    *operator*)
      echo "Calling Operator"
      handle_operator
      ;;
    *periodic*)
      echo "Calling handle_periodic"
      handle_nightly
      ;;
    *pull*)
      echo "Calling handle_main"
      handle_main
      ;;
  esac

echo "Main script completed with result: ${OVERALL_RESULT}"
exit "${OVERALL_RESULT}"

}

main



timeout --foreground 5m bash <<-"EOF"
    while ! oc login "$OPENSHIFT_API" -u "$OPENSHIFT_USERNAME" -p "$OPENSHIFT_PASSWORD" --insecure-skip-tls-verify=true; do
            sleep 20
    done
EOF
if [ $? -ne 0 ]; then
    echo "Timed out waiting for login"
    exit 1
fi

export IMAGE_LOC=`git log -p --pretty=format: -- certified-plugins.yaml | grep '^[+-]' | grep -Ev '^\+\+\+|^---' | grep image_loc | awk '{print $3}'`
export IMAGE_VERSION=`git log -p --pretty=format: -- certified-plugins.yaml | grep '^[+-]' | grep -Ev '^\+\+\+|^---' | grep plugin_version | awk '{print $3}'`



helm list


helm repo add openshift-helm-charts https://charts.openshift.io/
helm repo update

helm install \
    -f rhdh-helm-values.yaml \
    redhat-developer-hub openshift-helm-charts/redhat-developer-hub \
    --namespace rose-pipeline --create-namespace


helm --kubeconfig /opt/.kube/config upgrade --reuse-values -f "${{ needs.detect-changes.outputs.package_yaml }}" \
    redhat-developer-hub openshift-helm-charts/redhat-developer-hub \
    --namespace rose-pipeline

helm list

echo "WAITING FOR REVIEW"

sleep 300
exit 1