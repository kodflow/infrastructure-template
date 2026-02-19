# infrastructure-template

.DEFAULT_GOAL := help

# Terragrunt
init: ## Initialize Terraform + Terragrunt
	terragrunt init --terragrunt-working-dir stacks/

plan: ## Plan all stacks
	terragrunt run-all plan --terragrunt-working-dir stacks/

apply: ## Apply all stacks
	terragrunt run-all apply --terragrunt-working-dir stacks/

destroy: ## Destroy all stacks (requires confirmation)
	terragrunt run-all destroy --terragrunt-working-dir stacks/

# Validation
validate: ## Validate Terraform + Ansible syntax
	terragrunt run-all validate --terragrunt-working-dir stacks/
	ansible-playbook --syntax-check ansible/playbooks/*.yml

lint: ## Lint Terraform + Ansible
	tflint --recursive --config .tflint.hcl
	ansible-lint ansible/

fmt: ## Format Terraform files
	terraform fmt -recursive modules/
	terraform fmt -recursive stacks/

# Tests
test: test-tf test-ansible ## Run all tests

test-tf: ## Run Terratest
	cd tests/terratest && go test -v -timeout 30m ./...

test-ansible: ## Run Molecule tests
	cd tests/molecule && molecule test

# Operations
drift: ## Detect infrastructure drift
	terragrunt run-all plan -detailed-exitcode --terragrunt-working-dir stacks/ || echo "DRIFT DETECTED"

cost: ## Estimate infrastructure cost
	infracost breakdown --path stacks/

cost-diff: ## Compare cost with current
	infracost diff --path stacks/

# Secrets
vault-status: ## Check Vault status
	vault status

vault-login: ## Login to Vault
	vault login -method=token

# Ansible
configure: ## Run Ansible playbooks
	ansible-playbook -i inventory/ansible/hosts.yml ansible/playbooks/site.yml

configure-check: ## Dry-run Ansible
	ansible-playbook -i inventory/ansible/hosts.yml ansible/playbooks/site.yml --check --diff

# Packer
image: ## Build machine images
	packer build packer/

image-validate: ## Validate Packer templates
	packer validate packer/

# Utilities
clean: ## Clean temporary files
	rm -rf .terragrunt-cache/
	rm -rf stacks/**/.terragrunt-cache/
	rm -rf tests/terratest/.test-data/

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: init plan apply destroy validate lint fmt test test-tf test-ansible drift cost cost-diff vault-status vault-login configure configure-check image image-validate clean help
