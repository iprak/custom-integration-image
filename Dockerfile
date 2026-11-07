FROM python:3.14-trixie

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install uv for ultra-fast dependency resolution and wheel caching
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gh \
        git \
        cmake \
        nodejs \
        npm \
        locales \
        autoconf \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        libjpeg-dev \
        libffi-dev \
        libudev-dev \
        zlib1g-dev \
        pkg-config \
        libavformat-dev \
        libavcodec-dev \
        libavdevice-dev \
        libavutil-dev \
        libswscale-dev \
        libswresample-dev \
        libavfilter-dev \
        ffmpeg \
        libgammu-dev \
        build-essential \
        libturbojpeg0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Generate the specific locale (en_US.UTF-8)
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

WORKDIR /tmp

# Install default requirements
COPY my_requirements.txt requirements_all.txt requirements_test_pre_commit.txt requirements_test.txt requirements.txt ./
COPY homeassistant/package_constraints.txt homeassistant/package_constraints.txt

# Install test and custom requirements using uv with a persistent BuildKit cache mount
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system --no-cache \
        -c homeassistant/package_constraints.txt \
        -r my_requirements.txt \
        -r requirements_all.txt \
        -r requirements_test.txt

# Copy container_content into /workspaces
WORKDIR /workspaces
COPY container_content ./container_content

# Ensure setup.sh is executable (run as root before dropping privileges)
USER root
RUN chmod +x ./container_content/scripts/setup.sh

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user and group with home directory permissions and sudo support
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Switch to the non-root user
USER $USERNAME

# Set the default shell to bash
ENV SHELL=/bin/bash