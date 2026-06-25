# CameraApp Focus State Recovery

Status: Completed
Date: 2026-06-25

## Context

`lockFocus()` and `runPrecaptureSequence()` publish waiting states before
submitting Camera2 requests. A synchronous access failure or closed session can
reject that request, while a disappearing precapture dependency can return
before submission. Those paths previously left the shared capture state waiting
for a callback that would never arrive. Precapture failures could also retain
the earlier AF lock and a stale AE precapture trigger in the shared builder.

## Changes

- Restore `STATE_PREVIEW` when focus dependencies are unavailable or request
  submission fails.
- Restore `STATE_PREVIEW` when precapture dependencies are unavailable.
- Route submitted-request failures through `unlockFocus()` so recovery cancels
  focus and restarts the saved repeating preview when dependencies remain.
- Clear `CONTROL_AE_PRECAPTURE_TRIGGER` before submitting the recovery request.
- Recover from both `CameraAccessException` and closed-session
  `IllegalStateException` failures.
- Extend the SDK-free baseline with ordered recovery checks for both methods.

## Verification

- Confirmed the new source contract failed before the production change.
- `scripts/check-baseline.sh`
- Hostile mutations that removed dependency, submitted-request, or trigger
  recovery were rejected.
- `scripts/test-makefile-root.sh`
- `make check` with hosted API 36 instrumentation in GitHub Actions.

## Device Boundary

The local environment has no Android SDK, emulator, or physical camera, so no
live focus, precapture, preview, or still capture scenario was executed locally.
Camera timing and hardware behavior remain in the exact-head device verification
matrix.
