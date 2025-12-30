FROM mcr.microsoft.com/devcontainers/python:1-3.13

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Uninstall pre-installed formatting and linting tools
# They would conflict with our pinned versions
RUN \
    pipx uninstall pydocstyle \
    && pipx uninstall pycodestyle \
    && pipx uninstall mypy \
    && pipx uninstall pylint

RUN \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        # Additional library needed by some tests and accordingly by VScode Tests Discovery
        bluez \
        ffmpeg \
        libudev-dev \
        libavformat-dev \
        libavcodec-dev \
        libavdevice-dev \
        libavutil-dev \
        libgammu-dev \
        libswscale-dev \
        libswresample-dev \
        libavfilter-dev \
        libpcap-dev \
        libturbojpeg0 \
        libyaml-dev \
        libxml2 \
        gh \
        git \
        cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip3 install uv

WORKDIR /tmp

# Install default requirements
COPY requirements.txt requirements_test.txt requirements_test_all.txt requirements_test_pre_commit.txt my_requirements.txt ./
COPY homeassistant/package_constraints.txt homeassistant/package_constraints.txt

# Core requirements
RUN pip3 install -r requirements.txt

# Testing requirements
RUN pip3 install -r requirements_test.txt

# Custom requirements
RUN pip3 install -r my_requirements.txt

# Copy container_content into /workspaces. It will be created if it doesn't exist.
# container_content includes .vscode, pylint, pyproject.toml, etc.
WORKDIR /workspaces
COPY container_content ./container_content

# Ensure setup.sh is executable
USER root
RUN chmod +x ./container_content/scripts/setup.sh

USER vscode

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash