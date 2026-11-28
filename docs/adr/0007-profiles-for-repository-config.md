# 0007. Profiles for applying shared configuration to many repositories

- Status: Accepted
- Date: 2026-11-28

## Context

Most repositories in an organization share the same settings and rulesets,
with a few differences. Calling the `repository` module once per repository
repeats that configuration, and a change to the shared part has to be made in
every call.

## Decision

Add a `repositories` module that takes named **profiles**. A profile can set
repository settings and rulesets. Each repository lists the profiles it uses
and can override anything.

- Layers apply in order, later ones winning: `default_profiles`, then the
  repository's `profiles` (in list order), then its own `settings` and
  `rulesets`.
- Settings merge key by key. Unset (null) attributes are dropped from each
  layer before merging, so a layer that doesn't mention a setting doesn't reset
  it. Settings no layer sets fall back to the `repository` module's defaults,
  so the secure defaults live in one place.
- Rulesets merge by name. A later ruleset with the same name replaces the
  earlier one **as a whole**, and `null` removes an inherited ruleset.
- An unknown profile name fails the plan.
- `default_profiles` defaults to `[]`: no profile applies unless the consumer
  asks for it.
- On GitHub Free, a private repository with rulesets fails the plan by
  default. `on_unsupported_rulesets = "skip"` drops those rulesets explicitly.
- The `resolved` output shows each repository's merged configuration.

Alternatives considered:

- **Deep-merging rulesets.** HCL has no deep merge, and partly merged rules
  are hard to review in a plan. Whole replacement means each ruleset in a plan
  appears exactly as one layer wrote it. Variants go in separate profiles.
- **Leaving it to consumers** (`for_each` over a local map). Every consumer
  would reimplement the merge, including the null-stripping, which is easy to
  get wrong.
- **Organization rulesets only.** They avoid repeating rules, but they can't
  set repository settings and need GitHub Team. On Team they complement
  profiles (see the organization module's README).
- **Skipping unsupported rulesets silently.** That would leave a repository
  looking protected in code when it isn't, so failing is the default.

## Consequences

- One change to a profile updates every repository that uses it in a single
  plan.
- The settings type in `repositories/` and the ruleset type are copies of the
  `repository/` module's types, because HCL can't share types between
  modules. `scripts/check-type-drift.py` runs in pre-commit and CI and fails if
  they differ.
- Moving existing per-repository module calls into `repositories` needs
  `moved` blocks, or the repositories are recreated (and, with
  `archive_on_destroy`, archived).
