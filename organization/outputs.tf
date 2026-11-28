output "team_ids" {
  description = "Map of team key to GitHub team ID"
  value       = { for k, v in github_team.this : k => v.id }
}
