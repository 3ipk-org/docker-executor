# DevOps Toolchain Docker Image

This repository contains a Dockerfile that builds a comprehensive DevOps toolchain image based on Debian. The image includes various tools commonly used in DevOps and cloud infrastructure management workflows.

## Installed Tools

The image includes the following tools:

1. Terraform
1. HCP (HashiCorp Cloud Platform) CLI
1. Vault
1. kubectl
1. Skaffold
1. Helm
1. AWS CLI
1. Node / npm / nvm
1. Git
1. jq
1. yq
1. curl
1. unzip
1. OpenSSH server

## Version History

| Version | Release Date | Changes |
|---------|--------------|---------|
| v1.0.0  | 13-Aug-2024  | Initial release |
| v1.1.0  | 09-Oct-2024  | Add vault, node |

## Releasing a New Version

To release a new version of the image:

1. Update the Dockerfile or any other relevant files with your changes.
2. Commit your changes and push to the main branch.
3. Create a new tag following semantic versioning:
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```
4. The GitHub Actions workflow will automatically build and push the new image to the GitHub Container Registry (ghcr.io) with the following tags:
   - `v1.2.3` (full version)
   - `v1.2` (major.minor version)
   - `latest`

## Using the Image

For CI/CD pipelines, you can use the image as a base:
```yaml
image: ghcr.io/your-username/devops-toolchain:latest

pipelines:
  default:
    - step:
        name: Terraform Plan
        script:
          - cd terraform
          - terraform init
          - terraform plan -out=tfplan
        artifacts:
          - terraform/tfplan

    - step:
        name: Terraform Apply
        trigger: manual
        script:
          - cd terraform
          - terraform apply -auto-approve tfplan

  branches:
    main:
      - step:
          name: Deploy to Kubernetes
          script:
            - kubectl config use-context my-cluster
            - helm upgrade --install my-app ./helm-charts/my-app --namespace production

```

## Version Information

To check the versions of installed tools:

```bash
docker run --rm ghcr.io/3ipk-org/docker-executor:latest aws --version
docker run --rm ghcr.io/3ipk-org/docker-executor:latest helm version
docker run --rm ghcr.io/3ipk-org/docker-executor:latest skaffold version
docker run --rm ghcr.io/3ipk-org/docker-executor:latest kubectl version
docker run --rm ghcr.io/3ipk-org/docker-executor:latest terraform version
docker run --rm ghcr.io/3ipk-org/docker-executor:latest hcp version
```

## Notes

- The image is based on Debian (slim version).
- A non-root user 'nonroot' is created for running the container.
- The working directory is set to `/workspace`.

For more detailed information about the image and its contents, please refer to the Dockerfile in this repository.



