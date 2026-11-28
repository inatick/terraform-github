# Organization Module

This Terraform module manages GitHub Organization resources and settings.

## Usage

```hcl
module "org" {
  source   = "./modules/organization"
  org_name = "my-org"

  settings = {
    two_factor_requirement = "enabled"
    public_repo_creation   = "disabled"
  }

  teams = {
    "engineering" = {
      description = "Engineering team"
      members     = ["user1", "user2"]
    }
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
| [github_organization_ruleset.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_ruleset) | resource |
| [github_organization_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| org\_name | The name of the organization | `string` | n/a | yes |
| organization\_rulesets | Organization level rulesets | <pre>map(object({<br/>    name         = string<br/>    target       = string # e.g. "repository" or "organization"<br/>    entity_ids   = list(string)<br/>    rules_config = map(any)<br/>  }))</pre> | `{}` | no |
| projects | Deprecated: not used by this module and will be removed in a future major release. | `list(string)` | `[]` | no |
| settings | Organization settings | <pre>object({<br/>    billing_email                                                = optional(string)<br/>    company                                                      = optional(string)<br/>    blog                                                         = optional(string)<br/>    email                                                        = optional(string)<br/>    twitter_username                                             = optional(string)<br/>    location                                                     = optional(string)<br/>    name                                                         = optional(string)<br/>    description                                                  = optional(string)<br/>    has_organization_projects                                    = optional(bool)<br/>    has_repository_projects                                      = optional(bool)<br/>    default_repository_permission                                = optional(string)<br/>    members_can_create_repositories                              = optional(bool)<br/>    members_can_create_public_repositories                       = optional(bool)<br/>    members_can_create_private_repositories                      = optional(bool)<br/>    members_can_create_internal_repositories                     = optional(bool)<br/>    members_can_create_pages                                     = optional(bool)<br/>    members_can_create_public_pages                              = optional(bool)<br/>    members_can_create_private_pages                             = optional(bool)<br/>    members_can_fork_private_repositories                        = optional(bool)<br/>    web_commit_signoff_required                                  = optional(bool)<br/>    advanced_security_enabled_for_new_repositories               = optional(bool)<br/>    dependabot_alerts_enabled_for_new_repositories               = optional(bool)<br/>    dependabot_security_updates_enabled_for_new_repositories     = optional(bool)<br/>    dependency_graph_enabled_for_new_repositories                = optional(bool)<br/>    secret_scanning_enabled_for_new_repositories                 = optional(bool)<br/>    secret_scanning_push_protection_enabled_for_new_repositories = optional(bool)<br/><br/>  })</pre> | `{}` | no |
| teams | A map of teams and their members | <pre>map(object({<br/>    description          = optional(string, "A description of the team")<br/>    members              = optional(list(string), [])<br/>    privacy              = optional(string)<br/>    notification_setting = optional(string)<br/>    parent_team_id       = optional(string)<br/>    ldap_dn              = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| team\_ids | Map of team key to GitHub team ID |
<!-- END_TF_DOCS -->
