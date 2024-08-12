ARG DEBIAN_VERSION=12.6-slim
ARG DEBIAN_FRONTEND=noninteractive

FROM debian:${DEBIAN_VERSION} AS builder
ARG TARGETARCH=amd64

WORKDIR /workspace
RUN apt-get update
RUN apt-get install --no-install-recommends -y ca-certificates curl unzip

# terraform install
ARG TERRAFORM_VERSION
RUN curl --silent --show-error --fail --remote-name "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip"
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip

# hcp install
ARG HCP_VERSION
RUN curl --silent --show-error --fail --remote-name "https://releases.hashicorp.com/hcp/${HCP_VERSION}/hcp_${HCP_VERSION}_linux_${TARGETARCH}.zip"
RUN unzip -j hcp_${HCP_VERSION}_linux_${TARGETARCH}.zip

# kubectl
ARG KUBECTL_VERSION
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/kubectl

# scaffold
ARG SKAFFOLD_VERSION
RUN curl -Lo skaffold "https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-${TARGETARCH}"
RUN chmod +x skaffold

# helm
ARG HELM_VERSION
RUN echo "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN curl --silent --show-error --fail --remote-name "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN tar -zxvf "helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN mv linux-amd64/helm /workspace/helm

# aws install
ARG AWS_CLI_VERSION
RUN curl --show-error --fail --output "awscliv2.zip" --remote-name "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
RUN unzip -u awscliv2.zip
RUN ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin

# Build final image
FROM debian:${DEBIAN_VERSION} AS final
WORKDIR /workspace

RUN apt update \
  && apt install --no-install-recommends -y \
    ca-certificates \
    git \
    jq \
    yq \
    curl \
    unzip \
    openssh-server


COPY --from=builder /workspace/terraform    /usr/local/bin/terraform
COPY --from=builder /workspace/hcp          /usr/local/bin/hcp
COPY --from=builder /usr/local/kubectl      /usr/local/bin/kubectl
COPY --from=builder /workspace/skaffold     /usr/local/bin/skaffold
COPY --from=builder /workspace/helm         /usr/local/bin/helm
COPY --from=builder /usr/local/aws-cli      /usr/local/aws-cli
COPY --from=builder /usr/local/bin          /usr/local/bin/

# clear 
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store aws credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && chown nonroot:nonroot /workspace
USER nonroot

CMD ["bash"]
