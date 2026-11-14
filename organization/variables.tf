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
    billing_email                 = optional(string)
    two_factor_authentication     = optional(bool)
    verify_commit_signatures      = optional(bool)
    block_forks                   = optional(bool)
    sso_authentication            = optional(bool)
    security_events               = optional(bool)
    maintenance_period            = optional(string)
    content_scanning              = optional(bool)
    audit_log_streaming           = optional(bool)
    code_scanning                 = optional(bool)
    secret_scanning               = optional(bool)
    dependency_graph               = optional(bool)
    hackerone_integration         = optional(bool)
    ip_allow_list                 = optional(bool)
    community_profile             = optional(bool)
    plan_settings                 = optional(string)
    repository_vulnerabilities    = optional(bool)
    security_governance           = optional(bool)
  })
  default     = {}
  description = "Organization settings"
}

variable "teams" {
  type = map(object({
    description = optional(string, "A description of the team")
    members     = optional(list(string), [])
  }))
  default     = {}
  description = "A map of teams and their members"
}

variable "projects" {
  type        = list(string)
  default     = []
  description = "List of project names to create"
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
