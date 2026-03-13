FROM python:3.14-trixie

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \ 
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        # Additional library needed by some tests and accordingly by VScode Tests Discovery
        bluez \
        ffmpeg \
        libudev-dev \
        libavformat-dev \
        libavcodec-dev \
        libavdevice-dev \
        libavutil-dev \
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
        autoconf \
        locales \
        locales-all \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Generate the specific locale (e.g., en_US.UTF-8)
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

WORKDIR /tmp

# Install default requirements
COPY my_requirements.txt requirements_all.txt requirements_test_all.txt requirements_test_pre_commit.txt requirements_test.txt requirements.txt ./
COPY homeassistant/package_constraints.txt homeassistant/package_constraints.txt

# Install all, Testing and custom requirements
# requirements_all includes requirements. Just using requirements results in some important packages like home-assistant-frontend to be missing.
RUN pip3 install -r requirements_all.txt -r requirements_test.txt -r my_requirements.txt

# Copy container_content into /workspaces. It will be created if it doesn't exist.
# container_content includes .vscode, pylint, pyproject.toml, etc.
WORKDIR /workspaces
COPY container_content ./container_content

# Ensure setup.sh is executable
USER root
RUN chmod +x ./container_content/scripts/setup.sh

USER vscode

# Set the default shell to bash instead of sh
ENV SHELL=/bin/bash