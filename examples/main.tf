module "repos" {
  source = "../repositories"

  owner                   = var.owner
  default_profiles        = var.default_profiles
  profiles                = var.profiles
  repositories            = var.repositories
  on_unsupported_rulesets = var.on_unsupported_rulesets
}

module "org" {
  source   = "../organization"
  for_each = var.org_config != null ? { "default" = var.org_config } : {}

  org_name = var.owner
  settings = each.value.settings
  teams    = each.value.teams
  # Organization rulesets need GitHub Team or above.
  rulesets = var.enable_org_rulesets ? each.value.rulesets : {}
}
