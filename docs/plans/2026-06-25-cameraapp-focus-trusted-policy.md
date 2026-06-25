# CameraApp Focus Recovery Trusted Policy

Status: Completed
Date: 2026-06-25

## Context

The base-owned verifier still accepts only the completed June 20 permission
retry candidate. That stale semantic boundary rejects the reviewed focus and
precapture recovery change even though the normal API 36 checks and CodeQL pass.

## Changes

- Replace the historical single-file contract with exact templates for the
  eight files in the focus-recovery candidate.
- Preserve sole-parent topology, file-mode, size, digest, path, and trusted-byte
  verification.
- Generalize the regression fixture to populate candidates from policy instead
  of hard-coding `SampleTests.java`.
- Test the policy against an exact synthetic child and hostile byte, mode,
  extra-file, extra-commit, shallow-history, and tool-injection candidates.

## Rollout

1. Merge this base-owned policy bootstrap after ordinary hosted checks and an
   independent exact-head review. The old gate must reject this policy-changing
   bootstrap because candidate policy bytes are never trusted.
2. Rebase the semantic focus-recovery change as one direct child of the new
   default branch.
3. Require the base-owned trusted gate, both normal API 36 checks, CodeQL, and
   exact-head review to pass before merging the semantic child.

## Verification

- Eight trusted verifier acceptance and hostile candidate tests passed.
- The exact eight-file synthetic semantic child was accepted and emitted a
  receipt containing every reviewed digest.
- Hostile byte, mode, extra-file, extra-commit, shallow-history, archive-path,
  oversized-blob, workflow-spoofing, and tool-injection cases were rejected.
- `scripts/check-baseline.sh` passed.
- `git diff --check` passed.
