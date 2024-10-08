ARG DEBIAN_VERSION=12.6-slim
ARG DEBIAN_FRONTEND=noninteractive

FROM debian:${DEBIAN_VERSION} AS builder
ENV TARGETARCH=amd64

# https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst
ARG AWS_CLI_VERSION="2.17.25"

# https://github.com/hashicorp/terraform/releases
# https://releases.hashicorp.com/terraform/
ARG TF_VERSION="1.9.4"

# https://releases.hashicorp.com/hcp/0.4.0/
ARG HCP_VERSION="0.4.0"

# https://github.com/GoogleContainerTools/skaffold/releases
ARG SKAFFOLD_VERSION="v2.13.1"

# https://github.com/helm/helm/releases
ARG HELM_VERSION="v3.15.3"

# latest: https://dl.k8s.io/release/stable.txt
ARG KUBECTL_VERSION="v1.30.3"

# https://releases.hashicorp.com/vault/
ARG VAULT_VERSION="1.17.6"

WORKDIR /workspace
RUN apt-get update
RUN apt-get install --no-install-recommends -y ca-certificates curl unzip

# terraform install
RUN curl --silent --show-error --fail --remote-name "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TARGETARCH}.zip"
RUN unzip -jo terraform_${TF_VERSION}_linux_${TARGETARCH}.zip

# hcp install
RUN curl --silent --show-error --fail --remote-name "https://releases.hashicorp.com/hcp/${HCP_VERSION}/hcp_${HCP_VERSION}_linux_${TARGETARCH}.zip"
RUN unzip -jo hcp_${HCP_VERSION}_linux_${TARGETARCH}.zip

# vault install
RUN curl --silent --show-error --fail --remote-name "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip"
RUN echo vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip
RUN ls -la vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip
RUN unzip -jo vault_${VAULT_VERSION}_linux_${TARGETARCH}.zip

# kubectl
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/kubectl

# scaffold
RUN curl -Lo skaffold "https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-${TARGETARCH}"
RUN chmod +x skaffold

# helm
RUN echo "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN curl --silent --show-error --fail --remote-name "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN tar -zxvf "helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"
RUN mv linux-amd64/helm /workspace/helm

# aws install
RUN curl --show-error --fail --output "awscliv2.zip" --remote-name "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
RUN unzip -u awscliv2.zip
RUN ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin

# Install nvm and Node.js versions
ENV NVM_DIR=/usr/local/nvm
RUN mkdir $NVM_DIR
RUN curl --silent --show-error --fail --remote-name https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh
RUN bash install.sh
RUN . $NVM_DIR/nvm.sh && nvm install 18 && nvm install 20

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
COPY --from=builder /workspace/vault        /usr/local/bin/vault
COPY --from=builder /usr/local/bin          /usr/local/bin/
COPY --from=builder /usr/local/nvm          /usr/local/nvm
ENV NVM_DIR=/usr/local/nvm

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

SHELL ["/bin/bash", "-c"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 nonroot \
    # user needs a home folder to store aws credentials
    && useradd --gid nonroot --create-home --uid 1001 nonroot \
    && chown nonroot:nonroot /workspace
USER nonroot

# # Load nvm and set default Node.js version if needed
RUN echo 'source /usr/local/nvm/nvm.sh && nvm use 18' >> ~/.bashrc

# Ensure that bash is the command invoked
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["bash"]
