# CameraApp Focus Policy Recovery Marker

Status: Completed
Date: 2026-06-25

## Context

The reviewed focus-recovery checker extracted the recovery capture submission's
line number without first requiring that marker to be unique. POSIX `test`
inside an `if` can report an illegal empty integer and continue, so deleting the
capture call could evade the ordering contract.

## Changes

- Require exactly one recovery `mCaptureSession.capture(...)` marker before
  line-number comparison.
- Require the base-owned baseline to retain that exact checker contract.
- Update the exact trusted checker and changelog templates and their digests.
- Preserve the existing eight-file semantic boundary.

## Verification

- The missing-marker hostile mutation is rejected.
- Trusted verifier unit tests pass.
- An exact synthetic semantic child is accepted.
- `scripts/check-baseline.sh` and `git diff --check` pass.
