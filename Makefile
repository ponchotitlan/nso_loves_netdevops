.PHONY: lint-inventory run-nso-node load-neds load-packages prepare-test-network run-tests create-artifact-packages create-artifact-tests get-current-release-tag calculate-new-release-tag clean

lint-inventory:
	@pipeline/scripts/lint-inventory.sh inventory/bgp-inventory.yaml

run-nso-node:
	@pipeline/scripts/run-nso-node.sh

load-neds:
	@pipeline/scripts/download-neds.sh
	@pipeline/scripts/packages-reload.sh nso_node

load-packages:
	@pipeline/scripts/compile-packages.sh nso_node
	@pipeline/scripts/packages-reload.sh nso_node

prepare-test-network:
	@pipeline/scripts/load-preconfigs.sh nso_node
	@pipeline/scripts/load-netsims.sh nso_node

run-tests:
	@pipeline/scripts/install-testing-libraries.sh nso_node
	@pipeline/scripts/generate-inventory-payload.sh inventory/bgp-inventory.yaml services/devopsproeu-bgp/tests/bgp-inventory.json
	status=$$(pipeline/scripts/run-robot-tests.sh); \
	if [ "$$status" = "failed" ]; then \
		echo "🤖❌ At least one test failed!"; \
		exit 1; \
	else \
		echo "🤖✅ All tests were successful!"; \
	fi

create-artifact-packages:
	@pipeline/scripts/create-artifact-packages.sh nso_node

create-artifact-tests:
	@pipeline/scripts/create-artifact-tests.sh nso_node

get-current-release-tag:
	@pipeline/scripts/get-latest-git-tag.sh

calculate-new-release-tag:
	@pipeline/scripts/increment-git-tag-version.sh $(VERSION)

clean:
	@pipeline/scripts/clean-resources.sh