## Certifying Your Plugin with Red Hat Developer Hub

This document outlines the steps required to certify your plugin with Red Hat Developer Hub. Follow these instructions to ensure a smooth and successful certification process.

### 1. Submit Your Plugin for Certification

1. Fork the Certification [Repository](https://github.com/redhat-developer/rhdh-plugin-certification) to your GitHub account.
2. Prepare a Certification Pull Request:
   - Create a directory under `publishers` with the name of your organization.
   - Inside this directory, create a subdirectory with the name of your dynamic plugin.
   - Within this plugin directory, create another subdirectory using the version of the plugin as the directory name.
   - Finally, in this version directory, create a file called `package.yaml`.
     - In the `package.yaml` file, add the content for your dynamic plugin. Below is an example structure and content:

       **Directory Structure:**
       ```plaintext
       publishers/
       └── your-organization
           └── your-plugin
               └── v1.0.0
                   └── package.yaml
       ```

       **Example `package.yaml` Content:**
       ```yaml
       global:
         dynamic:
           plugins:
             - package: oci://quay.io/tkral/backstage-community-plugin-todo:v0.1.1!backstage-community-plugin-todo
               disabled: false
       ```

3. Submit the PR:
   - Push your changes to your fork and create a pull request against the certification repository.

### 2. Post-Certification

1. **Metadata Storage:**
   - Ensure the plugin’s metadata is stored in the designated repository for certified plugins.
2. **Ongoing Maintenance:**
   - Monitor for updates to Red Hat’s certification requirements.
   - Regularly update your plugin to ensure compatibility with new platform versions.

---

## FAQ: Understanding the Certification Process

### **Q: What happens after I submit my plugin?**

Once your PR is created, an automated certification pipeline runs to verify compatibility with Red Hat Developer Hub. This includes:

- Compatibility checks
- Smoke tests
- A final review process

You will be notified if any changes are required.

### **Q: What kind of tests are performed in the pipeline?**

The pipeline runs the following automated checks:

- Ensures your plugin meets Red Hat Developer Hub compatibility requirements.
- Executes smoke tests to verify basic functionality.
- Validates the `package.yaml` structure and metadata.

### **Q: Do I need to take any action during the certification process?**

You do not need to manually trigger any steps. However, if an issue is found, you will receive feedback with steps to resolve it.

#### For questions or assistance, contact the Red Hat Developer Hub support team at [support@redhat.com](mailto:support@redhat.com).

