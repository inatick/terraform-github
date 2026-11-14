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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| repository_id | The ID of the repository | `number` | - | yes |
| branch | The branch to protect | `string` | - | yes |
| enforce_admins | Whether to enforce administrator privileges | `bool` | `true` | no |
| allows_force_pushes | Whether to allow force pushes | `bool` | `false` | no |
| allows_deletions | Whether to allow deletions | `bool` | `false` | no |
| required_pull_request_reviews | Required pull request reviews configuration | `object` | `null` | no |
| required_status_checks | Required status checks configuration | `object` | `null` | no |

## Outputs

*(No outputs defined for this module)*
