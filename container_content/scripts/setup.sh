#!/usr/bin/env bash

# Stop on errors
set -e

function ensure_hass_config() {
    echo "Preparing config folder"
    mkdir -p config
    hass --script ensure_config -c config 

    echo "Creating Home Assistant User"
    hass --script auth -c config add test test

    echo "Skipping onboarding"
    cp -f /workspaces/container_content/onboarding config/.storage
}

function copy_dev_content() {
    echo "Copying pylint folder"
    if [ -f "pylint" ]; then
        rm -R pylint
    fi
    cp -rf /workspaces/container_content/pylint .

    echo "Copying pyproject.toml"
    cp -f /workspaces/container_content/pyproject.toml .

    echo "Copying .pre-commit-config.yaml"
    cp -f /workspaces/container_content/.pre-commit-config.yaml .

    echo "Preparing .vscode folder"
    if [ -f ".vscode" ]; then
        rm -R .vscode
    fi
    cp -rf /workspaces/container_content/.vscode .
}

function copy_configuration_overrides() {
    if [ -f ".devcontainer/configuration.yaml" ]; then
        echo "Linking configuration.yaml"
        ln -sfr ".devcontainer/configuration.yaml" config/configuration.yaml
    fi

    if [ -f ".devcontainer/secrets.yaml" ]; then
        echo "Linking secrets.yaml"
        ln -sfr ".devcontainer/secrets.yaml" config/secrets.yaml
    fi
}

ensure_hass_config
copy_dev_content
copy_configuration_overrides


echo "Linking custom_components"
rm -rf config/custom_components
#Don't use r which makes nested folders when script is re-ran
ln -s custom_components config/custom_components

# Extract .vscode, pylint, pyproject.toml, setup.cfg
#rsync -a -v --remove-source-files /tmp/container_content/ ./

if [ -f "requirements_component.txt" ]; then
    echo "Installing requirements from requirements_component.txt"
    pip3 install -r "requirements_component.txt"
fi
