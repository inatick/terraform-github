variable "repository_name" {
  type        = string
  description = "The name of the repository"

  validation {
    condition     = length(var.repository_name) >= 1
    error_message = "The repository name must be at least 1 character long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.repository_name))
    error_message = "The repository name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the repository"
}

variable "archived" {
  type        = bool
  default     = false
  description = "Whether the repository is archived"
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

variable "allow_auto_merge" {
  type        = bool
  default     = false
  description = "Whether pull requests can be set to merge automatically once requirements are met"
}

variable "allow_update_branch" {
  type        = bool
  default     = false
  description = "Whether to suggest updating pull request branches that are behind the base branch"
}

variable "delete_branch_on_merge" {
  type        = bool
  default     = false
  description = "Whether head branches are deleted automatically after pull requests are merged"
}

variable "archive_on_destroy" {
  type        = bool
  default     = true
  description = "Whether to archive the repository instead of deleting it on destroy"
}

variable "has_branch_protection" {
  type        = bool
  default     = false
  description = "Whether to apply branch protection"
}

variable "branch_protection_config" {
  type = object({
    branch                        = string
    enforce_admins                = bool
    allows_force_pushes           = bool
    allows_deletions              = bool
    required_pull_request_reviews = optional(bool)
    required_status_checks        = optional(bool)
  })
  default     = null
  description = "Configuration for branch protection"
}

variable "has_issues" {
  type        = bool
  default     = true
  description = "Whether issues are enabled"
}

variable "has_discussions" {
  type        = bool
  default     = true
  description = "Whether discussions are enabled"
}

variable "has_projects" {
  type        = bool
  default     = false
  description = "Whether projects are enabled"
}

variable "has_wiki" {
  type        = bool
  default     = false
  description = "Whether the wiki is enabled"
}

variable "is_template" {
  type        = bool
  default     = false
  description = "Whether the repository is a template"
}

variable "gitignore_template" {
  type        = string
  default     = ""
  description = "The gitignore template to use"
}

variable "license_template" {
  type        = string
  default     = ""
  description = "The license template to use"
}
