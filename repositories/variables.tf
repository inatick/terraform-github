variable "owner" {
  type        = string
  description = "The organization that owns the repositories. Its GitHub plan is looked up to check that rulesets are supported."
}

variable "default_profiles" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "Profiles applied to every repository, in order, before the repository's own profiles."
}

variable "profiles" {
  description = "Named, reusable repository configuration. Each profile can set repository settings and rulesets."
  nullable    = false
  default     = {}
  type = map(object({
    # BEGIN settings-type: one attribute per repository/ input, except
    # repository_name, description, rulesets and deprecated inputs
    # (scripts/check-type-drift.py).
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
    # END settings-type
    # BEGIN shared-ruleset-type
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
    })), {})
    # END shared-ruleset-type
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
    # BEGIN settings-type
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
    # END settings-type
    # BEGIN shared-ruleset-type
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
    })), {})
    # END shared-ruleset-type
  }))
}

variable "on_unsupported_rulesets" {
  type        = string
  default     = "fail"
  nullable    = false
  description = <<-EOT
    What to do when the organization is on the GitHub Free plan and a private
    repository has rulesets, which GitHub rejects on Free. "fail" (default)
    fails the plan and names the repositories. "skip" drops those rulesets.
  EOT

  validation {
    condition     = contains(["fail", "skip"], var.on_unsupported_rulesets)
    error_message = "on_unsupported_rulesets must be \"fail\" or \"skip\"."
  }
}
