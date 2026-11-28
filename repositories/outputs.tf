output "repositories" {
  description = "Map of repository name to its ID, name, URL and ruleset IDs"
  value = {
    for k, m in module.repository : k => {
      id          = m.repository_id
      name        = m.repository_name
      html_url    = m.html_url
      ruleset_ids = m.ruleset_ids
    }
  }
}

output "resolved" {
  description = "The effective configuration of each repository after merging its profiles: description, profiles applied, settings (unset settings use the repository module defaults) and rulesets"
  value       = local.resolved
}

output "skipped_rulesets" {
  description = "Repositories whose rulesets were dropped because on_unsupported_rulesets = \"skip\" and the organization is on GitHub Free"
  value       = local.skip_rulesets
}
