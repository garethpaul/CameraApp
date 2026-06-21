# CameraApp Trusted Direct Gate V3

## Status: Completed

## Context

The exact live signed default parent for this bootstrap is
`31ef456ccdba0527407a6ec253e1b5e9bbbe6a1a`. The rejected candidates
`15c0885755c41aa18aeb92a85193facdb61fb55c` and
`67b2352a032ff956c4034e9215c53709d5e340bf` remain rejected sibling
non-ancestors and must not appear in any accepted repair ancestry.
15c0885755c41aa18aeb92a85193facdb61fb55c and 67b2352a032ff956c4034e9215c53709d5e340bf remain rejected sibling non-ancestors.

The v2 direct gate still trusted pull-request-controlled workflow/script bytes.
A malicious pull request can preserve the visible workflow command while
replacing `scripts/ci-check.sh` with `exit 0` or a symlink to `/usr/bin/true`.

## Architecture

Phase 1 adds a base-owned `pull_request_target` bootstrap,
`.github/workflows/trusted-cameraapp-gate.yml`. It checks out
`${{ github.workflow_sha }}` into `trusted-base`, verifies the protected
environment policy with isolated Python, fetches the pull request head into
`candidate` as untrusted Git data, and invokes only `trusted-base` verifier
bytes.
The privileged job uses read-only contents permission, no secrets, no cache, no
submodules, no LFS, no persisted credentials, and no candidate Make, Gradle, or
script execution.

The trusted verifier runs through `trusted-verifier/run-hermetic.sh`, clears
shell, Git, dynamic-loader, coverage, and Python startup variables, and execs
`/usr/bin/python3 -I -S -B`. `verify_candidate.py` validates source binding,
sole-parent topology, rejected ancestry, exact changed paths, modes, blob
digests, blob size limits, archive-style path limits, and trusted-checkout
bytes. The only accepted semantic child in this bootstrap is the reviewed
`SampleTests.java` permission retry template.

## Two-Phase Rollout

Phase 1 is this bootstrap commit. It is safe to merge only after local tests,
static checks, and hostile mutations pass. No GitHub writes, settings changes,
or merge are performed by the commit.

Phase 2 is operational setup after Phase 1 lands:

- Create `cameraapp-trusted-verifier-v1` with no secrets and no environment
  variables.
- Configure selected deployment branches with exactly one branch policy:
  `master`.
- Make a required protected environment deployment to
  `cameraapp-trusted-verifier-v1` the merge authority. The normal `Check`
  context is diagnostic, not authoritative.
- Re-run the environment preflight before accepting any semantic repair.

With that setup, pull-request workflow bytes, CODEOWNERS, candidate Makefiles,
candidate scripts, candidate Gradle config, and check names cannot authorize a
merge. Any later Android execution must be gated by the accepted trusted
receipt and separately reviewed trusted bytes/config.

## Test-First Evidence

- RED: the first regression built pull-request candidates that preserved
  `run: timeout 22m ./scripts/ci-check.sh` while replacing `scripts/ci-check.sh`
  with `exit 0` or a `/usr/bin/true` symlink. The v2 design lacked a trusted
  rejection and failed with the missing trusted verifier.
- GREEN: the base-owned verifier rejected both candidates with
  `candidate changed-file boundary differs`.
- Hostile tests cover workflow spoofing, extra files, extra commits, executable
  mode changes, environment/App mismatch, shallow ancestry, fake Git/Python
  tools, Python startup injection, hostile archive paths, and oversized blobs.

## Prerequisites

Hosted Android runtime validation still requires JDK 17, Android SDK platform
36, Build Tools 36.1.0, an API 36 Google APIs emulator image, writable cgroup v2
containment, and the protected environment described above.

## 2026-06-21 Base-Owned Repair

The environment preflight originally called the GitHub environments API
without authentication, so hosted runs received HTTP 403 before candidate
validation. The workflow now grants only `actions: read`, passes the built-in
workflow token only into the isolated preflight process, and sends it as a
Bearer token on both environment-policy requests. Candidate code still never
runs under `pull_request_target`, and the environment remains restricted to the
single `master` deployment branch policy.

The exact-file policy now authorizes only the reviewed documentation bytes from
closed PR #32 plus repaired successor bytes for its two Make harness scripts.
The authorized paths are `README.md`, `SECURITY.md`, the Make-authority plan,
and those two scripts. Application, Gradle, workflow, and all other paths remain
outside the accepted candidate boundary. PR #32 remains closed because its
parent predates this base-owned repair and its baseline script carries the old
policy assertion; any later publication must be a new single commit directly
on the repaired default branch.
