variable "repositories" {
  type = map(object({
    name         = string
    description  = optional(string, "")
    is_private   = optional(bool, true)
    squash_merge = optional(bool, true)
    merge_commit = optional(bool, false)
    rebase_merge = optional(bool, false)
    branch_protection = optional(object({
      branch              = string
      enforce_admins      = optional(bool, true)
      allows_force_pushes = optional(bool, false)
      allows_deletions    = optional(bool, false)
      required_pull_request_reviews = optional(object({
        dismiss_stale_reviews           = optional(bool, true)
        required_approving_review_count = optional(number, 1)
      }), null)
      required_status_checks = optional(object({
        diameter_context = optional(bool, false)
        strict           = optional(bool, false)
        contexts         = list(string)
      }), null)
    }), null)
  }))
  description = "Map of repository configurations"
}

variable "org_config" {
  type = object({
    name     = string
    settings = map(any)
    teams = map(object({
      description          = optional(string, "A description of the team")
      members              = optional(list(string), [])
      privacy              = optional(string)
      notification_setting = optional(string)
      parent_team_id       = optional(string)
      ldap_dn              = optional(string)
    }))
    projects = list(string)
    organization_rulesets = map(object({
      name         = string
      target       = string
      entity_ids   = list(string)
      rules_config = map(any)
    }))
  })
  default     = null
  description = "Organization and team configuration"
}
