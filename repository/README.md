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

## Destroying a repository

`archive_on_destroy` defaults to `true`, so removing a repository from your configuration archives it on GitHub instead of deleting it. The archived repository keeps its name: creating a repository with the same name later fails until you unarchive it (and import it) or delete it by hand. Set `archive_on_destroy = false` to delete repositories on destroy.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.8.0 |
| github | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| github | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| repository\_name | The name of the repository | `string` | n/a | yes |
| allow\_auto\_merge | Whether pull requests can be set to merge automatically once requirements are met | `bool` | `false` | no |
| allow\_merge\_commit | Whether merge commits are allowed | `bool` | `false` | no |
| allow\_rebase\_merge | Whether rebase merge is allowed | `bool` | `false` | no |
| allow\_squash\_merge | Whether squash merge is allowed | `bool` | `true` | no |
| allow\_update\_branch | Whether to suggest updating pull request branches that are behind the base branch | `bool` | `false` | no |
| archive\_on\_destroy | Whether to archive the repository instead of deleting it on destroy | `bool` | `true` | no |
| archived | Whether the repository is archived | `bool` | `false` | no |
| branch\_protection\_config | Deprecated: not used; use the branch\_protection module instead. Will be removed in a future major release. | <pre>object({<br/>    branch                        = string<br/>    enforce_admins                = bool<br/>    allows_force_pushes           = bool<br/>    allows_deletions              = bool<br/>    required_pull_request_reviews = optional(bool)<br/>    required_status_checks        = optional(bool)<br/>  })</pre> | `null` | no |
| delete\_branch\_on\_merge | Whether head branches are deleted automatically after pull requests are merged | `bool` | `false` | no |
| description | Description of the repository | `string` | `""` | no |
| gitignore\_template | The gitignore template to use | `string` | `""` | no |
| has\_branch\_protection | Deprecated: not used; use the branch\_protection module instead. Will be removed in a future major release. | `bool` | `false` | no |
| has\_discussions | Whether discussions are enabled | `bool` | `true` | no |
| has\_issues | Whether issues are enabled | `bool` | `true` | no |
| has\_projects | Whether projects are enabled | `bool` | `false` | no |
| has\_wiki | Whether the wiki is enabled | `bool` | `false` | no |
| is\_private | Whether the repository is private | `bool` | `true` | no |
| is\_template | Whether the repository is a template | `bool` | `false` | no |
| license\_template | The license template to use | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repository\_id | The ID of the repository |
| repository\_name | The name of the repository |
<!-- END_TF_DOCS -->
