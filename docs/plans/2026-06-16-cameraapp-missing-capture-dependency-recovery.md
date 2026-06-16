# CameraApp Missing Capture Dependency Recovery

## Status: Completed

## Context

`captureStillPicture()` can be entered after the capture state machine leaves
`STATE_PREVIEW`. If the activity, camera device, image reader, or capture
session disappears before the still request is built, the method returns
without restoring preview state. Later shutter actions can then remain blocked
even though no still capture was submitted.

## Objectives

- Restore `STATE_PREVIEW` before returning for missing still-capture
  dependencies.
- Preserve successful capture behavior and current-session callback ownership.
- Make the nullable recovery and its ordering mutation-sensitive in the
  SDK-free baseline.

## Scope

- Update `Camera2BasicFragment.java` missing-dependency handling.
- Extend `scripts/check-baseline.sh` with a focused static contract.
- Update maintained engineering guidance and change history.

## Verification

- `sh -n scripts/check-baseline.sh`
- Focused SDK-free baseline validation
- Repository-root and external-directory `make check`
- Isolated mutations removing or reordering nullable dependency recovery
- Exact diff, artifact, secret-like addition, conflict-marker, whitespace,
  and file-mode audits

## Risks

- Preview state must be restored before the early return.
- Successful still-capture submission and callback ownership must remain
  unchanged.
- Android camera timing still requires emulator or physical-device coverage.

## Out Of Scope

- Capture retries, camera reopening, AF/AE policy changes, UI changes,
  dependency upgrades, and workflow changes.

## Verification Results

- `sh -n scripts/check-baseline.sh` and the focused SDK-free baseline passed.
- Three isolated nullable-recovery mutations were rejected: removing the
  preview-state reset, moving it after `return`, and moving it before the
  missing-dependency guard.
- Repository-root `make check` completed with Corretto 17, Android SDK 36, and
  Build Tools 36.1.0 in an isolated exact-source copy. The subsequent
  external-directory `make check` reached its explicit 240-second timeout and
  is not claimed as complete.
- Exact diff, artifact, secret-like addition, conflict-marker, whitespace, and
  file-mode audits passed before commit.
- No emulator, physical camera, or live missing-dependency race was exercised.
