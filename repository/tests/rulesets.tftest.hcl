mock_provider "github" {}

variables {
  repository_name = "test-repo"
}

run "no_rulesets_by_default" {
  command = plan

  assert {
    condition     = length(github_repository_ruleset.this) == 0
    error_message = "No rulesets should be created when rulesets is empty."
  }
}

run "ruleset_defaults" {
  command = plan

  variables {
    rulesets = {
      protect-default-branch = {}
    }
  }

  assert {
    condition     = github_repository_ruleset.this["protect-default-branch"].name == "protect-default-branch" && github_repository_ruleset.this["protect-default-branch"].repository == "test-repo"
    error_message = "The ruleset should be named after its key and attached to the repository."
  }

  assert {
    condition     = github_repository_ruleset.this["protect-default-branch"].target == "branch" && github_repository_ruleset.this["protect-default-branch"].enforcement == "active"
    error_message = "Rulesets should default to target = branch and enforcement = active."
  }

  assert {
    condition     = github_repository_ruleset.this["protect-default-branch"].conditions[0].ref_name[0].include == tolist(["~DEFAULT_BRANCH"]) && length(github_repository_ruleset.this["protect-default-branch"].conditions[0].ref_name[0].exclude) == 0
    error_message = "Branch rulesets should include the default branch by default."
  }

  assert {
    condition     = github_repository_ruleset.this["protect-default-branch"].rules[0].deletion == true && github_repository_ruleset.this["protect-default-branch"].rules[0].non_fast_forward == true
    error_message = "Rulesets should block deletion and force pushes by default."
  }

  assert {
    condition     = length(github_repository_ruleset.this["protect-default-branch"].rules[0].pull_request) == 0 && length(github_repository_ruleset.this["protect-default-branch"].rules[0].required_status_checks) == 0
    error_message = "pull_request and required_status_checks should only be rendered when set."
  }

  assert {
    condition     = length(github_repository_ruleset.this["protect-default-branch"].bypass_actors) == 0
    error_message = "There should be no bypass actors by default."
  }
}

run "tag_ruleset_includes_all_tags" {
  command = plan

  variables {
    rulesets = {
      protect-tags = {
        target = "tag"
        rules  = { update = true }
      }
    }
  }

  assert {
    condition     = github_repository_ruleset.this["protect-tags"].target == "tag" && github_repository_ruleset.this["protect-tags"].conditions[0].ref_name[0].include == tolist(["~ALL"])
    error_message = "Tag rulesets should include all tags by default."
  }

  assert {
    condition     = github_repository_ruleset.this["protect-tags"].rules[0].update == true
    error_message = "Rules should follow the input."
  }
}

run "pull_request_status_checks_and_bypass" {
  command = plan

  variables {
    rulesets = {
      main = {
        include = ["refs/heads/main"]
        exclude = ["refs/heads/main-old"]
        bypass_actors = [
          { actor_type = "Integration", actor_id = 12345 },
          { actor_type = "OrganizationAdmin", bypass_mode = "pull_request" },
        ]
        rules = {
          required_linear_history = true
          pull_request = {
            required_approving_review_count = 2
            allowed_merge_methods           = ["squash"]
          }
          required_status_checks = {
            strict = true
            checks = [
              { context = "ci-ok", integration_id = 15368 },
              { context = "Conventional PR title" },
            ]
          }
        }
      }
    }
  }

  assert {
    condition     = github_repository_ruleset.this["main"].conditions[0].ref_name[0].include == tolist(["refs/heads/main"]) && github_repository_ruleset.this["main"].conditions[0].ref_name[0].exclude == tolist(["refs/heads/main-old"])
    error_message = "include and exclude should follow the input."
  }

  assert {
    condition     = github_repository_ruleset.this["main"].bypass_actors[0].actor_type == "Integration" && github_repository_ruleset.this["main"].bypass_actors[0].actor_id == 12345 && github_repository_ruleset.this["main"].bypass_actors[0].bypass_mode == "always"
    error_message = "Bypass actors should be rendered, with bypass_mode defaulting to always."
  }

  assert {
    condition     = github_repository_ruleset.this["main"].bypass_actors[1].bypass_mode == "pull_request"
    error_message = "bypass_mode should follow the input."
  }

  assert {
    condition     = github_repository_ruleset.this["main"].rules[0].required_linear_history == true
    error_message = "required_linear_history should follow the input."
  }

  assert {
    condition = (
      github_repository_ruleset.this["main"].rules[0].pull_request[0].required_approving_review_count == 2 &&
      github_repository_ruleset.this["main"].rules[0].pull_request[0].dismiss_stale_reviews_on_push == true &&
      github_repository_ruleset.this["main"].rules[0].pull_request[0].required_review_thread_resolution == true &&
      github_repository_ruleset.this["main"].rules[0].pull_request[0].allowed_merge_methods == tolist(["squash"])
    )
    error_message = "The pull_request rule should follow the input and its defaults."
  }

  assert {
    condition     = github_repository_ruleset.this["main"].rules[0].required_status_checks[0].strict_required_status_checks_policy == true && length(github_repository_ruleset.this["main"].rules[0].required_status_checks[0].required_check) == 2
    error_message = "required_status_checks should render one required_check per check."
  }

  assert {
    condition     = contains([for c in github_repository_ruleset.this["main"].rules[0].required_status_checks[0].required_check : "${c.context}/${coalesce(c.integration_id, 0)}"], "ci-ok/15368")
    error_message = "Required checks should keep their integration_id."
  }
}

run "null_ruleset_is_ignored" {
  command = plan

  variables {
    rulesets = {
      kept    = {}
      removed = null
    }
  }

  assert {
    condition     = keys(github_repository_ruleset.this) == ["kept"]
    error_message = "A null ruleset should not be created."
  }
}

run "rejects_evaluate_enforcement" {
  command = plan

  variables {
    rulesets = { bad = { enforcement = "evaluate" } }
  }

  expect_failures = [var.rulesets]
}

run "rejects_unknown_enforcement" {
  command = plan

  variables {
    rulesets = { bad = { enforcement = "on" } }
  }

  expect_failures = [var.rulesets]
}

run "rejects_push_target" {
  command = plan

  variables {
    rulesets = { bad = { target = "push", include = ["~DEFAULT_BRANCH"] } }
  }

  expect_failures = [var.rulesets]
}

run "rejects_unknown_actor_type" {
  command = plan

  variables {
    rulesets = { bad = { bypass_actors = [{ actor_type = "Robot", actor_id = 1 }] } }
  }

  expect_failures = [var.rulesets]
}

run "rejects_unknown_bypass_mode" {
  command = plan

  variables {
    rulesets = { bad = { bypass_actors = [{ actor_type = "Integration", actor_id = 1, bypass_mode = "sometimes" }] } }
  }

  expect_failures = [var.rulesets]
}

run "rejects_empty_status_checks" {
  command = plan

  variables {
    rulesets = { bad = { rules = { required_status_checks = { checks = [] } } } }
  }

  expect_failures = [var.rulesets]
}
