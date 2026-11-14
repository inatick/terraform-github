variable "repository_name" {
  type        = string
  description = "The name of the repository"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the repository"
}

variable "is_private" {
  type        = bool
  default     = true
  description = "Whether the repository is private"
}

variable "allow_squash_merge" {
  type        = bool
  default     = true
  description = "Whether squash merge is allowed"
}

variable "allow_merge_commit" {
  type        = bool
  default     = false
  description = "Whether merge commits are allowed"
}

variable "allow_rebase_merge" {
  type        = bool
  default     = false
  description = "Whether rebase merge is allowed"
}

variable "has_branch_protection" {
  type        = bool
  default     = false
  description = "Whether to apply branch protection"
}

variable "branch_protection_config" {
  type = object({
    branch             = string
    enforce_admins     = bool
    allows_force_pushes = bool
    allows_deletions    = bool
    required_pull_request_reviews = boolean | null
    required_status_checks = boolean | null
  })
  default = null
  description = "Configuration for branch protection"
}
