# CameraApp Synchronous Capture Recovery

## Status: Planned

## Context

The still-capture callback now recovers focus after asynchronous capture
failure, but synchronous `CameraAccessException` paths can still leave the
capture state machine outside `STATE_PREVIEW`. A failed `stopRepeating()`,
still capture submission, focus-cancel request, or preview restart must not
leave subsequent shutter taps permanently blocked.

## Objectives

- Restore `STATE_PREVIEW` when still-capture submission fails synchronously.
- Publish preview state before focus-cancel and repeating-preview operations
  that can throw.
- Preserve session ownership guards and successful capture behavior.
- Make exception recovery and ordering mutation-sensitive in the SDK-free
  baseline.

## Scope

- Update `Camera2BasicFragment.java` capture and focus-recovery paths.
- Extend `scripts/check-baseline.sh` with synchronous recovery contracts.
- Update maintained engineering guidance and change history.

## Verification

- `sh -n scripts/check-baseline.sh`
- Focused SDK-free baseline validation
- Repository-root and external-directory `make check`
- Isolated mutations removing or reordering synchronous state recovery
- Exact diff, artifact, secret-like addition, conflict-marker, whitespace,
  and file-mode audits

## Risks

- State must be reset before any recovery operation that can throw.
- Recovery must continue using the current capture-session ownership boundary.
- Android camera timing still requires emulator or physical-device coverage.

## Out Of Scope

- Capture retries, AF/AE policy changes, UI changes, persistence changes,
  dependency upgrades, and workflow changes.
