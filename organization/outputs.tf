output "team_ids" {
  description = "Map of team key to GitHub team ID"
  value       = { for k, v in github_team.this : k => v.id }
}

output "ruleset_ids" {
  description = "Map of organization ruleset name (from var.rulesets) to GitHub ruleset ID"
  value       = { for k, v in github_organization_ruleset.rulesets : k => v.ruleset_id }
}
