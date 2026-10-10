FROM python:3.14-trixie

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \ 
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        # Additional library needed by some tests and accordingly by VScode Tests Discovery
        gh \
        git \
        cmake \
        nodejs \
        npm \
        locales \
        locales-all \
        autoconf libssl-dev libxml2-dev libxslt1-dev libjpeg-dev libffi-dev libudev-dev zlib1g-dev pkg-config libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libswscale-dev libswresample-dev libavfilter-dev ffmpeg libgammu-dev build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Generate the specific locale (e.g., en_US.UTF-8)
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

WORKDIR /tmp

# Install default requirements
COPY my_requirements.txt requirements_test_pre_commit.txt requirements_test.txt requirements.txt ./
COPY homeassistant/package_constraints.txt homeassistant/package_constraints.txt

# Install all, Testing and custom requirements
# Just using requirements results in some important packages like home-assistant-frontend to be missing.
RUN pip3 install --no-cache-dir -r requirements.txt -r requirements_test.txt  -r my_requirements.txt


# Copy container_content into /workspaces. It will be created if it doesn't exist.
# container_content includes .vscode, pylint, pyproject.toml, etc.
WORKDIR /workspaces
COPY container_content ./container_content

# Ensure setup.sh is executable
USER root
RUN chmod +x ./container_content/scripts/setup.sh

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user and group with home directory permissions
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support so you can install packages later
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Tell Docker to switch to this user for remaining build commands
#USER $USERNAME

# Set the default shell to bash instead of sh
ENV SHELL=/bin/bash