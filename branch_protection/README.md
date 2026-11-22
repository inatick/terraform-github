# Branch Protection Module

This Terraform module manages GitHub branch protection rules for a specific repository.

## Usage

```hcl
module "branch_protection" {
  source = "./modules/branch_protection"

  repository_id                 = 12345678
  branch                        = "main"
  enforce_admins                = true
  allows_force_pushes           = false
  allows_deletions              = false
  required_pull_request_reviews = {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allows_deletions"></a> [allows\_deletions](#input\_allows\_deletions) | Whether to allow deletions | `bool` | `false` | no |
| <a name="input_allows_force_pushes"></a> [allows\_force\_pushes](#input\_allows\_force\_pushes) | Whether to allow force pushes | `bool` | `false` | no |
| <a name="input_branch"></a> [branch](#input\_branch) | The branch to protect | `string` | n/a | yes |
| <a name="input_enforce_admins"></a> [enforce\_admins](#input\_enforce\_admins) | Whether to enforce administrator privileges | `bool` | `true` | no |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | The ID of the repository | `number` | n/a | yes |
| <a name="input_required_pull_request_reviews"></a> [required\_pull\_request\_reviews](#input\_required\_pull\_request\_reviews) | Required pull request reviews configuration | <pre>object({<br/>    dismiss_stale_reviews           = bool<br/>    required_approving_review_count = number<br/>  })</pre> | `null` | no |
| <a name="input_required_status_checks"></a> [required\_status\_checks](#input\_required\_status\_checks) | Required status checks configuration | <pre>object({<br/>    diameter_context = bool<br/>    strict           = bool<br/>    contexts         = list(string)<br/>  })</pre> | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
