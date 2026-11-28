# terraform-github

[![CI](https://github.com/inatick/terraform-github/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/inatick/terraform-github/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/inatick/terraform-github?sort=semver)](https://github.com/inatick/terraform-github/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Reusable OpenTofu modules for managing GitHub organizations, teams, repositories
and rulesets. Built and tested with OpenTofu, and kept compatible with
Terraform.

This repository contains **modules only**. It has no backend and manages no
real state. Use the modules from your own root configuration.

## Modules

| Module | Manages |
|--------|---------|
| [`organization`](organization/README.md) | Organization settings, teams and memberships, organization rulesets |
| [`repository`](repository/README.md) | One repository and its rulesets (private and squash-only by default) |
| [`repositories`](repositories/README.md) | Many repositories from shared **profiles**: define settings and rulesets once, apply them everywhere, override per repository |
| [`branch_protection`](branch_protection/README.md) | **Deprecated**, removed in v2.0.0. A classic branch protection rule. Use rulesets instead. |

[`examples/`](examples/README.md) shows `repositories` with profiles and the
`organization` module, and CI plans it against a mocked provider.

## Usage

Reference a module by its subdirectory and pin a released tag:

```hcl
module "repos" {
  source = "git::https://github.com/inatick/terraform-github.git//repositories?ref=v1.1.0"

  owner            = "my-org"
  default_profiles = ["protected"]

  profiles = {
    protected = {
      settings = { delete_branch_on_merge = true }
      rulesets = {
        protect-default-branch = {
          rules = { pull_request = { required_approving_review_count = 1 } }
        }
      }
    }
  }

  repositories = {
    api-service = { description = "The main API service", settings = { is_private = false } }
    web-app     = { description = "The web front end", settings = { is_private = false } }
  }
}
```

For a single repository, use the [`repository`](repository/README.md) module
and its `rulesets` input directly.

Configure the `integrations/github` provider in your root configuration, for
example with `GITHUB_TOKEN` and `GITHUB_OWNER` in the environment. The modules
don't contain provider blocks.

## GitHub plan requirements

| Feature | Free | Team and above |
|---------|------|----------------|
| Repository settings, teams, profiles | yes | yes |
| Repository rulesets | public repositories only | all repositories |
| Organization rulesets | no | yes |

The `repositories` module checks the organization's plan and fails at plan time
if a private repository on GitHub Free has rulesets, unless you set
`on_unsupported_rulesets = "skip"`.

## Compatibility

| Tool | Supported | Tested in CI |
|------|-----------|--------------|
| OpenTofu (primary) | `>= 1.8.0` | version in [`.opentofu-version`](.opentofu-version) |
| Terraform | `>= 1.8.0` | version in [`.terraform-version`](.terraform-version) |
| `integrations/github` provider | `~> 6.0` | |

## Versioning and upgrading

The whole repository has one [semantic version](https://semver.org/). Every
merge to `main` that contains a `fix:` or `feat:` change is released
automatically. Release notes are on the
[Releases](https://github.com/inatick/terraform-github/releases) page.

**Upgrading from `v0.x`** (`v0.0.1`, `v0.1.0`) (breaking changes in `v1.0.0`):

- The repository root is no longer a root configuration. The placeholder
  `main.tf` was removed. Reference the modules by subdirectory as shown above.
- `examples/full_setup.tf` is now `examples/main.tf`.
- The modules now require OpenTofu or Terraform `>= 1.8.0`.
- `branch_protection.repository_id` is now a `string` (repository name or node
  ID), which fixes passing `module.<repo>.repository_id` into it. Numeric values
  still work.

**Deprecated in `v1.1.0`, removed in `v2.0.0`:**

- The `branch_protection` module. Replace it with a ruleset: add the ruleset
  and apply, then remove the `branch_protection` call and apply again, so the
  branch is never unprotected.
- `repository` inputs `has_branch_protection` and `branch_protection_config`
  (never used).
- `organization` inputs `organization_rulesets` (use `rulesets`) and `projects`
  (never used).

## Development

```bash
mise install            # or install tofu, tflint, terraform-docs and pre-commit yourself
pre-commit install      # installs the pre-commit and commit-msg hooks
make ci                 # what CI runs: pre-commit, validate and test (OpenTofu)
make test TOOL=terraform
```

Run `make help` to list all targets. See [CONTRIBUTING.md](CONTRIBUTING.md) for
the commit convention and the release process, and
[docs/architecture.md](docs/architecture.md) and [docs/adr/](docs/adr/) for
design decisions.

## Defaults

| Variable | Module | Default | Description |
|----------|--------|---------|-------------|
| `is_private` | repository | `true` | Repository visibility |
| `allow_squash_merge` | repository | `true` | Allowed merge strategy |
| `allow_merge_commit` | repository | `false` | Allowed merge strategy |
| `allow_rebase_merge` | repository | `false` | Allowed merge strategy |
| `archive_on_destroy` | repository | `true` | Archive rather than delete on destroy |
| `rulesets.*.rules.deletion` | repository | `true` | Block deleting the branch or tag |
| `rulesets.*.rules.non_fast_forward` | repository | `true` | Block force pushes |
| `on_unsupported_rulesets` | repositories | `"fail"` | Fail the plan for rulesets GitHub Free can't apply |
