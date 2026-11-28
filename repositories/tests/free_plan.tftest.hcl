# The organization is on GitHub Free, where rulesets only work on public
# repositories.
mock_provider "github" {}

override_data {
  target = data.github_organization.this
  values = {
    plan = "free"
  }
}

variables {
  owner = "test-org"

  profiles = {
    protected = {
      rulesets = { protect-default-branch = {} }
    }
  }

  repositories = {
    public-module = {
      settings = { is_private = false }
      profiles = ["protected"]
    }
    private-app = {
      profiles = ["protected"]
    }
    private-unprotected = {}
  }
}

run "fails_for_private_repo_with_rulesets" {
  command = plan

  expect_failures = [data.github_organization.this]
}

run "skip_drops_only_private_rulesets" {
  command = plan

  variables {
    on_unsupported_rulesets = "skip"
  }

  assert {
    condition     = output.skipped_rulesets == tolist(["private-app"])
    error_message = "Only the private repository with rulesets should be skipped."
  }

  assert {
    condition     = length(output.repositories["private-app"].ruleset_ids) == 0 && length(output.repositories["public-module"].ruleset_ids) == 1
    error_message = "Skipped repositories should get no rulesets, and public ones keep theirs."
  }

  assert {
    condition     = length(output.resolved["private-app"].rulesets) == 1
    error_message = "The resolved output should still show the configured ruleset."
  }
}

run "public_repos_with_rulesets_plan" {
  command = plan

  variables {
    repositories = {
      public-module = {
        settings = { is_private = false }
        profiles = ["protected"]
      }
      private-unprotected = {}
    }
  }

  assert {
    condition     = length(output.repositories["public-module"].ruleset_ids) == 1 && length(output.skipped_rulesets) == 0
    error_message = "Public repositories should keep their rulesets on the Free plan."
  }
}
