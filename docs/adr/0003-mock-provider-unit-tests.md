# 0003. Native tests with a mocked provider

- Status: Accepted
- Date: 2026-11-28

## Context

The earlier approach (in `terraform-github-repo`) ran only `validate` against a
test harness. That proves the code type-checks, but never evaluates defaults,
conditionals, `for_each` fan-out or variable validation. Running tests against
the live GitHub API would need secrets, which pull requests from forks don't
get, and would be slow and flaky.

## Decision

Each module has `tests/*.tftest.hcl` that use `mock_provider "github" {}`
(`override_data` where needed) and `run` blocks, mostly `command = plan`. They
assert resource attributes and use `expect_failures` for variable validation.
`examples/tests/` plans the full example as a smoke test of how the modules
connect.

The same test files run under `tofu test` and `terraform test`.

## Consequences

- Tests need no credentials and run in seconds.
- They found a real bug straight away: `branch_protection.repository_id` was
  typed `number`, but the repository module outputs a name string.
- Mocks don't prove the GitHub API accepts a configuration. That gap is
  accepted (see ADR 0002).
