smoke_test() {

    echo "DAN"

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

    #   # ✅ Upload Playwright Report inside the same job
    #   - name: Upload Playwright Report
    #     if: always()
    #     uses: actions/upload-artifact@v4
    #     with:
    #       name: playwright-report
    #       path: rhdh/e2e-tests/playwright-report/
    #       retention-days: 7
    #       if-no-files-found: warn
    #       include-hidden-files: true

    #   - name: Verify Playwright Report Before Upload
    #     if: always()
    #     run: |
    #       echo "🔍 Checking if Playwright report directory exists..."
    #       if [ -d "rhdh/e2e-tests/playwright-report" ]; then
    #         echo "✅ Playwright report directory found!"
    #         echo "🔍 Listing contents:"
    #         ls -lah rhdh/e2e-tests/playwright-report
    #       else
    #         echo "❌ ERROR: Playwright report directory NOT found!"
    #       fi

    #   - name: Show current working directory and contents
    #     if: always()
    #     run: |
    #       echo "📂 Current working directory:"
    #       pwd
    #       echo "🔍 Listing contents of current directory:"
    #       ls -lah

    #   - name: Show one level up directory
    #     if: always()
    #     run: |
    #       echo "🔍 Listing contents of parent directory:"
    #       ls -lah ..

    #   - name: Attempt to find Playwright Report
    #     if: always()
    #     run: |
    #       echo "🔍 Trying to locate 'rhdh' directory and navigate into it..."
    #       if [ -d "rhdh" ]; then
    #         cd rhdh
    #         echo "✅ Successfully entered 'rhdh' directory."
    #         echo "🔍 Listing contents inside 'rhdh':"
    #         ls -lah
          
    #         if [ -d "e2e-tests" ]; then
    #           cd e2e-tests
    #           echo "✅ Successfully entered 'e2e-tests' directory."
    #           echo "🔍 Listing contents inside 'e2e-tests':"
    #           ls -lah
          
    #           if [ -d "playwright-report" ]; then
    #             echo "✅ Playwright report directory found!"
    #             echo "🔍 Listing contents of 'playwright-report':"
    #             ls -lah playwright-report
    #           else
    #             echo "❌ Playwright report directory NOT found!"
    #           fi
    #         else
    #           echo "❌ 'e2e-tests' directory NOT found inside 'rhdh'!"
    #         fi
    #       else
    #         echo "❌ 'rhdh' directory NOT found in current path!"
    #       fi    
}

smoke_test