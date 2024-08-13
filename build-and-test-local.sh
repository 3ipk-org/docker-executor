#!/usr/bin/env bash

IMAGE_NAME=3ipk-executor
IMAGE_TAG=latest

docker buildx build \
  --progress plain \
  --tag ${IMAGE_NAME}:${IMAGE_TAG} .

# verify 
docker run --rm 3ipk-executor:latest aws --version
docker run --rm 3ipk-executor:latest helm version
docker run --rm 3ipk-executor:latest skaffold version
docker run --rm 3ipk-executor:latest kubectl version
docker run --rm 3ipk-executor:latest terraform version
docker run --rm 3ipk-executor:latest hcp version
