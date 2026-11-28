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

# tflint-ignore: terraform_unused_declarations
variable "projects" {
  type        = list(string)
  default     = []
  description = "Deprecated: not used by this module and will be removed in a future major release."
}

variable "organization_rulesets" {
  type = map(object({
    name         = string
    target       = string # e.g. "repository" or "organization"
    entity_ids   = list(string)
    rules_config = map(any)
  }))
  default     = {}
  description = "Organization level rulesets"
}
