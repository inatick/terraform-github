terraform {
  required_version = ">= 1.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

data "github_organization" "this" {
  name = var.org_name
}

resource "github_organization_settings" "this" {
  billing_email                                                = var.settings.billing_email
  company                                                      = var.settings.company
  blog                                                         = var.settings.blog
  email                                                        = var.settings.email
  twitter_username                                             = var.settings.twitter_username
  location                                                     = var.settings.location
  name                                                         = var.settings.name
  description                                                  = var.settings.description
  has_organization_projects                                    = var.settings.has_organization_projects
  has_repository_projects                                      = var.settings.has_repository_projects
  default_repository_permission                                = var.settings.default_repository_permission
  members_can_create_repositories                              = var.settings.members_can_create_repositories
  members_can_create_public_repositories                       = var.settings.members_can_create_public_repositories
  members_can_create_private_repositories                      = var.settings.members_can_create_private_repositories
  members_can_create_internal_repositories                     = var.settings.members_can_create_internal_repositories
  members_can_create_pages                                     = var.settings.members_can_create_public_pages
  members_can_create_public_pages                              = var.settings.members_can_create_public_pages
  members_can_create_private_pages                             = var.settings.members_can_create_private_pages
  members_can_fork_private_repositories                        = var.settings.members_can_fork_private_repositories
  web_commit_signoff_required                                  = var.settings.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = var.settings.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories               = var.settings.dependabot_alerts_enabled_for_new_repositories
  dependabot_security_updates_enabled_for_new_repositories     = var.settings.dependabot_security_updates_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories                = var.settings.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = var.settings.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.settings.secret_scanning_push_protection_enabled_for_new_repositories
}

resource "github_team" "this" {
  for_each             = var.teams
  name                 = each.key
  description          = each.value.description
  privacy              = each.value.privacy
  notification_setting = each.value.notification_setting
  parent_team_id       = each.value.parent_team_id
  ldap_dn              = each.value.ldap_dn
}

resource "github_team_membership" "this" {
  for_each = {
    for pair in flatten([
      for team_key, team_val in var.teams : [
        for member in team_val.members : {
          team   = team_key
          member = member
        }
      ]
    ]) : "${pair.team}-${pair.member}" => pair
  }

  team_id   = github_team.this[each.value.team].id
  username   = each.value.member
  role       = "member"
}

# Example of managing organization-level rulesets
resource "github_organization_ruleset" "this" {
  for_each = var.organization_rulesets

  name        = each.value.name
  target      = each.value.target
  enforcement = "active"

  rules {
    deletion = true
  }
}
