FROM mcr.microsoft.com/vscode/devcontainers/python:0-3.10

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
        cmake \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip3 install -r requirements.txt --use-deprecated=legacy-resolver
RUN rm -rf requirements.txt

RUN pip3 install -r requirements_component.txt --use-deprecated=legacy-resolver