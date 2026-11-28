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
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| branch | The branch to protect | `string` | n/a | yes |
| repository\_id | The ID of the repository | `number` | n/a | yes |
| allows\_deletions | Whether to allow deletions | `bool` | `false` | no |
| allows\_force\_pushes | Whether to allow force pushes | `bool` | `false` | no |
| enforce\_admins | Whether to enforce administrator privileges | `bool` | `true` | no |
| required\_pull\_request\_reviews | Required pull request reviews configuration | <pre>object({<br/>    dismiss_stale_reviews           = bool<br/>    required_approving_review_count = number<br/>  })</pre> | `null` | no |
| required\_status\_checks | Required status checks configuration | <pre>object({<br/>    diameter_context = bool<br/>    strict           = bool<br/>    contexts         = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| branch\_protection\_id | The ID of the branch protection rule |
<!-- END_TF_DOCS -->
