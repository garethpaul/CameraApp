# CameraApp Gradle 9.6.1 Trusted Policy

Status: Completed
Date: 2026-06-26

## Context

Android lint began rejecting the authenticated Gradle 9.6.0 wrapper after
9.6.1 became the current stable release. The base-owned verifier must review
the exact wrapper and documentation bytes before a semantic child can update
the project.

## Changes

- Replace the opened-camera templates with exact templates for the eleven files
  in the Gradle 9.6.1 refresh.
- Preserve sole-parent topology, file-mode, size, digest, path, trusted-byte,
  archive-boundary, and hermetic tool verification.
- Keep the candidate as data; the trusted workflow executes no candidate code.

## Rollout

1. Merge this base-owned bootstrap after ordinary hosted checks and independent
   exact-head review. The old gate must reject candidate-owned policy changes.
2. Apply the reviewed wrapper refresh as one direct child of the new default
   branch.
3. Require the protected-environment trusted gate, API 36 verification,
   CodeQL, and exact-head review before merging that child.

## Verification

- Trusted verifier unit tests pass.
- The exact eleven-file synthetic semantic child emits a passing receipt.
- Hostile byte, mode, extra-file, extra-commit, shallow-history, archive-path,
  oversized-blob, workflow-spoofing, and tool-injection cases remain covered.
- `scripts/check-baseline.sh`, policy JSON parsing, and `git diff --check` pass.
