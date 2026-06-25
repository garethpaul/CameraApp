# CameraApp Preview Recovery Trusted Policy

Status: Completed
Date: 2026-06-25

## Context

The base-owned verifier authorizes only the completed focus-state repair. It
must reject the newly designed preview-session startup recovery until a
separate default-branch policy bootstrap reviews those exact bytes.

## Changes

- Replace the focus-state templates with exact templates for the eight files in
  the preview-session recovery candidate.
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

- All eight trusted verifier acceptance and hostile candidate tests passed.
- The exact eight-file synthetic semantic child emitted a passing receipt.
- Hostile byte, mode, extra-file, extra-commit, shallow-history, archive-path,
  oversized-blob, workflow-spoofing, and tool-injection cases were rejected.
- `scripts/check-baseline.sh`, policy JSON parsing, and `git diff --check`
  passed.
