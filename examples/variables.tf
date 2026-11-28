variable "owner" {
  type        = string
  description = "The GitHub organization that owns the repositories"
}

variable "default_profiles" {
  type        = list(string)
  default     = []
  description = "Profiles applied to every repository"
}

variable "profiles" {
  description = "Named, reusable repository configuration. Each profile can set repository settings and rulesets."
  nullable    = false
  default     = {}
  type = map(object({
    settings = optional(object({
      archived               = optional(bool)
      is_private             = optional(bool)
      allow_squash_merge     = optional(bool)
      allow_merge_commit     = optional(bool)
      allow_rebase_merge     = optional(bool)
      allow_auto_merge       = optional(bool)
      allow_update_branch    = optional(bool)
      delete_branch_on_merge = optional(bool)
      archive_on_destroy     = optional(bool)
      has_issues             = optional(bool)
      has_discussions        = optional(bool)
      has_projects           = optional(bool)
      has_wiki               = optional(bool)
      is_template            = optional(bool)
      gitignore_template     = optional(string)
      license_template       = optional(string)
    }), {})
    rulesets = optional(map(object({
      target      = optional(string, "branch")
      enforcement = optional(string, "active")
      include     = optional(list(string))
      exclude     = optional(list(string), [])
      bypass_actors = optional(list(object({
        actor_type  = string
        actor_id    = optional(number)
        bypass_mode = optional(string, "always")
      })), [])
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
    })), {})
  }))
}

variable "repositories" {
  description = <<-EOT
    Repositories to manage, keyed by repository name. Each one inherits
    default_profiles, then its own profiles (later profiles win), then its own
    settings and rulesets. Set a ruleset to null to remove an inherited one.
  EOT
  nullable    = false
  type = map(object({
    description = optional(string)
    profiles    = optional(list(string), [])
    settings = optional(object({
      archived               = optional(bool)
      is_private             = optional(bool)
      allow_squash_merge     = optional(bool)
      allow_merge_commit     = optional(bool)
      allow_rebase_merge     = optional(bool)
      allow_auto_merge       = optional(bool)
      allow_update_branch    = optional(bool)
      delete_branch_on_merge = optional(bool)
      archive_on_destroy     = optional(bool)
      has_issues             = optional(bool)
      has_discussions        = optional(bool)
      has_projects           = optional(bool)
      has_wiki               = optional(bool)
      is_template            = optional(bool)
      gitignore_template     = optional(string)
      license_template       = optional(string)
    }), {})
    rulesets = optional(map(object({
      target      = optional(string, "branch")
      enforcement = optional(string, "active")
      include     = optional(list(string))
      exclude     = optional(list(string), [])
      bypass_actors = optional(list(object({
        actor_type  = string
        actor_id    = optional(number)
        bypass_mode = optional(string, "always")
      })), [])
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
    })), {})
  }))
}

variable "on_unsupported_rulesets" {
  type        = string
  default     = "fail"
  description = "What to do with rulesets on private repositories when the organization is on GitHub Free: fail or skip"
}

variable "org_config" {
  type = object({
    settings = map(any)
    teams = optional(map(object({
      description          = optional(string, "A description of the team")
      members              = optional(list(string), [])
      privacy              = optional(string)
      notification_setting = optional(string)
      parent_team_id       = optional(string)
      ldap_dn              = optional(string)
    })), {})
    rulesets = optional(any, {})
  })
  default     = null
  description = "Organization settings, teams and organization rulesets. Leave null to leave the organization alone."
}

variable "enable_org_rulesets" {
  type        = bool
  default     = false
  description = "Create the organization rulesets in org_config. They need GitHub Team or above."
}

variable "github_token" {
  type        = string
  default     = null
  sensitive   = true
  description = "GitHub token for the provider. Leave null to use the GITHUB_TOKEN environment variable."
}
