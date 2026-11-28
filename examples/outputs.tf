output "repositories" {
  description = "Map of repository name to its ID, name, URL and ruleset IDs"
  value       = module.repos.repositories
}

output "resolved" {
  description = "The effective configuration of each repository after merging profiles"
  value       = module.repos.resolved
}
