# GitHub Infrastructure Module (OpenTofu/Terraform)

A comprehensive set of modules to manage your GitHub infrastructure, including organizations, teams, repositories, and branch protection rules.

## Project Structure

```text
.
├── branch_protection/  # Module for branch protection rules
├── organization/       # Module for organization, teams, and rulesets
├── repository/          # Module for repository settings
├── examples/
│   ├── full_setup.tf   # Complete configuration example
│   ├── terraform.tfvars # Configuration values for the example
│   ├── providers.tf    # Provider configuration
│   ├── variables.tf    # Variables for the example
│   └── outputs.tf      # Outputs for the example
└── README.md
```

## Modules

### 1. Repository Module (`repository/`)
Configures base repository settings.
- **Default Merge Strategy**: Optimized for **squash-merge only** to maintain a clean commit history.
- **Customization**: Easily override merge settings (`merge_commit`, `rebase_merge`), visibility (`is_private`), and descriptions.

### 2. Branch Protection Module (`branch_protection/`)
Applies granular protection rules to specific branches.
- **Configurable Rules**:
  - Require pull request reviews (with configurable review counts).
  - Require status checks.
  - Enforce administrator privileges.
  - Disable force pushes and deletions.

### 3. Organization Module (`organization/`)
Manages the high-level structure of your organization.
- **Organization Settings**: Control Two-Factor Authentication (2FA) requirements and public repository creation settings.
- **Teams**: Create teams and manage memberships (users/members) within the organization.
- **Projects**: Provision project management spaces.
- **Organization Rulesets**: Apply organization-wide rulesets to enforce policies across the entire organization.

## Usage

To use the complete example:

1.  Navigate to the `examples/` directory:
    ```bash
    cd examples
    ```
2.  (Optional) Customize the `terraform.tfvars` file.
3.  Run `tofu init` (or `terraform init`).
4.  Run `tofu plan` to see the changes that will be applied.

### Example `terraform.tfvars`

```hcl
# Organization Configuration
org_config = {
  name  = "my-awesome-org"
  settings = {
    two_factor_requirement = true
    public_repo_creation   = "DISABLED"
  }
  teams = {
    "dev-team" = {
      description = "Core developers"
      members     = ["alice", "bob"]
    }
  }
  projects = ["Project Alpha"]
  organization_rulesets = {
    "enforce-2fa" = {
      name        = "Enforce 2FA"
      target      = "organization"
      entity_ids = []
      rules_config = {}
    }
  }
}

# Repository Configuration
repositories = {
  "api-service" = {
    name        = "api-service"
    description = "The main API service"
    is_private  = true
    branch_protection = {
      branch = "main"
      required_pull_request_reviews = {
        required_approving_review_count = 2
      }
    }
  }
}
```

## Defaults

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `is_private` | `true` | Repository visibility |
| `allow_squash_merge` | `true` | Allowed merge strategy |
| `allow_merge_commit` | `false` | Allowed merge strategy |
| `allow_rebase_merge` | `false` | Allowed merge strategy |
| `enforce_admins` | `true` | Branch protection admin enforcement |
| `allows_force_pushes` | `false` | Allow force pushes on protected branches |
| `allows_deletions` | `false` | Allow deletions on protected branches |
