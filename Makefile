.PHONY: all render register build run up compile reload netsims down

# Makefile for building, creating and cleaning
# the NSO and CXTA containers for this development environment.

# Requirements:
# 1. Docker and Docker Compose installed and running.
# 2. BuildKit enabled (usually default in recent Docker versions, or set DOCKER_BUILDKIT=1).
# 3. A 'docker-compose.yml' file defining the services for NSO and CXTA, plus the runtime secrets.
# 4. A 'Dockerfile' for the NSO custom image, configured to use BuildKit's

# Target to lint the inventory file
lint:
	./setup/lint-inventory.sh inventory/bgp-inventory.yaml

# Target to render the templates in this repository (*j2 files) with the information from config.yaml
render:
	@echo "--- ✨ Rendering templates ---"
	./setup/render-templates.sh

# Target to mount a local Docker registry on localhost:5000 for your NSO container image,
# in case it comes from a clean `docker loads` and it is not hosted in a registry
register:
	@echo "--- 📤 Mounting local registry (if needed) ---"
	./setup/mount-registry-server.sh

# Target to build the Docker image with secrets
# The Dockerfile in the repository is used for this
# The Docker BuildKit is used for best security practices - The secrets are not recorded in the layers history
build:
	@echo "--- 🏗️ Building NSO custom image with BuildKit secrets ---"
	./setup/build-image.sh

# Target to run the docker compose services with healthcheck
# We don't know how long the NSO container is going to take to become healthy.
# as it depends on the artifacts and NEDs from the custom image.
# Therefore, we are using a script instead of a fixed timed.
run:
	@echo "--- 🚀 Starting Docker Compose services ---"
	./setup/run-services.sh

# Target to run the `packages reload` command in the CLI
# of the NSO container
compile:
	@echo "--- 🛠️ Compiling your services ---"
	./setup/compile-packages.sh

# Target to run the `packages reload` command in the CLI
# of the NSO container
reload:
	@echo "--- 🔀 Reloading the services ---"
	./setup/packages-reload.sh

# Target to create and onboard the netsim devices
# in the NSO container
netsims:
	@echo "--- ⬇️ Loading preconfiguration files ---"
	./setup/load-preconfigs.sh
	@echo "--- 🛸 Loading netsims ---"
	./setup/load-netsims.sh
	@echo "--- ⬇️ Loading preconfiguration files again (for device-targeted configs)---"
	./setup/load-preconfigs.sh

# Target for installation of testing libraries in a python venv in the worker node.
# Rendering of the JSON payload based on the inventory file.
# Running of the Robot tests in each package.
test:
	./setup/install-testing-libraries.sh
	./setup/generate-inventory-payload.sh inventory/bgp-inventory.yaml packages/devopsproeu-bgp/tests/bgp-inventory.json
	status=$$(./setup/run-robot-tests.sh); \
	if [ "$$status" = "failed" ]; then \
		echo "🤖❌ At least one test failed!"; \
		exit 1; \
	else \
		echo "🤖✅ All tests were successful!"; \
	fi

# Target for creation of artifacts - packages, test results and NSO logs
artifacts:
	./setup/create-artifact-packages.sh
	./setup/create-artifact-tests.sh

# Target to get the current release tag
get-current-release-tag:
	@pipeline/scripts/get-latest-git-tag.sh

# Target to calculate the new release tag
calculate-new-release-tag:
	@pipeline/scripts/increment-git-tag-version.sh $(VERSION)

# Target to stop Docker Compose services
down:
	@echo "--- 🛑 Stopping Docker Compose services ---"
	./setup/clean-resources.sh