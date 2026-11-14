resource "github_repository" "this" {
  name                     = var.repository_name
  description              = var.description
  visibility               = var.is_private ? "private" : "public"
  allow_squash_merge       = var.allow_squash_merge
  allow_merge_commit       = var.allow_merge_commit
  allow_rebase_merge       = var.allow_rebase_merge
  auto_delete              = false
  has_issues               = true
  has_projects             = true
  has_wiki                 = true
  is_template              = false
  gitignore_template        = ""
  license_template         = ""
  allow_governance_admins  = true
}

output "repository_id" {
  value = github_repository.this.id
}

output "repository_name" {
  value = github_repository.this.name
}
