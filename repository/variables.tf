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
  nullable    = false
}

variable "archived" {
  type        = bool
  default     = false
  description = "Whether the repository is archived"
  nullable    = false
}

variable "is_private" {
  type        = bool
  default     = true
  description = "Whether the repository is private"
  nullable    = false
}

variable "allow_squash_merge" {
  type        = bool
  default     = true
  description = "Whether squash merge is allowed"
  nullable    = false
}

variable "allow_merge_commit" {
  type        = bool
  default     = false
  description = "Whether merge commits are allowed"
  nullable    = false
}

variable "allow_rebase_merge" {
  type        = bool
  default     = false
  description = "Whether rebase merge is allowed"
  nullable    = false
}

variable "allow_auto_merge" {
  type        = bool
  default     = false
  description = "Whether pull requests can be set to merge automatically once requirements are met"
  nullable    = false
}

variable "allow_update_branch" {
  type        = bool
  default     = false
  description = "Whether to suggest updating pull request branches that are behind the base branch"
  nullable    = false
}

variable "delete_branch_on_merge" {
  type        = bool
  default     = false
  description = "Whether head branches are deleted automatically after pull requests are merged"
  nullable    = false
}

variable "archive_on_destroy" {
  type        = bool
  default     = true
  description = "Whether to archive the repository instead of deleting it on destroy"
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "has_branch_protection" {
  type        = bool
  default     = false
  description = "Deprecated: not used; use the rulesets input instead. Will be removed in the next major release."
}

# tflint-ignore: terraform_unused_declarations
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
  description = "Deprecated: not used; use the rulesets input instead. Will be removed in the next major release."
}

variable "has_issues" {
  type        = bool
  default     = true
  description = "Whether issues are enabled"
  nullable    = false
}

variable "has_discussions" {
  type        = bool
  default     = true
  description = "Whether discussions are enabled"
  nullable    = false
}

variable "has_projects" {
  type        = bool
  default     = false
  description = "Whether projects are enabled"
  nullable    = false
}

variable "has_wiki" {
  type        = bool
  default     = false
  description = "Whether the wiki is enabled"
  nullable    = false
}

variable "is_template" {
  type        = bool
  default     = false
  description = "Whether the repository is a template"
  nullable    = false
}

variable "gitignore_template" {
  type        = string
  default     = ""
  description = "The gitignore template to use"
  nullable    = false
}

variable "license_template" {
  type        = string
  default     = ""
  description = "The license template to use"
  nullable    = false
}

variable "rulesets" {
  description = <<-EOT
    Repository rulesets, keyed by ruleset name. Each ruleset targets branches
    (default) or tags. `include` defaults to the default branch for branch
    rulesets and to all tags for tag rulesets. Rulesets on private
    repositories need a paid GitHub plan.
  EOT
  nullable    = false
  default     = {}
  # BEGIN shared-ruleset-type: keep identical in repository/ and repositories/
  # (scripts/check-type-drift.py). The rules object is also shared with organization/.
  type = map(object({
    target      = optional(string, "branch")
    enforcement = optional(string, "active")
    include     = optional(list(string))
    exclude     = optional(list(string), [])
    bypass_actors = optional(list(object({
      actor_type  = string
      actor_id    = optional(number)
      bypass_mode = optional(string, "always")
    })), [])
    # BEGIN shared-rules-type
    rules = optional(object({
      creation                = optional(bool)
      update                  = optional(bool)
      deletion                = optional(bool, true)
      non_fast_forward        = optional(bool, true)
      required_linear_history = optional(bool)
      required_signatures     = optional(bool)
      pull_request = optional(object({
        required_approving_review_count   = optional(number, 1)
        dismiss_stale_reviews_on_push     = optional(bool, true)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_review_thread_resolution = optional(bool, true)
        allowed_merge_methods             = optional(list(string))
      }))
      required_status_checks = optional(object({
        strict                   = optional(bool, false)
        do_not_enforce_on_create = optional(bool, false)
        checks = list(object({
          context        = string
          integration_id = optional(number)
        }))
      }))
    }), {})
    # END shared-rules-type
  }))
  # END shared-ruleset-type

  validation {
    condition     = alltrue([for r in values(var.rulesets) : r == null || contains(["branch", "tag"], r.target)])
    error_message = "Ruleset target must be \"branch\" or \"tag\". Push rulesets are not supported."
  }

  validation {
    condition     = alltrue([for r in values(var.rulesets) : r == null || contains(["active", "disabled"], r.enforcement)])
    error_message = "Ruleset enforcement must be \"active\" or \"disabled\". \"evaluate\" needs GitHub Enterprise and is not supported."
  }

  validation {
    condition = alltrue(flatten([for r in values(var.rulesets) : r == null ? [] : [
      for a in r.bypass_actors : contains(["Integration", "OrganizationAdmin", "RepositoryRole", "Team", "DeployKey"], a.actor_type)
    ]]))
    error_message = "Bypass actor actor_type must be one of Integration, OrganizationAdmin, RepositoryRole, Team or DeployKey."
  }

  validation {
    condition = alltrue(flatten([for r in values(var.rulesets) : r == null ? [] : [
      for a in r.bypass_actors : contains(["always", "pull_request"], a.bypass_mode)
    ]]))
    error_message = "Bypass actor bypass_mode must be \"always\" or \"pull_request\"."
  }

  validation {
    condition = alltrue([for r in values(var.rulesets) : r == null || try(
      length(r.rules.required_status_checks.checks) > 0, true
    )])
    error_message = "required_status_checks.checks must list at least one check."
  }
}
