# Repository Module

This Terraform module manages GitHub repositories with configurable settings for visibility, merge methods, and enabled features.

## Usage

```hcl
module "repo" {
  source = "./modules/repository"

  repository_name = "my-new-repo"
  is_private      = true
  description     = "A sample repository"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| repository_name | The name of the repository | `string` | - | yes |
| description | Description of the repository | `string` | `""` | no |
| is_private | Whether the repository is private | `bool` | `true` | no |
| allow_squash_merge | Whether squash merge is allowed | `bool` | `true` | no |
| allow_merge_commit | Whether merge commits are allowed | `bool` | `false` | no |
| allow_rebase_merge | Whether rebase merge is allowed | `bool` | `false` | no |
| has_issues | Whether issues are enabled | `bool` | `true` | no |
| has_projects | Whether projects are enabled | `bool` | `true` | no |
| has_wiki | Whether the wiki is enabled | `bool` | `true` | no |
| is_template | Whether the repository is a template | `bool` | `false` | no |
| gitignore_template | The gitignore template to use | `string` | `""` | no |
| license_template | The license template to use | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_id | The ID of the repository |
| repository_name | The name of the repository |
