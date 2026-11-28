owner = "my-org"

# Applied to every repository first.
default_profiles = ["base"]

profiles = {
  base = {
    settings = {
      delete_branch_on_merge = true
      allow_update_branch    = true
    }
    rulesets = {
      protect-default-branch = {
        rules = {
          pull_request = { required_approving_review_count = 1 }
        }
      }
    }
  }

  # Public module repositories: CI must pass before merging.
  public-module = {
    settings = {
      is_private      = false
      has_discussions = true
    }
    rulesets = {
      # Same name as in base, so this replaces it as a whole.
      protect-default-branch = {
        rules = {
          required_linear_history = true
          pull_request = {
            required_approving_review_count = 0
            allowed_merge_methods           = ["squash"]
          }
          required_status_checks = {
            # 15368 is the GitHub Actions app, so only checks reported by
            # Actions count.
            checks = [
              { context = "ci-ok", integration_id = 15368 },
              { context = "Conventional PR title", integration_id = 15368 },
            ]
          }
        }
      }
    }
  }
}

repositories = {
  # Public, with the CI-gated ruleset.
  "terraform-modules" = {
    description = "Reusable OpenTofu modules"
    profiles    = ["public-module"]
  }

  # Private, opting out of the inherited ruleset (rulesets on private
  # repositories need GitHub Team).
  "my-app" = {
    description = "The main application"
    settings    = { has_wiki = true }
    rulesets    = { protect-default-branch = null }
  }

  # Private, inheriting base's ruleset. On GitHub Free, GitHub rejects
  # rulesets on private repositories (see on_unsupported_rulesets below).
  "internal-tools" = {
    description = "Internal scripts and tooling"
  }
}

# On GitHub Free, drop the rulesets of private repositories instead of failing
# the plan. Has no effect on paid plans.
on_unsupported_rulesets = "skip"

org_config = {
  settings = {
    billing_email = "my@example.com"
  }
  teams = {
    "engineering" = {
      description = "The core engineering team"
      members     = ["alice", "bob"]
    }
    "product" = {
      description = "Product management team"
      members     = ["charlie"]
    }
  }
  rulesets = {
    "protect-default-branches" = {
      repository_name = { include = ["~ALL"] }
      rules = {
        pull_request = { required_approving_review_count = 1 }
      }
    }
  }
}

# Organization rulesets need GitHub Team or above.
enable_org_rulesets = false
