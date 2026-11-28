variable "org_name" {
  type        = string
  description = "The name of the organization"

  validation {
    condition     = length(var.org_name) >= 1
    error_message = "The organization name must be at least 1 character long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.org_name))
    error_message = "The organization name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "settings" {
  type = object({
    billing_email                                                = optional(string)
    company                                                      = optional(string)
    blog                                                         = optional(string)
    email                                                        = optional(string)
    twitter_username                                             = optional(string)
    location                                                     = optional(string)
    name                                                         = optional(string)
    description                                                  = optional(string)
    has_organization_projects                                    = optional(bool)
    has_repository_projects                                      = optional(bool)
    default_repository_permission                                = optional(string)
    members_can_create_repositories                              = optional(bool)
    members_can_create_public_repositories                       = optional(bool)
    members_can_create_private_repositories                      = optional(bool)
    members_can_create_internal_repositories                     = optional(bool)
    members_can_create_pages                                     = optional(bool)
    members_can_create_public_pages                              = optional(bool)
    members_can_create_private_pages                             = optional(bool)
    members_can_fork_private_repositories                        = optional(bool)
    web_commit_signoff_required                                  = optional(bool)
    advanced_security_enabled_for_new_repositories               = optional(bool)
    dependabot_alerts_enabled_for_new_repositories               = optional(bool)
    dependabot_security_updates_enabled_for_new_repositories     = optional(bool)
    dependency_graph_enabled_for_new_repositories                = optional(bool)
    secret_scanning_enabled_for_new_repositories                 = optional(bool)
    secret_scanning_push_protection_enabled_for_new_repositories = optional(bool)

  })
  default     = {}
  description = "Organization settings"
}

variable "teams" {
  type = map(object({
    description          = optional(string, "A description of the team")
    members              = optional(list(string), [])
    privacy              = optional(string)
    notification_setting = optional(string)
    parent_team_id       = optional(string)
    ldap_dn              = optional(string)
  }))
  default     = {}
  description = "A map of teams and their members"
}

variable "rulesets" {
  description = <<-EOT
    Organization rulesets, keyed by ruleset name. They need GitHub Team or
    above. The rules object is the same as the repository module's. Target
    repositories with repository_name (default: all repositories) or
    repository_id, not both. include defaults to the default branch for branch
    rulesets and to all tags for tag rulesets.
  EOT
  nullable    = false
  default     = {}
  type = map(object({
    target      = optional(string, "branch")
    enforcement = optional(string, "active")
    include     = optional(list(string))
    exclude     = optional(list(string), [])
    repository_name = optional(object({
      include   = optional(list(string), ["~ALL"])
      exclude   = optional(list(string), [])
      protected = optional(bool, false)
    }))
    repository_id = optional(list(number))
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

  validation {
    condition     = alltrue([for r in values(var.rulesets) : !(r.repository_name != null && r.repository_id != null)])
    error_message = "Set repository_name or repository_id on an organization ruleset, not both."
  }

  validation {
    condition     = alltrue([for r in values(var.rulesets) : contains(["branch", "tag"], r.target)])
    error_message = "Ruleset target must be \"branch\" or \"tag\". Push rulesets are not supported."
  }

  validation {
    condition     = alltrue([for r in values(var.rulesets) : contains(["active", "disabled"], r.enforcement)])
    error_message = "Ruleset enforcement must be \"active\" or \"disabled\". \"evaluate\" needs GitHub Enterprise and is not supported."
  }

  validation {
    condition = alltrue(flatten([for r in values(var.rulesets) : [
      for a in r.bypass_actors : contains(["Integration", "OrganizationAdmin", "RepositoryRole", "Team", "DeployKey"], a.actor_type) && contains(["always", "pull_request"], a.bypass_mode)
    ]]))
    error_message = "Bypass actor actor_type must be one of Integration, OrganizationAdmin, RepositoryRole, Team or DeployKey, and bypass_mode must be \"always\" or \"pull_request\"."
  }

  validation {
    condition     = alltrue([for r in values(var.rulesets) : try(length(r.rules.required_status_checks.checks) > 0, true)])
    error_message = "required_status_checks.checks must list at least one check."
  }
}
