mock_provider "github" {}

variables {
  repository_id = "test-repo"
  branch        = "main"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = github_branch_protection.this.pattern == "main"
    error_message = "The protected pattern should match the branch input."
  }

  assert {
    condition     = github_branch_protection.this.enforce_admins == true
    error_message = "Admins should be subject to branch protection by default."
  }

  assert {
    condition     = github_branch_protection.this.allows_force_pushes == false && github_branch_protection.this.allows_deletions == false
    error_message = "Force pushes and deletions should be blocked by default."
  }

  assert {
    condition     = length(github_branch_protection.this.required_pull_request_reviews) == 0
    error_message = "No pull request review block should be rendered when the input is null."
  }

  assert {
    condition     = length(github_branch_protection.this.required_status_checks) == 0
    error_message = "No status check block should be rendered when the input is null."
  }
}

run "renders_optional_blocks" {
  command = plan

  variables {
    required_pull_request_reviews = {
      dismiss_stale_reviews           = true
      required_approving_review_count = 2
    }
    required_status_checks = {
      diameter_context = false
      strict           = true
      contexts         = ["ci-ok"]
    }
  }

  assert {
    condition     = github_branch_protection.this.required_pull_request_reviews[0].required_approving_review_count == 2
    error_message = "The review count should follow the input."
  }

  assert {
    condition     = github_branch_protection.this.required_status_checks[0].strict && contains(github_branch_protection.this.required_status_checks[0].contexts, "ci-ok")
    error_message = "Status checks should follow the input."
  }
}

run "rejects_invalid_branch" {
  command = plan

  variables {
    branch = "bad branch"
  }

  expect_failures = [
    var.branch,
  ]
}
