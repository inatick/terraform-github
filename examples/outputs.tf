output "repository_names" {
  description = "Names of the repositories created by the example"
  value       = [for r in module.repos : r.repository_name]
}

output "repository_ids" {
  description = "Map of repository key to repository ID"
  value       = { for k, v in module.repos : k => v.repository_id }
}
