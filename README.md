## Workflow for Certifying Your Plugin with Red Hat Developer Hub

#### This document outlines the steps required to certify your plugin with Red Hat Developer Hub. Follow these instructions to ensure a smooth and successful certification process.

### 1. Submit Your Plugin for Certification

1. Create a Certification Repository:

    * Fork the Certification Repository to your GitHub account.
    * Clone the repository locally for changes.
    
2. Prepare a Certification Pull Request (PR):

     *  Write a detailed description in your PR, including:
        - Name: Plugin name
        - Authors: <list of authors>
        - OCI image: Image repository, name, and tag. Example, quay.io/example/image:v0.0.1
            
            Use supported packaging formats specified in the Plugin Packaging Documentation.

3. Submit the PR:

    * Push your changes to your fork and create a pull request against the certification repository.

### 2. Certification Pipeline

1. Automated CI/CD Pipeline:

    * Your plugin will automatically be run through the certification pipeline:
        - Compatibility checks with Red Hat Developer Hub.
        - Smoke tests for basic functionality.

2. Review Feedback:

    * Address any issues flagged during the automated pipeline.
    * Incorporate feedback from reviewers.

### 3. Post-Certification

1. Metadata Storage:

    * Ensure the plugin’s metadata is stored in the designated repository for certified plugins.

1. Ongoing Maintenance:


    *  Monitor for updates to Red Hat’s certification requirements.
    * Regularly update your plugin to ensure compatibility with new platform versions.

### Additional Resources
* Plugin Development Guidelines
* Certification FAQ
* Red Hat Support Portal

#### For questions or assistance, contact the Red Hat Developer Hub support team at support@redhat.com.

