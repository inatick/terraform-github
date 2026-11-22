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

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allow_merge_commit"></a> [allow\_merge\_commit](#input\_allow\_merge\_commit) | Whether merge commits are allowed | `bool` | `false` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | Whether rebase merge is allowed | `bool` | `false` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | Whether squash merge is allowed | `bool` | `true` | no |
| <a name="input_branch_protection_config"></a> [branch\_protection\_config](#input\_branch\_protection\_config) | Configuration for branch protection | <pre>object({<br/>    branch                        = string<br/>    enforce_admins                = bool<br/>    allows_force_pushes           = bool<br/>    allows_deletions              = bool<br/>    required_pull_request_reviews = optional(bool)<br/>    required_status_checks        = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the repository | `string` | `""` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | The gitignore template to use | `string` | `""` | no |
| <a name="input_has_branch_protection"></a> [has\_branch\_protection](#input\_has\_branch\_protection) | Whether to apply branch protection | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | Whether issues are enabled | `bool` | `true` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | Whether projects are enabled | `bool` | `true` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | Whether the wiki is enabled | `bool` | `true` | no |
| <a name="input_is_private"></a> [is\_private](#input\_is\_private) | Whether the repository is private | `bool` | `true` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | Whether the repository is a template | `bool` | `false` | no |
| <a name="input_license_template"></a> [license\_template](#input\_license\_template) | The license template to use | `string` | `""` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | The name of the repository | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | The ID of the repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | The name of the repository |
<!-- END_TF_DOCS -->
