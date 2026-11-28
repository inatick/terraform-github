# Example: full setup

Shows the three modules working together: repositories (`../repository`), their
branch protection (`../branch_protection`) and organization settings, teams and
rulesets (`../organization`). Values come from `terraform.tfvars`.

`tests/examples.tftest.hcl` plans this example against a mocked provider in CI.
To plan it against a real organization:

```bash
export GITHUB_TOKEN=...   # token with admin rights on the target org
export GITHUB_OWNER=my-org
make init plan summarise
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.8.0 |
| github | ~> 6.0 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| repositories | Map of repository configurations | <pre>map(object({<br/>    name         = string<br/>    description  = optional(string, "")<br/>    is_private   = optional(bool, true)<br/>    squash_merge = optional(bool, true)<br/>    merge_commit = optional(bool, false)<br/>    rebase_merge = optional(bool, false)<br/>    branch_protection = optional(object({<br/>      branch              = string<br/>      enforce_admins      = optional(bool, true)<br/>      allows_force_pushes = optional(bool, false)<br/>      allows_deletions    = optional(bool, false)<br/>      required_pull_request_reviews = optional(object({<br/>        dismiss_stale_reviews           = optional(bool, true)<br/>        required_approving_review_count = optional(number, 1)<br/>      }), null)<br/>      required_status_checks = optional(object({<br/>        diameter_context = optional(bool, false)<br/>        strict           = optional(bool, false)<br/>        contexts         = list(string)<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | n/a | yes |
| github\_token | GitHub token for the provider. Leave null to use the GITHUB\_TOKEN environment variable. | `string` | `null` | no |
| org\_config | Organization and team configuration | <pre>object({<br/>    name     = string<br/>    settings = map(any)<br/>    teams = map(object({<br/>      description          = optional(string, "A description of the team")<br/>      members              = optional(list(string), [])<br/>      privacy              = optional(string)<br/>      notification_setting = optional(string)<br/>      parent_team_id       = optional(string)<br/>      ldap_dn              = optional(string)<br/>    }))<br/>    projects = list(string)<br/>    organization_rulesets = map(object({<br/>      name         = string<br/>      target       = string<br/>      entity_ids   = list(string)<br/>      rules_config = map(any)<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repository\_ids | Map of repository key to repository ID |
| repository\_names | Names of the repositories created by the example |
<!-- END_TF_DOCS -->
