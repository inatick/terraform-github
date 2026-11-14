resource "github_branch_protection" "this" {
  repository_id = var.repository_id
  pattern       = var.branch

  enforce_admins = var.enforce_admins
  allows_force_pushes = var.allows_force_pushes
  allows_deletions = var.allows_deletions

  dynamic "required_pull_request_reviews" {
    for_each = var.required_pull_request_reviews != null ? [var.required_pull_request_reviews] : []
    content {
      dismiss_stale_reviews          = required_pull_request_reviews.value.dismiss_stale_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
    }
  }

  dynamic "required_status_checks" {
    for_each = var.required_status_checks != null ? [var.required_status_checks] : []
    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }
}
