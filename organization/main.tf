terraform {
  required_version = ">= 1.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

resource "github_organization" "this" {
  name          = var.org_name
  billing_email = var.settings.billing_email
}

resource "github_organization_settings" "this" {
  two_factor_authentication  = var.settings.two_factor_authentication
  verify_commit_signatures   = var.settings.verify_commit_signatures
  block_forks                = var.settings.block_forks
  sso_authentication         = var.settings.sso_authentication
  security_events            = var.settings.security_events
  maintenance_period         = var.settings.maintenance_period
  content_scanning           = var.settings.content_scanning
  audit_log_streaming        = var.settings.audit_log_streaming
  code_scanning              = var.settings.code_scanning
  secret_scanning            = var.settings.secret_scanning
  dependency_graph           = var.settings.dependency_graph
  hackerone_integration      = var.settings.hackerone_integration
  ip_allow_list              = var.settings.ip_allow_list
  community_profile          = var.settings.community_profile
  plan_settings              = var.settings.plan_settings
  repository_vulnerabilities = var.settings.repository_vulnerabilities
  security_governance        = var.settings.security_governance
}

resource "github_team" "this" {
  for_each     = var.teams
  name         = each.key
  description  = each.value.description
  organization = github_organization.this.node_id
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
  member_id = each.value.member
  role      = "direct_member"
}

# Example of managing organization-level rulesets
resource "github_organization_rulesets" "this" {
  for_each = var.organization_rulesets

  name       = each.value.name
  target     = each.value.target
  entity_ids = each.value.entity_ids

  # Note: In a production module, we would use dynamic blocks
  # for various rule types (branch_name, pusher, etc.)
  # This is a simplified implementation.
  conditions {
    # Example condition: branch name pattern
    # In a real module, this would be highly configurable
  }
}
