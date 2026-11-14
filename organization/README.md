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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_name | The name of the organization | `string` | - | yes |
| settings | Organization settings | `object` | `{}` | no |
| teams | A map of teams and their members | `map(object)` | `{}` | no |
| projects | List of project names to create | `list(string)` | `[]` | no |
| organization_rulesets | Organization level rulesets | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| team_ids | A map of team keys to their GitHub IDs |
