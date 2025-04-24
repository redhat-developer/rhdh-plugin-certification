
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
    yarn install

    # name: Install Playwright Dependencies
    cd e2e-tests

    echo "INSTALL CHROMIUM"
    yarn playwright install chromium

    # name: Run Playwright Smoke Test
        
    # working-directory: rhdh/e2e-tests
    echo "RUN PLAYWRIGHT TEST"

    yarn playwright test playwright/e2e/smoke-test.spec.ts --project="any-test"


    # Check if the Playwright report directory exists
    if [ -d "rhdh/e2e-tests/playwright-report" ]; then
        echo "Playwright report directory exists."

    else
        echo "Playwright report directory is missing!"
        exit 1
    fi




    # Config
    REPO="your-username/your-repo"   # Update this or use: gh repo view --json nameWithOwner
    TAG="v1.0.0"                     # You can make this dynamic
    REPORT_DIR="rhdh/e2e-tests/playwright-report"
    ZIP_FILE="playwright-report.zip"

    # Ensure the report exists
    if [ ! -d "$REPORT_DIR" ]; then
      echo "❌ Report directory '$REPORT_DIR' not found."
      exit 1
    fi

    # Zip the report
    echo "📦 Zipping report..."
    zip -r "$ZIP_FILE" "$REPORT_DIR"

    # Check if release exists
    if ! gh release view "$TAG" --repo "$REPO" &> /dev/null; then
      echo "🔖 Creating release $TAG..."
      gh release create "$TAG" --repo "$REPO" --title "Test Report $TAG" --notes "Automated Playwright report upload"
    else
      echo "📄 Release $TAG already exists."
    fi

    # Upload to release
    echo "📤 Uploading report..."
    gh release upload "$TAG" "$ZIP_FILE" --repo "$REPO" --clobber

    echo "✅ Report uploaded: https://github.com/$REPO/releases/tag/$TAG"

    # ✅ Upload Playwright Report inside the same job
    # - name: Upload Playwright Report
    #   if: always()
    #   uses: actions/upload-artifact@v4
    #   with:
    #     name: playwright-report
    #     path: rhdh/e2e-tests/playwright-report/
    #     retention-days: 7
    #     if-no-files-found: warn
    #     include-hidden-files: true

}

# smoke_test
# helm_test_until_success redhat-developer-hub test-pipeline-dan