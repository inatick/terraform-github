# terraform-github

[![CI](https://github.com/inatick/terraform-github/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/inatick/terraform-github/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/inatick/terraform-github?sort=semver)](https://github.com/inatick/terraform-github/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Reusable OpenTofu modules for managing GitHub organizations, teams, repositories
and branch protection. Built and tested with OpenTofu, and kept compatible with
Terraform.

This repository contains **modules only**. It has no backend and manages no
real state. Use the modules from your own root configuration.

## Modules

| Module | Manages |
|--------|---------|
| [`organization`](organization/README.md) | Organization settings, teams and memberships, organization rulesets |
| [`repository`](repository/README.md) | A repository's visibility, merge methods, features and templates (private and squash-only by default) |
| [`branch_protection`](branch_protection/README.md) | A branch protection rule (admins included, no force pushes or deletions by default) |

[`examples/`](examples/README.md) wires all three together, and CI plans it
against a mocked provider.

## Usage

Reference a module by its subdirectory and pin a released tag:

```hcl
module "repo" {
  source = "git::https://github.com/inatick/terraform-github.git//repository?ref=v1.0.0"

  repository_name = "api-service"
  description     = "The main API service"
}

module "main_protection" {
  source = "git::https://github.com/inatick/terraform-github.git//branch_protection?ref=v1.0.0"

  repository_id = module.repo.repository_id
  branch        = "main"
  required_pull_request_reviews = {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }
}
```

Configure the `integrations/github` provider in your root configuration, for
example with `GITHUB_TOKEN` and `GITHUB_OWNER` in the environment. The modules
don't contain provider blocks.

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
| `enforce_admins` | branch_protection | `true` | Admins are subject to the rule |
| `allows_force_pushes` | branch_protection | `false` | Allow force pushes on protected branches |
| `allows_deletions` | branch_protection | `false` | Allow deletion of protected branches |
