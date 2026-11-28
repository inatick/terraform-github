mock_provider "github" {}

override_data {
  target = data.github_organization.this
  values = {
    plan = "team"
  }
}

variables {
  owner            = "test-org"
  default_profiles = ["base"]

  profiles = {
    base = {
      settings = {
        delete_branch_on_merge = true
        allow_update_branch    = true
        has_wiki               = false
      }
      rulesets = {
        protect-default-branch = {
          rules = { pull_request = { required_approving_review_count = 1 } }
        }
      }
    }
    ci-gated = {
      # Leaves every setting unset: it must not reset what base set.
      rulesets = {
        protect-default-branch = {
          rules = {
            pull_request           = { required_approving_review_count = 2 }
            required_status_checks = { checks = [{ context = "ci-ok" }] }
          }
        }
      }
    }
    public-module = {
      settings = {
        is_private         = false
        has_wiki           = true
        allow_squash_merge = true
      }
    }
    wiki-off = {
      settings = { has_wiki = false }
    }
  }

  repositories = {
    module-repo = {
      description = "A public module"
      profiles    = ["ci-gated", "public-module"]
    }
    app = {
      description = "An application"
      settings    = { has_wiki = true, delete_branch_on_merge = false }
      rulesets    = { protect-default-branch = null }
    }
    ordered = {
      profiles = ["public-module", "wiki-off"]
    }
    private-app = {}
  }
}

run "default_profiles_apply_to_every_repo" {
  command = plan

  assert {
    condition     = alltrue([for r in output.resolved : r.profiles[0] == "base"])
    error_message = "Default profiles should be applied first to every repository."
  }

  assert {
    condition     = output.resolved["ordered"].settings.allow_update_branch == true && output.resolved["module-repo"].settings.allow_update_branch == true
    error_message = "Settings from default profiles should reach every repository."
  }
}

run "later_layers_win" {
  command = plan

  assert {
    condition     = output.resolved["ordered"].settings.has_wiki == false
    error_message = "A later profile should override an earlier one."
  }

  assert {
    condition     = output.resolved["app"].settings.has_wiki == true && output.resolved["app"].settings.delete_branch_on_merge == false
    error_message = "A repository's own settings should override every profile."
  }

  assert {
    condition     = output.resolved["app"].description == "An application"
    error_message = "The description should follow the input."
  }
}

run "unset_settings_do_not_reset_earlier_layers" {
  command = plan

  assert {
    condition     = output.resolved["module-repo"].settings.delete_branch_on_merge == true
    error_message = "A profile that leaves a setting unset must not reset a value set by an earlier profile."
  }

  assert {
    condition     = output.resolved["module-repo"].settings.is_private == false && output.resolved["module-repo"].settings.has_wiki == true
    error_message = "Settings from the repository's profiles should be applied."
  }

  assert {
    condition     = !contains(keys(output.resolved["app"].settings), "is_private")
    error_message = "Settings no layer sets should be left out, so the repository module default applies."
  }
}

run "rulesets_replace_whole_and_null_removes" {
  command = plan

  assert {
    condition     = output.resolved["module-repo"].rulesets["protect-default-branch"].rules.pull_request.required_approving_review_count == 2 && output.resolved["module-repo"].rulesets["protect-default-branch"].rules.required_status_checks.checks[0].context == "ci-ok"
    error_message = "A ruleset with the same name in a later profile should replace the earlier ruleset."
  }

  assert {
    condition     = length(output.resolved["app"].rulesets) == 0
    error_message = "Setting a ruleset to null should remove the inherited ruleset."
  }

  assert {
    condition     = keys(output.resolved["ordered"].rulesets) == ["protect-default-branch"] && output.resolved["ordered"].rulesets["protect-default-branch"].rules.pull_request.required_approving_review_count == 1
    error_message = "Repositories should inherit rulesets from default profiles."
  }

  assert {
    condition     = keys(output.repositories["module-repo"].ruleset_ids) == ["protect-default-branch"] && length(output.repositories["app"].ruleset_ids) == 0
    error_message = "Rulesets should be created from the resolved configuration."
  }
}

run "repositories_are_named_after_their_keys" {
  command = plan

  assert {
    condition     = toset([for r in output.repositories : r.name]) == toset(["module-repo", "app", "ordered", "private-app"])
    error_message = "One repository should be created per entry, named after its key."
  }
}

run "rejects_unknown_profile" {
  command = plan

  variables {
    repositories = {
      typo = { profiles = ["ci-gatd"] }
    }
  }

  expect_failures = [data.github_organization.this]
}

run "rejects_unknown_default_profile" {
  command = plan

  variables {
    default_profiles = ["missing"]
  }

  expect_failures = [data.github_organization.this]
}

run "team_plan_keeps_rulesets" {
  command = plan

  assert {
    condition     = length(output.skipped_rulesets) == 0 && length(output.repositories["private-app"].ruleset_ids) == 1
    error_message = "On a paid plan, private repositories should keep their rulesets."
  }
}

run "rejects_bad_on_unsupported_rulesets" {
  command = plan

  variables {
    on_unsupported_rulesets = "ignore"
  }

  expect_failures = [var.on_unsupported_rulesets]
}
