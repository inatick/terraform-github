variable "repository_id" {
  type        = number
  description = "The ID of the repository"
}

variable "branch" {
  type        = string
  description = "The branch to protect"
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
    dismiss_stale_reviews          = bool
    required_approving_review_count = number
  })
  default = null
  description = "Required pull request reviews configuration"
}

variable "required_status_checks" {
  type = object({
    diameter_context = bool
    strict          = bool
    contexts        = list(string)
  })
  default = null
  description = "Required status checks configuration"
}
