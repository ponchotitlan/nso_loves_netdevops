#!/bin/bash -x
# Title: Clean resources
# Description: This script brings down the associated resources to all the services in the docker-compose file
# Author: @ponchotitlan
#
# Usage:
#   ./clean-resouces.sh

echo "##### [🧹] Bringing all staging services down .... #####"

# Stop all the services of the docker-compose file
docker compose -f docker-compose.yml down

# Remove all the files mounted in the mounted volume pipeline/conf except for the file ncs.conf
rm -rf ncs/ssh/
rm -rf ncs/ssl/
rm -rf ncs/ncs.crypto_keys

echo "[🧹] Clean sweep done!"