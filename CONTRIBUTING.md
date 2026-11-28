# Contributing

## Toolchain

| Tool | Version source |
|------|----------------|
| OpenTofu | `.opentofu-version` |
| Terraform (compatibility checks only) | `.terraform-version` |
| TFLint | `TFLINT_VERSION` in `.github/workflows/ci.yml`. The plugin version is in `.tflint.hcl` |
| terraform-docs | `TERRAFORM_DOCS_VERSION` in `.github/workflows/ci.yml` |
| pre-commit | `.pre-commit-config.yaml` |
| Node.js (release tooling only) | `.nvmrc` |

When you bump a version, change it in the file listed above, so that CI and
local runs stay in step.

```bash
pre-commit install   # pre-commit and commit-msg hooks
make help            # list targets
make ci              # pre-commit + validate + test, the same as CI's OpenTofu leg
```

## Rules for module code

- **Keep the code compatible with Terraform.** Don't use `.tofu` files or any
  OpenTofu-only syntax or features in modules. CI runs validate and test with
  both tools. See [ADR 0001](docs/adr/0001-opentofu-primary-terraform-compatible.md).
- **No `provider` or `backend` blocks** in `organization/`, `repository/` or
  `branch_protection/`. Consumers configure the provider.
- Every module has `main.tf`, `variables.tf`, `outputs.tf` and `versions.tf`.
  TFLint enforces this.
- Every variable and output needs a `type` (variables) and a `description`.
- Don't commit `.terraform.lock.hcl` for child modules. Only `examples/` keeps a
  lock file.
- terraform-docs generates the section of each README between
  `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->`. Run `make docs`, and
  don't edit that section by hand.

## Tests

Each module has native tests in `<module>/tests/*.tftest.hcl`. They use
`mock_provider "github" {}`, so they need no token and no network access to
GitHub.

```bash
make test                 # OpenTofu
make test TOOL=terraform  # Terraform
cd repository && tofu init -backend=false && tofu test   # a single module
```

When you change behaviour, add or update a `run` block that asserts it. Use
`command = plan` unless you need computed values, and `expect_failures` for
variable validation. Keep test syntax to what both `tofu test` and
`terraform test` support.

## Commits, PR titles and releases

PRs are **squash-merged**, so the **PR title** becomes the commit on `main`.
It must follow [Conventional Commits](https://www.conventionalcommits.org/),
and the `PR title` check enforces this. The title decides the release:

| Title | Release |
|-------|---------|
| `fix: ...` | patch (`v1.2.3` → `v1.2.4`) |
| `feat: ...` | minor (`v1.2.3` → `v1.3.0`) |
| `feat!: ...`, or a `BREAKING CHANGE:` footer | major (`v1.2.3` → `v2.0.0`) |
| `chore:`, `docs:`, `ci:`, `test:`, `refactor:` ... | no release |

Treat a change as breaking if it removes or renames an input or output, changes
an input's type in an incompatible way, changes a default that alters
infrastructure, or raises `required_version` or the provider constraint.

Releases are fully automated. Once CI passes on `main`, semantic-release tags
the next version and publishes a GitHub Release. Never create tags by hand. To
preview the next version, run `make release-dry-run` (needs Node from
`.nvmrc`, `npm ci` and `gh auth login`).
