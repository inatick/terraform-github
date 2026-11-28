module "repos" {
  source = "../repository"

  for_each = var.repositories

  repository_name    = each.value.name
  description        = each.value.description
  is_private         = each.value.is_private
  allow_squash_merge = each.value.squash_merge
  allow_merge_commit = each.value.merge_commit
  allow_rebase_merge = each.value.rebase_merge
}

module "branch_protection" {
  source = "../branch_protection"
  for_each = {
    for k, v in var.repositories : k => v if v.branch_protection != null
  }

  repository_id                 = module.repos[each.key].repository_id
  branch                        = each.value.branch_protection.branch
  enforce_admins                = each.value.branch_protection.enforce_admins
  allows_force_pushes           = each.value.branch_protection.allows_force_pushes
  allows_deletions              = each.value.branch_protection.allows_deletions
  required_pull_request_reviews = each.value.branch_protection.required_pull_request_reviews
  required_status_checks        = each.value.branch_protection.required_status_checks
}

module "org" {
  source   = "../organization"
  for_each = var.org_config != null ? { "default" = var.org_config } : {}

  org_name              = each.value.name
  settings              = each.value.settings
  teams                 = each.value.teams
  projects              = each.value.projects
  organization_rulesets = each.value.organization_rulesets
}
