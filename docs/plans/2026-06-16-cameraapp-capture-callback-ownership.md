# CameraApp Capture Callback Ownership

## Status: Completed

## Context

`mCaptureCallback` is shared across preview sessions and processes results
without checking which `CameraCaptureSession` produced them. The still-capture
completion callback similarly calls `unlockFocus()` without checking its
session. A delayed callback from a closed or replaced session can therefore
advance the replacement session's capture state or issue focus requests to it.

## Objectives

- Ignore preview capture results unless the callback session is still current.
- Ignore still-capture completion unless the callback session is still current.
- Preserve the existing AF/AE state machine, camera/session ownership, and
  capture behavior for current callbacks.
- Keep the boundary mutation-sensitive in the SDK-free baseline.

## Scope

- Update `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`.
- Extend `scripts/check-baseline.sh` with callback-session identity and ordering
  contracts.
- Document the ownership boundary in `AGENTS.md`, `README.md`, `SECURITY.md`,
  `VISION.md`, and `CHANGES.md`.

## Verification

- `sh -n scripts/check-baseline.sh`
- Repository-root and external-directory `make check`
- Isolated mutations removing or moving each session guard
- `git diff --check`
- Exact-path, generated-artifact, sensitive-value, conflict-marker, and
  file-mode audits

## Risks

- The guard must compare callback identity with `mCaptureSession` before any
  state transition or `unlockFocus()` call.
- Source validation cannot reproduce Android camera callback timing; emulator
  and physical-camera execution remain in the device verification matrix.
- This PR is stacked on PR #17 and must retain base-first merge ordering.

## Out Of Scope

- AF/AE heuristics, timeout policy, camera selection, image saving, UI changes,
  dependency/toolchain upgrades, and workflow changes.

## Verification Results

- `sh -n scripts/check-baseline.sh` passed, and the focused baseline accepted
  the implementation once completed-plan evidence was supplied.
- Six isolated ownership mutations were rejected: session visibility, both
  shared capture-result guards, the still-capture completion guard, maintained
  guidance, and completed plan status.
- Repository-root and external-directory `make check` passed the SDK-free
  source contracts and the pinned Android package gate.
- No emulator, physical camera, or live stale callback was executed; runtime
  callback timing remains in the checked-in device verification matrix.
