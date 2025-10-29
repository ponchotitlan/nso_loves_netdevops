#!/bin/bash -x
# Title: Creation of artifacts with the test results from the service packages
# Description: This script adds to a tar file the files located in the packages/<package>/tests dir of this repository. The netsim folders are ignored. The resulting tar file is stored in the mounted volume /tmp/nso for easier access via the pipeline later on.
# Author: @ponchotitlan
#
# Usage:
#   ./create-artifact-tests.sh

# This function creates a tar file of the folder specified and saves it in the /tmp/nso location
run_robot_test(){
    local service_name="$1"

    source .venv/bin/activate
    robot --outputdir packages/$service_name/tests/ packages/$service_name/tests/$service_name.robot
}

YAML_FILE_CONFIG="config.yaml"
PACKAGES_DIR="packages"
NEDS_PATH=".netsims | keys"
TOKEN_SUCCESS="0 failed"

# Get all the packages folders and remove the trailing slash from their names
all_packages=($(ls -d "$PACKAGES_DIR"/*/ | xargs -n 1 basename))

# Iterate over each folder and check if it's in the excluded list
all_tests_passed=1
for package in "${all_packages[@]}"; do
    test_results=$(run_robot_test $package)

    if echo "$test_results" | grep -q "$TOKEN_SUCCESS"; then
        # This test passed!
        continue
    else
        # This test didn't pass!
        all_tests_passed=0
    fi
done

if [[ $all_tests_passed == 0 ]]; then
    # The job failed
    echo "failed"
else
    # The job is successful
    echo "pass"
fi