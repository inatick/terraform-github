# Context

`terraform-github` is a public library of reusable OpenTofu modules (compatible
with Terraform) for the `integrations/github` provider. Consumers pin a
released tag. This repo has no backend and manages no real infrastructure.

## Glossary

- **Module**: one of `organization/`, `repository/` and `repositories/`. A
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
- **Ruleset**: a set of rules (no deletion, no force push, pull request
  required, required status checks, ...) on matching branches or tags. A
  repository ruleset belongs to one repository; an organization ruleset targets
  many repositories by name or ID and needs GitHub Team. Rulesets replace
  classic branch protection (ADR 0006).
- **Profile**: a named set of repository settings and rulesets in the
  `repositories` module, applied to every repository that lists it (ADR 0007).
- **Default profile**: a profile in `default_profiles`, applied to every
  repository before its own profiles.
- **Resolved configuration**: a repository's effective settings and rulesets
  after merging its profiles and overrides. The `resolved` output of
  `repositories`.
- **Bypass actor**: an App, team, role or deploy key allowed to bypass a
  ruleset, always or only through pull requests.
- **`ci-ok`**: the aggregate CI check, and the only check branch rules require.

## Where to look

- Design: `docs/architecture.md`
- Decisions: `docs/adr/`
- How to contribute, test and release: `CONTRIBUTING.md`
