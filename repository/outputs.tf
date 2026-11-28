output "repository_id" {
  description = "The ID of the repository"
  value       = github_repository.this.id
}

output "repository_name" {
  description = "The name of the repository"
  value       = github_repository.this.name
}

output "html_url" {
  description = "The URL of the repository on GitHub"
  value       = github_repository.this.html_url
}

output "ruleset_ids" {
  description = "Map of ruleset name to GitHub ruleset ID"
  value       = { for k, v in github_repository_ruleset.this : k => v.ruleset_id }
}
