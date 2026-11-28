mock_provider "github" {}

variables {
  org_name = "test-org"
  settings = { billing_email = "billing@example.com" }
}

run "no_rulesets_by_default" {
  command = plan

  assert {
    condition     = length(github_organization_ruleset.rulesets) == 0
    error_message = "No organization rulesets should be created by default."
  }
}

run "defaults_target_every_repository" {
  command = plan

  variables {
    rulesets = { protect-default-branches = {} }
  }

  assert {
    condition     = github_organization_ruleset.rulesets["protect-default-branches"].target == "branch" && github_organization_ruleset.rulesets["protect-default-branches"].enforcement == "active"
    error_message = "Org rulesets should default to target = branch and enforcement = active."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["protect-default-branches"].conditions[0].ref_name[0].include == tolist(["~DEFAULT_BRANCH"])
    error_message = "Org rulesets should include the default branch by default."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["protect-default-branches"].conditions[0].repository_name[0].include == tolist(["~ALL"]) && github_organization_ruleset.rulesets["protect-default-branches"].conditions[0].repository_name[0].protected == false
    error_message = "Org rulesets should target every repository by default."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["protect-default-branches"].rules[0].deletion == true && github_organization_ruleset.rulesets["protect-default-branches"].rules[0].non_fast_forward == true
    error_message = "Org rulesets should block deletion and force pushes by default."
  }
}

run "repository_name_and_ref_conditions" {
  command = plan

  variables {
    rulesets = {
      modules = {
        include         = ["refs/heads/main"]
        exclude         = ["refs/heads/legacy"]
        repository_name = { include = ["terraform-*"], exclude = ["terraform-sandbox"], protected = true }
        rules = {
          pull_request           = { required_approving_review_count = 0 }
          required_status_checks = { checks = [{ context = "ci-ok" }] }
        }
      }
    }
  }

  assert {
    condition = (
      github_organization_ruleset.rulesets["modules"].conditions[0].repository_name[0].include == tolist(["terraform-*"]) &&
      github_organization_ruleset.rulesets["modules"].conditions[0].repository_name[0].exclude == tolist(["terraform-sandbox"]) &&
      github_organization_ruleset.rulesets["modules"].conditions[0].repository_name[0].protected == true
    )
    error_message = "repository_name conditions should follow the input."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["modules"].conditions[0].ref_name[0].include == tolist(["refs/heads/main"]) && github_organization_ruleset.rulesets["modules"].conditions[0].ref_name[0].exclude == tolist(["refs/heads/legacy"])
    error_message = "ref_name conditions should follow the input."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["modules"].rules[0].pull_request[0].required_approving_review_count == 0 && length(github_organization_ruleset.rulesets["modules"].rules[0].required_status_checks[0].required_check) == 1
    error_message = "Rules should follow the input."
  }
}

run "repository_id_condition" {
  command = plan

  variables {
    rulesets = { by-id = { repository_id = [123, 456] } }
  }

  assert {
    condition     = github_organization_ruleset.rulesets["by-id"].conditions[0].repository_id == tolist([123, 456]) && length(github_organization_ruleset.rulesets["by-id"].conditions[0].repository_name) == 0
    error_message = "repository_id should replace the default repository_name condition."
  }
}

run "rejects_repository_name_and_id" {
  command = plan

  variables {
    rulesets = {
      bad = {
        repository_name = { include = ["~ALL"] }
        repository_id   = [123]
      }
    }
  }

  expect_failures = [var.rulesets]
}

run "rejects_evaluate_enforcement" {
  command = plan

  variables {
    rulesets = { bad = { enforcement = "evaluate" } }
  }

  expect_failures = [var.rulesets]
}
