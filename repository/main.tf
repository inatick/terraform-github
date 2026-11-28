resource "github_repository" "this" {
  name                   = var.repository_name
  description            = var.description
  archived               = var.archived
  visibility             = var.is_private ? "private" : "public"
  allow_squash_merge     = var.allow_squash_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  allow_auto_merge       = var.allow_auto_merge
  allow_update_branch    = var.allow_update_branch
  delete_branch_on_merge = var.delete_branch_on_merge
  archive_on_destroy     = var.archive_on_destroy
  has_issues             = var.has_issues
  has_discussions        = var.has_discussions
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  is_template            = var.is_template
  gitignore_template     = var.gitignore_template
  license_template       = var.license_template
}

locals {
  # A null value means "no ruleset" (the repositories module uses it to opt
  # out of an inherited ruleset).
  rulesets = { for name, r in var.rulesets : name => r if r != null }
}

resource "github_repository_ruleset" "this" {
  for_each = local.rulesets

  name        = each.key
  repository  = github_repository.this.name
  target      = each.value.target
  enforcement = each.value.enforcement

  conditions {
    ref_name {
      include = coalesce(each.value.include, each.value.target == "tag" ? ["~ALL"] : ["~DEFAULT_BRANCH"])
      exclude = each.value.exclude
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors
    content {
      actor_type  = bypass_actors.value.actor_type
      actor_id    = bypass_actors.value.actor_id
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = each.value.rules.creation
    update                  = each.value.rules.update
    deletion                = each.value.rules.deletion
    non_fast_forward        = each.value.rules.non_fast_forward
    required_linear_history = each.value.rules.required_linear_history
    required_signatures     = each.value.rules.required_signatures

    dynamic "pull_request" {
      for_each = each.value.rules.pull_request == null ? [] : [each.value.rules.pull_request]
      content {
        required_approving_review_count   = pull_request.value.required_approving_review_count
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
        allowed_merge_methods             = pull_request.value.allowed_merge_methods
      }
    }

    dynamic "required_status_checks" {
      for_each = each.value.rules.required_status_checks == null ? [] : [each.value.rules.required_status_checks]
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict
        do_not_enforce_on_create             = required_status_checks.value.do_not_enforce_on_create

        dynamic "required_check" {
          for_each = required_status_checks.value.checks
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }
}
