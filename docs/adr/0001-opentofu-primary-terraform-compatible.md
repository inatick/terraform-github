# 0001. OpenTofu first, Terraform compatible

- Status: Accepted
- Date: 2026-11-28

## Context

The inatick infrastructure uses OpenTofu, but these modules may also be used
from Terraform. OpenTofu has features Terraform lacks: state encryption,
early evaluation of variables in `backend` and module `source`, provider
`for_each`, `.tofu` file overrides and `-exclude`.

## Decision

- OpenTofu is the primary tool. CI lint, docs and release run with OpenTofu.
  Validate and test run with both OpenTofu and Terraform, and both legs are
  required.
- Modules must not use `.tofu` files or any OpenTofu-only syntax or feature.
  The OpenTofu-only features above help root configurations (backends, state,
  provider setup). These modules have none of those, so no feature justifies
  making them OpenTofu-only.
- `required_version = ">= 1.8.0"` in every module. Both tools meet this, and
  mocked providers in native tests need it.
- Install OpenTofu in CI with the official `opentofu/setup-opentofu` action.
  It's maintained by the OpenTofu project and verifies binaries against the
  release `SHA256SUMS`. It reads `.opentofu-version` via `tofu_version_file`.
  Terraform is installed with `hashicorp/setup-terraform`, with its version
  read from `.terraform-version`. Wrappers are disabled.
- Alternatives considered: `jdx/mise-action` and `tenv`. Both are useful
  locally, but they add a layer for no benefit over the official actions. The
  version files work with tenv, and with mise if configured.

## Consequences

- Contributors must keep code to the common subset of the two tools. The
  Terraform CI leg catches regressions.
- If a module ever needs an OpenTofu-only feature, write a new ADR that drops
  Terraform compatibility. That is a breaking change.
