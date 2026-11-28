# 0005. CI supply-chain hardening

- Status: Accepted
- Date: 2026-11-28

## Context

The repository is public, so its workflows run on pull requests from forks. Tag
hijacking of popular actions is a real attack (for example
`tj-actions/changed-files` in March 2025, where existing tags were moved to a
malicious commit).

## Decision

- Every `uses:` is pinned to a full commit SHA with a `# vX.Y.Z` comment.
  Dependabot updates both, with a 7-day cooldown.
- Binaries downloaded directly (terraform-docs, actionlint) are checked against
  pinned SHA-256 checksums. OpenTofu is verified by `setup-opentofu`.
- Top-level `permissions: contents: read` (or `{}`). Jobs widen permissions
  only where needed: `security-events: write` for SARIF, and `contents`,
  `issues` and `pull-requests` write for release.
- Only `pull_request` triggers, never `pull_request_target`. PR jobs use no
  secrets. Checkout uses `persist-credentials: false`, except where the
  workflow pushes a branch.
- GitHub App tokens instead of PATs, used only by the release and
  pre-commit-autoupdate workflows.
- The release job has no dependency cache, to avoid cache poisoning, and runs
  `npm audit signatures` before release.
- actionlint and zizmor (medium severity and above) lint every workflow
  change.

## Consequences

- Version bumps arrive as Dependabot PRs rather than floating tags.
- Enabling the repository setting "require actions to be pinned to a full-length
  commit SHA" enforces the pinning policy.
