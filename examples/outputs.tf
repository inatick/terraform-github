output "repository_names" {
  value = [for r in module.repos : r.repository_name]
}

output "repository_ids" {
  value = { for k, v in module.repos : k => v.repository_id }
}
