#!/usr/bin/env bash

# Stop on errors
set -e

echo "Moving additional container content"
[ -f "/container_content/pylint" ] && { rm -R ./pylint; }
mv -f /container_content/pylint .
mv -f /container_content/pyproject.toml .

echo "Preparing config folder"
mkdir -p /config

FILE=".devcontainer/configuration.yaml"
[ -f $FILE ] && { echo "Linking configuration.yaml"; ln -sfr $FILE /config/configuration.yaml; }
FILE=".devcontainer/secrets.yaml"
[ -f $FILE ] && { echo "Linking secrets.yaml"; ln -sfr $FILE /config/secrets.yaml; }

echo "Linking custom_components"
rm -rf /config/custom_components
ln -sfr custom_components /config/custom_components

# Extract .vscode, pylint, pyproject.toml, setup.cfg
#rsync -a -v --remove-source-files /tmp/container_content/ ./

FILE="requirements_component.txt"
[ -f $FILE ] && { echo "Installing requirements from requirements_component.txt"; pip3 install -r $FILE --use-deprecated=legacy-resolver; }