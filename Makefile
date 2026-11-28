.PHONY: help fmt fmt-check lint validate test docs pre-commit ci release-dry-run clean

# Run with Terraform instead of OpenTofu: make test TOOL=terraform
TOOL    := tofu
MODULES := organization repository repositories
DIRS    := $(MODULES) examples

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

fmt: ## Format all HCL files in place
	$(TOOL) fmt -recursive

fmt-check: ## Check formatting without changing files
	$(TOOL) fmt -recursive -check -diff

lint: ## Run tflint in every module and example
	tflint --init --config=$(CURDIR)/.tflint.hcl
	@set -e; for d in $(DIRS); do echo ">> tflint $$d"; tflint --chdir=$$d --config=$(CURDIR)/.tflint.hcl; done

validate: ## init (no backend) and validate every module and example
	@set -e; for d in $(DIRS); do echo ">> validate $$d"; (cd $$d && $(TOOL) init -backend=false -input=false >/dev/null && $(TOOL) validate); done

test: ## Run native tests (mocked provider) in every module and example
	@set -e; for d in $(DIRS); do echo ">> test $$d"; (cd $$d && $(TOOL) init -backend=false -input=false >/dev/null && $(TOOL) test); done

docs: ## Regenerate module README inputs/outputs with terraform-docs
	@set -e; for d in $(DIRS); do terraform-docs --config=$(CURDIR)/.terraform-docs.yml $$d; done

pre-commit: ## Run all pre-commit hooks against all files
	SKIP=conventional-pre-commit pre-commit run --all-files

ci: pre-commit validate test ## Run what CI runs (OpenTofu leg)

release-dry-run: ## Show the next version semantic-release would publish
	GITHUB_TOKEN=$$(gh auth token) npx semantic-release --dry-run --no-ci --branches $$(git rev-parse --abbrev-ref HEAD)

clean: ## Remove local .terraform directories
	find . -type d -name .terraform -prune -exec rm -rf {} +
