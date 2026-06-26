# CameraApp Callback Lock Trusted Policy

Status: Completed
Date: 2026-06-26

## Context

The base-owned verifier authorizes only the completed preview-session recovery.
It must reject the newly designed camera-open callback lock repair until a
separate default-branch bootstrap reviews those exact bytes.

## Changes

- Replace the preview-session templates with exact templates for the eight files
  in the callback lock ownership repair.
- Preserve sole-parent topology, file-mode, size, digest, path, trusted-byte,
  archive-boundary, and hermetic tool verification.
- Keep the candidate as data; the trusted workflow executes no candidate code.

## Rollout

1. Merge this base-owned bootstrap after ordinary hosted checks and independent
   exact-head review. The old gate must reject candidate-owned policy changes.
2. Apply the reviewed semantic repair as one direct child of the new default
   branch.
3. Require the protected-environment trusted gate, both API 36 checks, CodeQL,
   and exact-head review before merging that child.

## Verification

- Trusted verifier unit tests passed.
- The exact eight-file synthetic semantic child emitted a passing receipt.
- Hostile byte, mode, extra-file, extra-commit, shallow-history, archive-path,
  oversized-blob, workflow-spoofing, and tool-injection cases remain covered.
- `scripts/check-baseline.sh`, policy JSON parsing, and `git diff --check`
  passed.
