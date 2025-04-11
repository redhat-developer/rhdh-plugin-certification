#!/bin/bash

# set -e
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
    "smoke_test.sh"
    "utils.sh"
)

# Source each script dynamically
for SCRIPT in "${SCRIPTS[@]}"; do
    source "${DIR}/${SCRIPT}"
    echo "Loaded ${SCRIPT}"
done

handle_main() {

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
export PLUGIN_FILE=`git show --name-only --oneline HEAD | grep publishers`

git show

# Check if PLUGIN_FILE is empty or contains multiple files
if [[ -z "$PLUGIN_FILE" ]]; then
    echo "PLUGIN_FILE is empty!"
    exit 1
elif [[ $(echo "$PLUGIN_FILE" | wc -l) -ne 1 ]]; then
    echo "PLUGIN_FILE contains multiple filenames:"
    echo "$PLUGIN_FILE"
    exit 1
else
    echo "PLUGIN_FILE is valid: $PLUGIN_FILE"
fi

helm repo add openshift-helm-charts https://charts.openshift.io/
helm repo update

echo "Starting helm install"
helm install \
    -f rhdh-helm-values.yaml \
    redhat-developer-hub openshift-helm-charts/redhat-developer-hub \
    --namespace test-pipeline --create-namespace
echo "Post helm install"
helm list --namespace test-pipeline

helm_test_until_success redhat-developer-hub test-pipeline

echo "Starting Upgrade"
helm upgrade --reuse-values -f "$PLUGIN_FILE" \
    redhat-developer-hub openshift-helm-charts/redhat-developer-hub \
    --namespace test-pipeline
echo "Upgrade Complete"

helm list --namespace test-pipeline
helm_test_until_success redhat-developer-hub test-pipeline

smoke_test

echo "WAITING FOR REVIEW"

sleep 1200
exit 1
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




main
