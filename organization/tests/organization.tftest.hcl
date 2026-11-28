mock_provider "github" {}

variables {
  org_name = "test-org"
  settings = {
    billing_email = "billing@example.com"
    company       = "Example Ltd"
  }
  teams = {
    engineering = {
      description = "Engineering"
      members     = ["alice", "bob"]
    }
    product = {
      members = ["charlie"]
    }
  }
  organization_rulesets = {
    protect-main = {
      name         = "Protect main"
      target       = "branch"
      entity_ids   = []
      rules_config = {}
    }
  }
}

run "settings_are_passed_through" {
  command = plan

  assert {
    condition     = github_organization_settings.this.billing_email == "billing@example.com" && github_organization_settings.this.company == "Example Ltd"
    error_message = "Organization settings should follow the input."
  }
}

run "teams_and_memberships_fan_out" {
  command = plan

  assert {
    condition     = length(github_team.this) == 2
    error_message = "One team should be created per teams entry."
  }

  assert {
    condition     = toset(keys(github_team_membership.this)) == toset(["engineering-alice", "engineering-bob", "product-charlie"])
    error_message = "One membership should be created per team member, keyed team-member."
  }

  assert {
    condition     = alltrue([for m in github_team_membership.this : m.role == "member"])
    error_message = "Memberships should use the member role."
  }

  assert {
    condition     = github_team.this["product"].description == "A description of the team"
    error_message = "Teams without a description should get the default description."
  }
}

run "rulesets_are_active" {
  command = plan

  assert {
    condition     = github_organization_ruleset.this["protect-main"].name == "Protect main" && github_organization_ruleset.this["protect-main"].target == "branch"
    error_message = "Ruleset name and target should follow the input."
  }

  assert {
    condition     = github_organization_ruleset.this["protect-main"].enforcement == "active"
    error_message = "Rulesets should be actively enforced."
  }
}

run "rejects_invalid_org_name" {
  command = plan

  variables {
    org_name = "bad org!"
  }

  expect_failures = [
    var.org_name,
  ]
}
