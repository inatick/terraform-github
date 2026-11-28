# Architecture

## What this repository is

`terraform-github` is a **library of reusable child modules** for the
`integrations/github` provider. It has no backend and manages no state.
Infrastructure is planned and applied by *consumer* root configurations that
pin a release tag. That's why CI here is lint, test and release, with no
plan or apply ([ADR 0002](adr/0002-module-repo-ci-without-plan-apply.md)).

## Modules

```
                 consumer root configuration
            (provider "github" { owner = ... }, backend)
                 │                              │
                 ▼                              ▼
       ┌──────────────────────┐         ┌──────────────┐
       │     repositories     │         │ organization │
       │ profiles + overrides │         └──────────────┘
       └──────────────────────┘          settings, teams,
                 │ for_each              memberships, org
                 ▼                       rulesets (Team plan)
       ┌──────────────────────┐   ┌───────────────────────────┐
       │      repository      │──▶│ github_repository_ruleset │
       │  github_repository   │   │      (one per name)       │
       └──────────────────────┘   └───────────────────────────┘
```

| Module | Resources | Inputs it depends on |
|--------|-----------|----------------------|
| `organization` | `github_organization_settings`, `github_team`, `github_team_membership`, `github_organization_ruleset`, `data.github_organization` | none |
| `repository` | `github_repository`, `github_repository_ruleset` | none |
| `repositories` | `module.repository` per repository, `data.github_organization` (plan lookup) | `owner` |

### Profiles

`repositories` merges, for each repository, its default profiles, its own
profiles and its own `settings` and `rulesets`, in that order
([ADR 0007](adr/0007-profiles-for-repository-config.md)). Settings merge key by
key, ignoring unset values. Rulesets merge by name and are replaced as a whole,
and `null` removes one. The result is the `resolved` output, and it's what
`module.repository` receives.

### Types shared between modules

HCL can't share a type between modules, so the ruleset type is written in
`repository/` and `repositories/`, the `rules` object also in `organization/`,
and the settings type in `repositories/` mirrors `repository/`'s inputs.
`scripts/check-type-drift.py` (a pre-commit hook, so also in CI) fails if the
copies differ.

### GitHub plan constraints

On GitHub Free, rulesets only work on public repositories and organization
rulesets don't work at all. `repositories` reads the organization's plan from
`data.github_organization` and fails the plan, rather than the apply, when a
private repository would get rulesets
([ADR 0006](adr/0006-rulesets-replace-branch-protection.md)).

Design constraints:

- **No provider or backend blocks in modules.** The consumer configures
  the provider (owner, token or App credentials). Each module declares only
  `required_providers` and `required_version` in `versions.tf`.
- **Secure, opinionated defaults** that a consumer can override: private
  repositories, squash-only merges, archive on destroy, admins subject to
  branch protection, no force pushes or deletions.
- **Tool compatibility.** OpenTofu is the primary tool, and the code must also
  work with Terraform (`>= 1.8.0` for both)
  ([ADR 0001](adr/0001-opentofu-primary-terraform-compatible.md)).
- **One version for the whole repository.** Consumers reference
  `//<module>?ref=vX.Y.Z`
  ([ADR 0004](adr/0004-semantic-release-single-version.md)).

## Layout

```
.
├── organization/ repository/ repositories/
│   ├── main.tf  variables.tf  outputs.tf  versions.tf
│   ├── README.md            # hand-written intro + terraform-docs section
│   └── tests/*.tftest.hcl   # native tests, mocked provider
├── examples/                # root configuration using profiles (+ lock file)
├── scripts/check-type-drift.py  # keeps the shared types in sync
│   └── tests/examples.tftest.hcl
├── .github/workflows/       # ci.yml, release.yml, pr-title.yml, pre-commit-autoupdate.yml
├── docs/architecture.md, docs/adr/
├── .opentofu-version .terraform-version .nvmrc   # tool versions
├── .tflint.hcl .terraform-docs.yml .pre-commit-config.yaml
├── package.json package-lock.json .releaserc.json  # release tooling only
└── Makefile                 # same commands locally and in CI
```

## CI/CD

```
 pull_request / push to main                          (no secrets in any PR job)
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │ ci.yml                                                                       │
 │  lint ─────────── pre-commit: fmt, tflint, docs and type drift, hygiene      │
 │  test (matrix) ── {tofu, terraform} × {organization, repository,             │
 │                   repositories, examples}: init, validate, test              │
 │  security ─────── Trivy IaC: SARIF to code scanning, fail on HIGH/CRITICAL   │
 │  actions-lint ─── actionlint + zizmor                                        │
 │  ci-ok ────────── aggregate; the only check the branch rules require         │
 │  release ──────── push to main only, needs ci-ok → release.yml               │
 └──────────────────────────────────────────────────────────────────────────────┘
 release.yml (workflow_call)
   npm ci → npm audit signatures → GitHub App token → semantic-release
   → analyse commits since last tag → tag vX.Y.Z → GitHub Release (no commit to main)

 pr-title.yml ─────────── conventional PR title (squash merge ⇒ it drives the version)
 pre-commit-autoupdate ── weekly, opens a PR with the App token
 dependabot.yml ───────── github-actions, terraform, npm (weekly, grouped, 7-day cooldown)
```

Principles ([ADR 0005](adr/0005-supply-chain-hardening.md)):

1. **Least privilege.** The default token permission is `contents: read`. Jobs
   widen it only where needed.
2. **Fork-safe.** Only `pull_request` triggers, never `pull_request_target`.
   Tests use a mocked provider, so they need no credentials.
3. **Reproducible.** Tool versions are pinned in files, actions are pinned by
   commit SHA, and downloads are checksum-verified. Dependabot keeps them
   current.
4. **The same commands locally and in CI.** `make ci` reproduces the OpenTofu
   leg.
5. **One required check** (`ci-ok`), so the branch rules don't change when jobs
   change.

## Repository settings (applied outside this repo)

- A ruleset on `main` requires the `ci-ok` and `Conventional PR title` checks,
  PRs only, no force push or deletion, linear history, squash merge only.
- Actions setting: require actions to be pinned to a full-length commit SHA.
- `ORG_CLIENT_ID` / `ORG_APP_PRIVATE_KEY`: the org GitHub App used only by the
  release and pre-commit-autoupdate workflows.
