# CameraApp Ready Capture Trusted Policy

Status: Completed
Date: 2026-06-26

## Context

The base-owned verifier currently authorizes only the completed Gradle 9.6.1
refresh. It must reject the newly designed immediately-ready capture-state
repair until a separate default-branch bootstrap reviews those exact bytes.

## Changes

- Replace the Gradle refresh templates with exact templates for the nine files
  in the ready-capture state repair.
- Preserve sole-parent topology, file-mode, size, digest, path, trusted-byte,
  archive-boundary, and hermetic tool verification.
- Keep the candidate as data; the trusted workflow executes no candidate code.

## Rollout

1. Merge this base-owned bootstrap after ordinary hosted checks and independent
   exact-head review. The old gate must reject candidate-owned policy changes.
2. Apply the reviewed semantic repair as one direct child of the new default
   branch.
3. Require the protected-environment trusted gate, API 36 verification,
   CodeQL, and exact-head review before merging that child.

## Verification

- Trusted verifier unit tests pass.
- The exact nine-file synthetic semantic child emits a passing receipt.
- Hostile byte, mode, extra-file, extra-commit, shallow-history, archive-path,
  oversized-blob, workflow-spoofing, and tool-injection cases remain covered.
- `scripts/check-baseline.sh`, policy JSON parsing, shell syntax, Make authority
  tests, and `git diff --check` pass. Full local `make check` stops at the
  explicit JDK 17 gate because this host exposes JDK 21. Hosted API 36 and
  CodeQL checks pass; the prior base-owned gate rejects this policy bootstrap
  as designed. Codex review failed before analysis with HTTP 401, and the exact
  head received a clean immutable manual review.
