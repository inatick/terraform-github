resource "github_organization" "this" {
  name            = var.org_name
  two_factor_requirement = var.settings != null ? var.settings.two_factor_requirement : false
  public_repo_creation   = var.settings != null ? var.settings.public_repo_creation : "DISABLED"
}

resource "github_team" "this" {
  for_each    = var.teams
  name        = each.key
  description = each.value.description
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

  team_id      = github_team.this[each.value.team].id
  member_id    = each.value.member
  role         = "direct_member"
}

# Example of managing organization-level rulesets
resource "github_organization_ruleset" "this" {
  for_each = var.organization_rulesets

  name        = each.value.name
  target      = each.value.target
  entity_ids = each.value.entity_ids

  # Note: In a production module, we would use dynamic blocks 
  # for various rule types (branch_name, pusher, etc.)
  # This is a simplified implementation.
  conditions {
    # Example condition: branch name pattern
    # In a real module, this would be highly configurable
  }
}
