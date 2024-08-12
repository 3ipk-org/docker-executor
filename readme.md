
# DevOps Toolchain Docker Image

This repository contains a Dockerfile that builds a comprehensive DevOps toolchain image based on Debian. The image includes various tools commonly used in DevOps and cloud infrastructure management workflows.

## Purpose

The purpose of this Docker image is to provide a consistent environment with pre-installed DevOps tools, making it easier to run infrastructure management, Kubernetes operations, and cloud-related tasks across different environments.

## Installed Tools

The following tools are installed in this Docker image:

1. Terraform - Infrastructure as Code tool
2. HCP (HashiCorp Cloud Platform) CLI
3. kubectl - Kubernetes command-line tool
4. Skaffold - Command line tool that facilitates continuous development for Kubernetes applications
5. Helm - Kubernetes package manager
6. AWS CLI - Command line interface for Amazon Web Services
7. Git - Version control system
8. jq - Lightweight command-line JSON processor
9. yq - YAML processor
10. curl - Command line tool for transferring data using various protocols
11. unzip - Extraction utility for ZIP archives
12. OpenSSH server - For SSH access

## Usage

To use this image, you can pull it from your container registry or build it locally using the provided Dockerfile.

```bash
# edit / check tools versions in ./build.sh
# run the build
./build.sh
```

## Notes

- The image is based on Debian (slim version).
- A non-root user 'nonroot' is created for running the container.
- The working directory is set to /workspace.
- Custom versions of tools can be specified using build arguments.
