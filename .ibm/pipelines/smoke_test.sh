
helm_test_until_success() {
  local release_name=$1
  local namespace=$2
  local helm_test_status=1
  local start_time=$(date +%s)
  local timeout=300  # 5 minutes in seconds

  echo "Waiting for helm test to succeed"

  if [ -z "$release_name" ]; then
    echo "Error: Helm release name is required."
    return 1
  fi

  while [ $helm_test_status -ne 0 ]; do
    echo "Running helm test for release: $release_name"
    helm test "$release_name" --namespace "$namespace"
    helm_test_status=$?

    if [ $helm_test_status -eq 0 ]; then
      echo "Helm test passed for $release_name!"
      return 0
    else
      echo "Continuing to wait"
    fi

    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))

    if [ $elapsed -ge $timeout ]; then
      echo "Timeout of 5 minutes reached for $release_name. Exiting with status $helm_test_status."
      return $helm_test_status
    fi

    echo "Helm test failed with status $helm_test_status. Retrying in 10 seconds..."
    sleep 10
  done
}

smoke_test() {
    # set -e
    local deployment_name="$1"
    local release_name="$2"
    local namespace="$3"
    local BASE_URL=$4
    local timeout=${5:-600} # Timeout in seconds (default: 600 seconds)
    
    REPORT_DIR="playwright-report"

    # Ensure RHDH Repository Exists
    if [ ! -d "rhdh" ]; then
        echo "RHDH repository not found. Cloning..."
        git clone https://github.com/redhat-developer/rhdh.git
    else
        echo "RHDH repository already exists."
    fi

    # Verify RHDH Directory
    if [ ! -d "rhdh" ]; then
        echo "❌ ERROR: RHDH directory is missing!"
        exit 1
    else
        echo "✅ RHDH directory found."
    fi

    # Install Dependencies
    cd rhdh
    cd e2e-tests
    local HOME=/tmp
    yarn config set cacheFolder /tmp/.yarn-cache
    yarn install

    echo "INSTALL CHROMIUM"
    yarn playwright install chromium

    # working-directory: rhdh/e2e-tests
    echo "RUN PLAYWRIGHT TEST"

    yarn playwright test playwright/e2e/smoke-test.spec.ts --project="any-test"

    # Ensure the report exists
    if [ ! -d "$REPORT_DIR" ]; then
      echo "Current dir"
      pwd
      echo "contents"
      ls
      ls "$REPORT_DIR"
      echo "❌ Report directory '$REPORT_DIR' not found."
    fi

    cp -r "$REPORT_DIR/" "${ARTIFACT_DIR}/"
    # Zip the report
    # echo "📦 Zipping report..."
    # zip -r "$ZIP_FILE" "$REPORT_DIR"
}
