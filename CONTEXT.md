# Context

`terraform-github` is a public library of reusable OpenTofu modules (compatible
with Terraform) for the `integrations/github` provider. Consumers pin a
released tag. This repo has no backend and manages no real infrastructure.

## Glossary

- **Module**: one of `organization/`, `repository/`, `branch_protection/`. A
  child module with no provider or backend blocks.
- **Consumer**: a root configuration elsewhere (for example the repo that
  manages the `inatick` org) that calls these modules and runs plan and apply.
- **Example**: `examples/`, a root configuration with placeholder values that
  wires all modules together. CI plans it against a mocked provider.
- **Mocked test**: a `tests/*.tftest.hcl` file using `mock_provider "github"`.
  It needs no credentials.
- **Release**: a `vX.Y.Z` tag plus a GitHub Release, created by semantic-release
  from squash-merged conventional PR titles. There is one version for the whole
  repo.
- **`ci-ok`**: the aggregate CI check, and the only check branch rules require.

## Where to look

- Design: `docs/architecture.md`
- Decisions: `docs/adr/`
- How to contribute, test and release: `CONTRIBUTING.md`
