
timeout --foreground 5m bash <<-"EOF"
    while ! oc login "$OPENSHIFT_API" -u "$OPENSHIFT_USERNAME" -p "$OPENSHIFT_PASSWORD" --insecure-skip-tls-verify=true; do
            sleep 20
    done
EOF
if [ $? -ne 0 ]; then
    echo "Timed out waiting for login"
    exit 1
fi

echo "DAN TEST"

for file in ${{ steps.changed-files.outputs.all_changed_files }}; do
    echo "Processing file: $file"
    PARTNER_NAME=$(echo "$file" | cut -d'/' -f2)
    PLUGIN_NAME=$(echo "$file" | cut -d'/' -f3)
    VERSION=$(echo "$file" | cut -d'/' -f4)
    echo "PARTNER_NAME=$PARTNER_NAME" >> $GITHUB_OUTPUT
    echo "PLUGIN_NAME=$PLUGIN_NAME" >> $GITHUB_OUTPUT
    echo "PACKAGE_YAML=$file" >> $GITHUB_OUTPUT
    echo "VERSION=$VERSION" >> $GITHUB_OUTPUT
done

echo $GITHUB_OUTPUT

helm list
# Force fail by putting this beneath helm list
# oc login --token="${RHDH_PR_OS_CLUSTER_TOKEN}" --server="${RHDH_PR_OS_CLUSTER_URL}"
# oc whoami --show-server

