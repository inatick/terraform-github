# 0004. semantic-release, one version for the whole repo

- Status: Accepted
- Date: 2026-11-28

## Context

An earlier setup had three competing release mechanisms (release-please,
semantic-release and a hand-written tag script), and none of them worked end
to end. This repository is already in use, and tags `v0.0.1` and `v0.1.0` exist (no GitHub Releases).

## Decision

- **semantic-release** is the only release mechanism. It's pinned in
  `package.json` and `package-lock.json` (Node version in `.nvmrc`) and
  configured in `.releaserc.json` with the `conventionalcommits` preset and the
  plugins `commit-analyzer`, `release-notes-generator` and `github`.
- **One version for the whole repository.** Tags are `vX.Y.Z` (the same format
  as the existing tags). Consumers reference `//<module>?ref=vX.Y.Z`. Per-module
  versions are explicitly not wanted.
- **No commit back to `main`.** The `changelog` and `git` plugins aren't used.
  The GitHub Release notes are the changelog, so the release bot never needs to
  bypass the `main` ruleset. If a `CHANGELOG.md` is wanted later, add those
  plugins and make the GitHub App a ruleset bypass actor.
- **Gating:** `release.yml` is a reusable workflow, called by a `release` job
  in `ci.yml` that `needs: ci-ok` and runs only for pushes to `main`. This was
  preferred over `workflow_run` because the dependency is explicit and the
  release always runs on the exact commit that passed CI.
- **Token:** a GitHub App token (`ORG_CLIENT_ID` / `ORG_APP_PRIVATE_KEY`),
  scoped to `contents`, `issues` and `pull-requests` write. Releases created by
  the App can trigger other workflows, which `GITHUB_TOKEN` releases cannot.
- **Version source:** squash-merged PR titles, enforced by the
  `pr-title.yml` check.

## Consequences

- Versioning continues from the latest tag, `v0.1.0`. The first change to standardise the
  modules is breaking (root config removed, `required_version >= 1.8.0`), so it
  is released as `v1.0.0`.
- The PR title matters: a mislabelled title produces the wrong version bump.
- There's no `CHANGELOG.md` in the repository. Release notes live on GitHub
  Releases.
