# Branch protection module

Manages a classic branch protection rule for one branch (or pattern) of a
repository. Defaults: admins are included, force pushes and deletions are
blocked. Review and status-check requirements are added only when their
inputs are set.

## Usage

```hcl
module "repo" {
  source          = "git::https://github.com/inatick/terraform-github.git//repository?ref=v1.0.0"
  repository_name = "my-new-repo"
}

module "branch_protection" {
  source = "git::https://github.com/inatick/terraform-github.git//branch_protection?ref=v1.0.0"

  repository_id = module.repo.repository_id # repository name or node ID
  branch        = "main"

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
| repository\_id | The name or node ID of the repository (for example the repository module's repository\_id output) | `string` | n/a | yes |
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
