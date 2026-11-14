variable "repository_id" {
  type        = number
  description = "The ID of the repository"

  validation {
    condition     = var.repository_id > 0
    error_message = "The repository_id must be a positive integer."
  }
}

variable "branch" {
  type        = string
  description = "The branch to protect"

  validation {
    condition     = length(var.branch) >= 1
    error_message = "The branch name must be at least 1 character long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-/._]+$", var.branch))
    error_message = "The branch name contains invalid characters. Only alphanumeric, hyphens, underscores, dots, and slashes are allowed."
  }
}

variable "enforce_admins" {
  type        = bool
  default     = true
  description = "Whether to enforce administrator privileges"
}

variable "allows_force_pushes" {
  type        = bool
  default     = false
  description = "Whether to allow force pushes"
}

variable "allows_deletions" {
  type        = bool
  default     = false
  description = "Whether to allow deletions"
}

variable "required_pull_request_reviews" {
  type = object({
    dismiss_stale_reviews           = bool
    required_approving_review_count = number
  })
  default     = null
  description = "Required pull request reviews configuration"
}

variable "required_status_checks" {
  type = object({
    diameter_context = bool
    strict           = bool
    contexts         = list(string)
  })
  default     = null
  description = "Required status checks configuration"
}
