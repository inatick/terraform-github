# Agent guide

Read `CONTEXT.md` first, then `CONTRIBUTING.md`.

## Rules

- Run `make ci` before proposing changes. To check Terraform compatibility,
  also run `make test TOOL=terraform`.
- Don't use OpenTofu-only syntax or `.tofu` files in modules (ADR 0001).
- Don't add `provider` or `backend` blocks to modules. Don't commit child-module
  lock files.
- Regenerate README sections with `make docs`. Never edit the section between
  `BEGIN_TF_DOCS` and `END_TF_DOCS` by hand.
- PR titles must be Conventional Commits. They decide the release version (see
  CONTRIBUTING.md). Mark breaking changes with `!` or a `BREAKING CHANGE:`
  footer.
- Never create tags or releases by hand, and never run apply against a real
  organization.
- Pin any new GitHub Action to a full commit SHA with a `# vX.Y.Z` comment.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues, and external PRs are also treated as
requests. See `docs/agents/issue-tracker.md`.

### Triage labels

Uses the standard triage labels: `needs-triage`, `needs-info`,
`ready-for-agent`, `ready-for-human` and `wontfix`. See
`docs/agents/triage-labels.md`.

### Domain docs

Single-context layout with `CONTEXT.md` and `docs/adr/` at the repo root. See
`docs/agents/domain.md`.
