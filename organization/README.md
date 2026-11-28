# Organization module

Manages organization-level settings, teams and team memberships, and
organization rulesets. Planning fails early if `org_name` does not exist.

## Usage

```hcl
module "org" {
  source   = "git::https://github.com/inatick/terraform-github.git//organization?ref=v2.0.0"
  org_name = "my-org"

  settings = {
    billing_email                   = "billing@example.com"
    members_can_create_repositories = false
  }

  teams = {
    engineering = {
      description = "Engineering team"
      members     = ["user1", "user2"]
    }
  }
}
```

`settings.billing_email` is required by the GitHub provider.

## Organization rulesets

> [!IMPORTANT]
> Organization rulesets need **GitHub Team** or above. On GitHub Free the API
> rejects them.

One organization ruleset applies to many repositories, chosen by name pattern
or by ID. `rulesets` takes the same attributes and the same `rules` object as
the [repository module's rulesets](../repository/README.md#rulesets), plus:

| Attribute | Default | Notes |
|-----------|---------|-------|
| `repository_name` | `{ include = ["~ALL"] }` | `include` and `exclude` name patterns, and `protected` (whether matching repositories can be renamed or deleted). |
| `repository_id` | none | A list of repository IDs. Set this or `repository_name`, not both. |

```hcl
rulesets = {
  protect-default-branches = {
    # Every repository except sandboxes.
    repository_name = { include = ["~ALL"], exclude = ["sandbox-*"] }
    rules = {
      pull_request = { required_approving_review_count = 1 }
    }
  }
}
```

### Organization rulesets or profiles?

On GitHub Team, use both:

- **Organization rulesets** for rules that apply everywhere, for example "the
  default branch of every repository can't be deleted or force-pushed, and
  needs a pull request".
- **Profiles** in the [repositories](../repositories/README.md) module for
  repository settings, which organization rulesets can't set, and for rules
  that apply to only some repositories.

On GitHub Free, profiles are the only option, and their rulesets only take
effect on public repositories.

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
| [github_organization_ruleset.rulesets](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_ruleset) | resource |
| [github_organization_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| org\_name | The name of the organization | `string` | n/a | yes |
| rulesets | Organization rulesets, keyed by ruleset name. They need GitHub Team or<br/>above. The rules object is the same as the repository module's. Target<br/>repositories with repository\_name (default: all repositories) or<br/>repository\_id, not both. include defaults to the default branch for branch<br/>rulesets and to all tags for tag rulesets. | <pre>map(object({<br/>    target      = optional(string, "branch")<br/>    enforcement = optional(string, "active")<br/>    include     = optional(list(string))<br/>    exclude     = optional(list(string), [])<br/>    repository_name = optional(object({<br/>      include   = optional(list(string), ["~ALL"])<br/>      exclude   = optional(list(string), [])<br/>      protected = optional(bool, false)<br/>    }))<br/>    repository_id = optional(list(number))<br/>    bypass_actors = optional(list(object({<br/>      actor_type  = string<br/>      actor_id    = optional(number)<br/>      bypass_mode = optional(string, "always")<br/>    })), [])<br/>    # BEGIN shared-rules-type<br/>    rules = optional(object({<br/>      creation                = optional(bool)<br/>      update                  = optional(bool)<br/>      deletion                = optional(bool, true)<br/>      non_fast_forward        = optional(bool, true)<br/>      required_linear_history = optional(bool)<br/>      required_signatures     = optional(bool)<br/>      pull_request = optional(object({<br/>        required_approving_review_count   = optional(number, 1)<br/>        dismiss_stale_reviews_on_push     = optional(bool, true)<br/>        require_code_owner_review         = optional(bool, false)<br/>        require_last_push_approval        = optional(bool, false)<br/>        required_review_thread_resolution = optional(bool, true)<br/>        allowed_merge_methods             = optional(list(string))<br/>      }))<br/>      required_status_checks = optional(object({<br/>        strict                   = optional(bool, false)<br/>        do_not_enforce_on_create = optional(bool, false)<br/>        checks = list(object({<br/>          context        = string<br/>          integration_id = optional(number)<br/>        }))<br/>      }))<br/>    }), {})<br/>    # END shared-rules-type<br/>  }))</pre> | `{}` | no |
| settings | Organization settings | <pre>object({<br/>    billing_email                                                = optional(string)<br/>    company                                                      = optional(string)<br/>    blog                                                         = optional(string)<br/>    email                                                        = optional(string)<br/>    twitter_username                                             = optional(string)<br/>    location                                                     = optional(string)<br/>    name                                                         = optional(string)<br/>    description                                                  = optional(string)<br/>    has_organization_projects                                    = optional(bool)<br/>    has_repository_projects                                      = optional(bool)<br/>    default_repository_permission                                = optional(string)<br/>    members_can_create_repositories                              = optional(bool)<br/>    members_can_create_public_repositories                       = optional(bool)<br/>    members_can_create_private_repositories                      = optional(bool)<br/>    members_can_create_internal_repositories                     = optional(bool)<br/>    members_can_create_pages                                     = optional(bool)<br/>    members_can_create_public_pages                              = optional(bool)<br/>    members_can_create_private_pages                             = optional(bool)<br/>    members_can_fork_private_repositories                        = optional(bool)<br/>    web_commit_signoff_required                                  = optional(bool)<br/>    advanced_security_enabled_for_new_repositories               = optional(bool)<br/>    dependabot_alerts_enabled_for_new_repositories               = optional(bool)<br/>    dependabot_security_updates_enabled_for_new_repositories     = optional(bool)<br/>    dependency_graph_enabled_for_new_repositories                = optional(bool)<br/>    secret_scanning_enabled_for_new_repositories                 = optional(bool)<br/>    secret_scanning_push_protection_enabled_for_new_repositories = optional(bool)<br/><br/>  })</pre> | `{}` | no |
| teams | A map of teams and their members | <pre>map(object({<br/>    description          = optional(string, "A description of the team")<br/>    members              = optional(list(string), [])<br/>    privacy              = optional(string)<br/>    notification_setting = optional(string)<br/>    parent_team_id       = optional(string)<br/>    ldap_dn              = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| ruleset\_ids | Map of organization ruleset name (from var.rulesets) to GitHub ruleset ID |
| team\_ids | Map of team key to GitHub team ID |
<!-- END_TF_DOCS -->
