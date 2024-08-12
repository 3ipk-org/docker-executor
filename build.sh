#!/usr/bin/env bash


IMAGE_NAME=3ipk-executor
IMAGE_TAG=latest

# https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst
AWS_VERSION="2.17.25"

# https://github.com/hashicorp/terraform/releases
# https://releases.hashicorp.com/terraform/
TF_VERSION="1.9.4"

# https://releases.hashicorp.com/hcp/0.4.0/
HCP_VERSION="0.4.0"

# https://github.com/GoogleContainerTools/skaffold/releases
SKAFFOLD_VERSION="v2.13.1"

# https://github.com/helm/helm/releases
HELM_VERSION="v3.15.3"

# latest: https://dl.k8s.io/release/stable.txt
KUBECTL_VERSION="v1.30.3"


docker buildx build \
  --progress plain \
  --build-arg AWS_CLI_VERSION=${AWS_VERSION} \
  --build-arg TERRAFORM_VERSION=${TF_VERSION} \
  --build-arg HCP_VERSION=${HCP_VERSION} \
  --build-arg SKAFFOLD_VERSION=${SKAFFOLD_VERSION} \
  --build-arg HELM_VERSION=${HELM_VERSION} \
  --build-arg KUBECTL_VERSION=${KUBECTL_VERSION} \
  --tag ${IMAGE_NAME}:${IMAGE_TAG} .


# verify 
docker run --rm 3ipk-executor:latest aws --version
docker run --rm 3ipk-executor:latest helm version
docker run --rm 3ipk-executor:latest skaffold version
docker run --rm 3ipk-executor:latest kubectl version
docker run --rm 3ipk-executor:latest terraform version
docker run --rm 3ipk-executor:latest hcp version
