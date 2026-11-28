mock_provider "github" {}

variables {
  repository_name = "test-repo"
}

run "defaults_are_private_and_squash_only" {
  command = plan

  assert {
    condition     = github_repository.this.visibility == "private"
    error_message = "Repositories should be private by default."
  }

  assert {
    condition     = github_repository.this.allow_squash_merge && !github_repository.this.allow_merge_commit && !github_repository.this.allow_rebase_merge
    error_message = "Only squash merge should be allowed by default."
  }

  assert {
    condition     = github_repository.this.archive_on_destroy == true
    error_message = "Repositories should be archived rather than deleted on destroy by default."
  }

  assert {
    condition     = github_repository.this.archived == false
    error_message = "Repositories should not be archived by default."
  }
}

run "public_when_not_private" {
  command = plan

  variables {
    is_private = false
  }

  assert {
    condition     = github_repository.this.visibility == "public"
    error_message = "is_private = false should produce a public repository."
  }
}

run "merge_options_can_be_overridden" {
  command = plan

  variables {
    allow_squash_merge = false
    allow_merge_commit = true
    allow_rebase_merge = true
  }

  assert {
    condition     = !github_repository.this.allow_squash_merge && github_repository.this.allow_merge_commit && github_repository.this.allow_rebase_merge
    error_message = "Merge options should follow the input variables."
  }
}

run "rejects_invalid_repository_name" {
  command = plan

  variables {
    repository_name = "not a valid name!"
  }

  expect_failures = [
    var.repository_name,
  ]
}

run "outputs_repository_name" {
  assert {
    condition     = output.repository_name == "test-repo"
    error_message = "repository_name output should match the input."
  }
}

run "null_settings_use_the_defaults" {
  command = plan

  variables {
    is_private         = null
    allow_merge_commit = null
    archive_on_destroy = null
  }

  assert {
    condition     = github_repository.this.visibility == "private" && !github_repository.this.allow_merge_commit && github_repository.this.archive_on_destroy
    error_message = "Passing null should fall back to the secure defaults (the repositories module relies on this)."
  }
}
