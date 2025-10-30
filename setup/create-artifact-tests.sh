#!/bin/bash -x
# Title: Creation of artifacts with the test results from the service packages
# Description: This script adds to a tar file the files located in the packages/<package>/tests dir of this repository. The netsim folders are ignored. The resulting tar file is stored in the mounted volume /tmp/nso for easier access via the pipeline later on.
# Author: @ponchotitlan
#
# Usage:
#   ./create-artifact-tests.sh <service-name>

# This function creates a tar file of the folder specified and saves it in the /tmp/nso location
# Usage tar_folders_test <container_name(str)> <package_folder_names(array(str))>
tar_folders_test(){
    local container_name="$1"
    local tests_array="$2"

    docker exec -i $container_name bash -lc "cd /nso/run/packages/ && tar -czvf /tmp/nso/demo_test.tar.gz ${tests_array[@]}"
}

# This function creates a tar file of the NSO logs currently in the container
# Usage tar_logs <container_name(str)>
tar_logs(){
    local container_name="$1"
    docker exec -i $container_name bash -lc "tar -czvf /tmp/nso/demo_logs.tar.gz /log"
}

# This function creates a tar file with all the xml files from the preconfigs
tar_preconfigs(){
    find "preconfigs/" -type f -name "*.xml" -print0 | tar --null -cvf "preconfigs/demo_preconfigs.tar.gz" --files-from=-
}

YAML_FILE_CONFIG="config.yaml"
PACKAGES_DIR="packages"

echo "##### [📦] Zipping the results into an artifact.... #####"

# Get the name of the NSO container from the config.yaml file
nso_container_name=$(awk -F': ' '/^nso-name:/ {print $2}' "$YAML_FILE_CONFIG")

# Get all the packages folders and remove the trailing slash from their names
all_packages=($(ls -d "$PACKAGES_DIR"/*/ | xargs -n 1 basename))

service_tests=()
# Iterate over each folder and check if it's in the excluded list
for package in "${all_packages[@]}"; do
    service_tests+=("${package}/tests")
done

tar_preconfigs
tar_folders_test $nso_container_name ${service_tests[@]}
tar_logs $nso_container_name

echo "[📦] Creation of the artifact done!"