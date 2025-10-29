#!/bin/bash -x
# Title: Creation of artifacts with the service packages
# Description: This script adds to a tar file the service packages located in the packages/ dir of this repository. The netsim folders are ignored. The resulting tar file is stored in the mounted volume /tmp/nso for easier access via the pipeline later on.
# Author: @ponchotitlan
#
# Usage:
#   ./create-artifact-packages.sh <service-name>

# This function creates a tar file of the folder specified and saves it in the /tmp/nso location
# Usage tar_folders <container_name(str)> <package_folder_names(array(str))>
tar_folders(){
    local container_name="$1"
    local packages_array="$@"
    local ARTIFACT_NAME="demo_packages.tar.gz"
    local ARTIFACT_DIR="/tmp/nso"

    docker exec -i $container_name bash -lc "cd /nso/run/packages/ && tar -czvf $ARTIFACT_DIR/$ARTIFACT_NAME ${packages_array[@]}"
}

YAML_FILE_CONFIG="config.yaml"
PACKAGES_DIR="packages"

echo "##### [📦] Zipping the compiled packages into an artifact.... #####"

# Get the name of the NSO container from the config.yaml file
nso_container_name=$(awk -F': ' '/^nso-name:/ {print $2}' "$YAML_FILE_CONFIG")

# Get all the packages folders and remove the trailing slash from their names
all_packages=($(ls -d "$PACKAGES_DIR"/*/ | xargs -n 1 basename))

tar_folders $nso_container_name ${all_packages[@]}

echo "[📦] Creation of the artifact demo_packages.tar.gz done!"