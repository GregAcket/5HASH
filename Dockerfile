ARG TERRAFORM_VERSION=1.16.3
FROM hashicorp/terraform:${TERRAFORM_VERSION} AS terraform

FROM python:3.12-slim
ARG ANSIBLE_CORE_VERSION=2.18.19
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-client git \
 && rm -rf /var/lib/apt/lists/*
COPY --from=terraform /bin/terraform /usr/local/bin/terraform
RUN pip install --no-cache-dir "ansible-core==${ANSIBLE_CORE_VERSION}"
WORKDIR /work
