# CameraApp Open Publication Trusted Policy

Status: Completed
Date: 2026-06-26

## Context

The base-owned verifier authorizes only the completed camera-open callback
release-token repair. It must reject the newly designed opened-device
publication ordering repair until a separate default-branch bootstrap reviews
those exact bytes.

## Changes

- Replace the callback-lock templates with exact templates for the nine files
  in the opened-camera publication repair.
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
- `scripts/check-baseline.sh`, policy JSON parsing, and `git diff --check` pass.
