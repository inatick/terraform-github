# Example: profiles for many repositories

A root configuration that manages three repositories from shared profiles with
the [repositories](../repositories/README.md) module, plus organization
settings, teams and an organization ruleset with the
[organization](../organization/README.md) module. Values come from
`terraform.tfvars`:

| Repository | Profiles | Result |
|------------|----------|--------|
| `terraform-modules` | `base`, `public-module` | Public. Its CI-gated ruleset replaces `base`'s. |
| `my-app` | `base` | Private, with a wiki. Opts out of `base`'s ruleset. |
| `internal-tools` | `base` | Private, with `base`'s ruleset. On GitHub Free the ruleset is skipped (`on_unsupported_rulesets = "skip"`). |

The organization ruleset is created only when `enable_org_rulesets = true`,
because organization rulesets need GitHub Team.

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
| owner | The GitHub organization that owns the repositories | `string` | n/a | yes |
| repositories | Repositories to manage, keyed by repository name. Each one inherits<br/>default\_profiles, then its own profiles (later profiles win), then its own<br/>settings and rulesets. Set a ruleset to null to remove an inherited one. | <pre>map(object({<br/>    description = optional(string)<br/>    profiles    = optional(list(string), [])<br/>    settings = optional(object({<br/>      archived               = optional(bool)<br/>      is_private             = optional(bool)<br/>      allow_squash_merge     = optional(bool)<br/>      allow_merge_commit     = optional(bool)<br/>      allow_rebase_merge     = optional(bool)<br/>      allow_auto_merge       = optional(bool)<br/>      allow_update_branch    = optional(bool)<br/>      delete_branch_on_merge = optional(bool)<br/>      archive_on_destroy     = optional(bool)<br/>      has_issues             = optional(bool)<br/>      has_discussions        = optional(bool)<br/>      has_projects           = optional(bool)<br/>      has_wiki               = optional(bool)<br/>      is_template            = optional(bool)<br/>      gitignore_template     = optional(string)<br/>      license_template       = optional(string)<br/>    }), {})<br/>    rulesets = optional(map(object({<br/>      target      = optional(string, "branch")<br/>      enforcement = optional(string, "active")<br/>      include     = optional(list(string))<br/>      exclude     = optional(list(string), [])<br/>      bypass_actors = optional(list(object({<br/>        actor_type  = string<br/>        actor_id    = optional(number)<br/>        bypass_mode = optional(string, "always")<br/>      })), [])<br/>      rules = optional(object({<br/>        creation                = optional(bool)<br/>        update                  = optional(bool)<br/>        deletion                = optional(bool, true)<br/>        non_fast_forward        = optional(bool, true)<br/>        required_linear_history = optional(bool)<br/>        required_signatures     = optional(bool)<br/>        pull_request = optional(object({<br/>          required_approving_review_count   = optional(number, 1)<br/>          dismiss_stale_reviews_on_push     = optional(bool, true)<br/>          require_code_owner_review         = optional(bool, false)<br/>          require_last_push_approval        = optional(bool, false)<br/>          required_review_thread_resolution = optional(bool, true)<br/>          allowed_merge_methods             = optional(list(string))<br/>        }))<br/>        required_status_checks = optional(object({<br/>          strict                   = optional(bool, false)<br/>          do_not_enforce_on_create = optional(bool, false)<br/>          checks = list(object({<br/>            context        = string<br/>            integration_id = optional(number)<br/>          }))<br/>        }))<br/>      }), {})<br/>    })), {})<br/>  }))</pre> | n/a | yes |
| default\_profiles | Profiles applied to every repository | `list(string)` | `[]` | no |
| enable\_org\_rulesets | Create the organization rulesets in org\_config. They need GitHub Team or above. | `bool` | `false` | no |
| github\_token | GitHub token for the provider. Leave null to use the GITHUB\_TOKEN environment variable. | `string` | `null` | no |
| on\_unsupported\_rulesets | What to do with rulesets on private repositories when the organization is on GitHub Free: fail or skip | `string` | `"fail"` | no |
| org\_config | Organization settings, teams and organization rulesets. Leave null to leave the organization alone. | <pre>object({<br/>    settings = map(any)<br/>    teams = optional(map(object({<br/>      description          = optional(string, "A description of the team")<br/>      members              = optional(list(string), [])<br/>      privacy              = optional(string)<br/>      notification_setting = optional(string)<br/>      parent_team_id       = optional(string)<br/>      ldap_dn              = optional(string)<br/>    })), {})<br/>    rulesets = optional(any, {})<br/>  })</pre> | `null` | no |
| profiles | Named, reusable repository configuration. Each profile can set repository settings and rulesets. | <pre>map(object({<br/>    settings = optional(object({<br/>      archived               = optional(bool)<br/>      is_private             = optional(bool)<br/>      allow_squash_merge     = optional(bool)<br/>      allow_merge_commit     = optional(bool)<br/>      allow_rebase_merge     = optional(bool)<br/>      allow_auto_merge       = optional(bool)<br/>      allow_update_branch    = optional(bool)<br/>      delete_branch_on_merge = optional(bool)<br/>      archive_on_destroy     = optional(bool)<br/>      has_issues             = optional(bool)<br/>      has_discussions        = optional(bool)<br/>      has_projects           = optional(bool)<br/>      has_wiki               = optional(bool)<br/>      is_template            = optional(bool)<br/>      gitignore_template     = optional(string)<br/>      license_template       = optional(string)<br/>    }), {})<br/>    rulesets = optional(map(object({<br/>      target      = optional(string, "branch")<br/>      enforcement = optional(string, "active")<br/>      include     = optional(list(string))<br/>      exclude     = optional(list(string), [])<br/>      bypass_actors = optional(list(object({<br/>        actor_type  = string<br/>        actor_id    = optional(number)<br/>        bypass_mode = optional(string, "always")<br/>      })), [])<br/>      rules = optional(object({<br/>        creation                = optional(bool)<br/>        update                  = optional(bool)<br/>        deletion                = optional(bool, true)<br/>        non_fast_forward        = optional(bool, true)<br/>        required_linear_history = optional(bool)<br/>        required_signatures     = optional(bool)<br/>        pull_request = optional(object({<br/>          required_approving_review_count   = optional(number, 1)<br/>          dismiss_stale_reviews_on_push     = optional(bool, true)<br/>          require_code_owner_review         = optional(bool, false)<br/>          require_last_push_approval        = optional(bool, false)<br/>          required_review_thread_resolution = optional(bool, true)<br/>          allowed_merge_methods             = optional(list(string))<br/>        }))<br/>        required_status_checks = optional(object({<br/>          strict                   = optional(bool, false)<br/>          do_not_enforce_on_create = optional(bool, false)<br/>          checks = list(object({<br/>            context        = string<br/>            integration_id = optional(number)<br/>          }))<br/>        }))<br/>      }), {})<br/>    })), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repositories | Map of repository name to its ID, name, URL and ruleset IDs |
| resolved | The effective configuration of each repository after merging profiles |
<!-- END_TF_DOCS -->
