output "team_ids" {
  value = { for k, v in github_team.this : k => v.id }
}
