# 0002. CI for a module repository has no plan or apply

- Status: Accepted
- Date: 2026-11-28

## Context

This repository publishes reusable modules. It has no backend, holds no state
and targets no real organization. `examples/` uses placeholder values.

## Decision

CI here is limited to static checks, offline tests, security scanning and
versioned releases. No plan, apply or drift detection runs against a real
organization.

Plan and apply belong in the consumer root configuration that manages the
`inatick` org. The usual pattern there:
- plan on PR, with the plan summary posted as a PR comment and the saved plan
  as an artifact
- apply exactly that plan on merge, behind a protected environment
- a scheduled `plan -refresh-only -detailed-exitcode` to detect drift
- a remote backend with OpenTofu state encryption, and credentials from a
  GitHub App or OIDC

## Consequences

- PR checks need no credentials, so pull requests from forks work.
- Behaviour against the real GitHub API isn't exercised here. An optional,
  manually triggered integration suite against a sandbox org can be added
  later, behind a protected environment and never on PRs.
