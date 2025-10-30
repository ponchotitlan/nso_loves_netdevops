#!/bin/bash -x
# Title: Build Image
# Description: This script builds a custom NSO image with the variables provided in the YAML file config.yaml.
# Usage:
#   ./build-image.sh

set -xe
CONFIG_FILE="config.yaml"
SECRET_FILE="artifact_server_token.txt"

# Manual parsing of the YAML file to extract values
nso_image=$(awk -F': ' '/^nso-image:/ {print $2}' "$CONFIG_FILE")

# Get the artifact_server_token from an environment variable
TRIMMED_SECRET=$(echo "$DOWNLOAD_TOKEN" | xargs)

# Checking of the appropriate secret format
if [[ -z "$TRIMMED_SECRET" ]]; then
    echo "⚠️ Input is empty. No secrets will be used for downloading artifacts ..."
fi

if [[ -n "$TRIMMED_SECRET" && ! "$TRIMMED_SECRET" =~ ^[^:]+:[^:]+$ ]]; then
    echo "🔥 Input is invalid. Expected format ➡️ username:token. Please run this tool again and provide a valid input"
    exit 1
fi

# Creation of the file with the secret. Change of permissions
echo "$TRIMMED_SECRET" > $SECRET_FILE
chmod 600 $SECRET_FILE
set -x

# Docker build with the secret mounted. The resulting image will have the name provided in the config.yaml file
DOCKER_BUILDKIT=1 docker build \
--secret id=artifact_server_token,src=$SECRET_FILE \
-t $nso_image .

# Deletion of the artifact server token file
rm -rf $SECRET_FILE

