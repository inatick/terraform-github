# 0006. Rulesets replace classic branch protection

- Status: Accepted
- Date: 2026-11-28

## Context

The `branch_protection` module wraps one `github_branch_protection` resource
(classic branch protection). Callers always had to wire it to the `repository`
module by passing `module.<repo>.repository_id`, and that hand-wiring caused
the `number`/`string` bug fixed in v1.0.0.

Repository rulesets (`github_repository_ruleset`) are GitHub's recommended
replacement:

- Several rulesets can apply to one branch, and they combine.
- They target the default branch (`~DEFAULT_BRANCH`), branch patterns or tags.
- They support bypass actors, such as a GitHub App.
- They have more rules (linear history, signatures, merge queue, file
  restrictions) and the same rule model works for organization rulesets.

GitHub Free allows rulesets, and classic protection, on public repositories
only. Organization rulesets need GitHub Team.

## Decision

- Manage rulesets in the `repository` module through a `rulesets` input, so a
  repository and its rules are configured together with no wiring.
- Use the same `rules` object for repository and organization rulesets, so a
  rule definition works at either level.
- Support rulesets only. Remove `branch_protection` in v2.0.0, in the same
  release that adds rulesets, rather than keeping both mechanisms.
- Support only `branch` and `tag` targets and `active` or `disabled`
  enforcement. `push` rulesets and `evaluate` enforcement need paid or
  Enterprise plans and nobody needs them yet. Expose further rule blocks when a
  repository needs them, each as a minor release.
- Where the GitHub plan can be checked (the `repositories` module), fail at
  plan time instead of letting the API return 403 at apply time.

## Consequences

- One mechanism to learn, document and test.
- Consumers on v1.x migrate by moving their other module calls to v2.0.0 and
  adding the equivalent ruleset, while their `branch_protection` calls stay
  pinned to v1.0.0. They apply, then remove `branch_protection` and apply
  again, so the branch is never unprotected. Rulesets and classic protection
  can exist together during the change.
- On GitHub Free, private repositories can't be protected by either mechanism,
  so removing classic protection loses nothing there.
