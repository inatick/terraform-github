# Smoke test: the example configuration plans end to end against a mocked
# provider, using the values in terraform.tfvars.
mock_provider "github" {}

run "example_plans" {
  command = plan

  assert {
    condition     = length(module.repos) == 1 && length(module.branch_protection) == 1 && length(module.org) == 1
    error_message = "The example should create one repository, one branch protection rule and one organization configuration."
  }
}
