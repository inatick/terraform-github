# Smoke test: the example configuration plans end to end against a mocked
# provider, using the values in terraform.tfvars.
mock_provider "github" {}

run "example_plans" {
  command = plan

  assert {
    condition     = length(module.repos.repositories) == 3 && length(module.org) == 1
    error_message = "The example should create three repositories and one organization configuration."
  }

  assert {
    condition     = length(module.repos.repositories["terraform-modules"].ruleset_ids) == 1 && length(module.repos.repositories["my-app"].ruleset_ids) == 0
    error_message = "The public module repository should get its ruleset, and my-app should opt out."
  }

  assert {
    condition     = length(module.org["default"].ruleset_ids) == 0
    error_message = "Organization rulesets should be off unless enable_org_rulesets is true."
  }
}

run "free_plan_skips_private_rulesets" {
  command = plan

  override_data {
    target = module.repos.data.github_organization.this
    values = { plan = "free" }
  }

  assert {
    condition     = module.repos.skipped_rulesets == tolist(["internal-tools"])
    error_message = "On GitHub Free with skip, only the private repository with rulesets should lose them."
  }
}

run "org_rulesets_when_enabled" {
  command = plan

  variables {
    enable_org_rulesets = true
  }

  assert {
    condition     = keys(module.org["default"].ruleset_ids) == ["protect-default-branches"]
    error_message = "Organization rulesets should be created when enable_org_rulesets is true."
  }
}
