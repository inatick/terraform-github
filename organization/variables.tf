variable "org_name" {
  type        = string
  description = "The name of the organization"
}

variable "settings" {
  type = object({
    two_factor_requirement = optional(bool, false)
    public_repo_creation   = optional(string, "DISABLED")
  })
  default = null
  description = "Organization settings"
}

variable "teams" {
  type = map(object({
    description = optional(string, "A description of the team")
    members     = optional(list(string), [])
  }))
  default = {}
  description = "A map of teams and their members"
}

variable "projects" {
  type    = list(string)
  default = []
  description = "List of project names to create"
}

variable "organization_rulesets" {
  type = map(object({
    name        = string
    target      = string # e.g. "repository" or "organization"
    entity_ids = list(string)
    # Using a simplified approach for the purpose of this task
    rules_config = map(any) 
  }))
  default = {}
  description = "Organization level rulesets"
}
