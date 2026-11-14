output "repository_id" {
  description = "The ID of the repository"
  value       = github_repository.this.id
}

output "repository_name" {
  description = "The name of the repository"
  value       = github_repository.this.name
}
