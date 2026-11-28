# Security policy

## Reporting a vulnerability

Do not open a public issue. Report it privately with GitHub's
[private vulnerability reporting](https://github.com/inatick/terraform-github/security/advisories/new).
Include the affected module and version, and steps to reproduce.

## Supported versions

Only the latest release receives fixes.

## Supply chain

- CI jobs triggered by pull requests run without secrets, and workflows never
  use `pull_request_target`.
- Every GitHub Action is pinned to a full commit SHA. Downloaded binaries are
  checked against published SHA-256 checksums.
- Release tooling is pinned in `package-lock.json`, and its registry
  signatures are checked before each release.
- Trivy, actionlint and zizmor scan every change.
