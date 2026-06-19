# CameraApp Device Callback Ownership

## Status: Completed

## Context

`CameraDevice.StateCallback` can receive a delayed disconnect or error for the
device that initiated an earlier open. The current callbacks always clear
`mCameraDevice`, and the error callback finishes the activity, even when a
replacement camera is now current. A stale callback can therefore tear down
the ownership state and UI of a newer camera session.

## Objectives

- Close the callback-owned device for every disconnect or error.
- Clear shared camera state only when the callback device is still current.
- Finish the activity only for an error on the current camera device.
- Preserve semaphore release, preview-session ownership, diagnostics, and the
  existing Android 16 toolchain boundary.
- Keep the behavior verifiable through the repository's SDK-free baseline.

## Scope

- Update `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`.
- Extend `scripts/check-baseline.sh` with mutation-sensitive callback ownership
  and ordering contracts.
- Document the lifecycle boundary in `AGENTS.md`, `README.md`, `SECURITY.md`,
  `VISION.md`, and `CHANGES.md`.

## Verification

- `sh -n scripts/check-baseline.sh`
- `make check` from the repository root and an external directory
- Focused mutations removing the identity guard, moving the close after the
  guard, clearing replacement state, and finishing on stale errors
- `git diff --check`
- Generated artifact and sensitive-value audits

## Verification Results

- Four isolated ownership mutations were rejected: removing the disconnect
  guard, moving callback-device closure after the guard, clearing replacement
  state before the guard, and finishing the activity before error ownership.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed before the
  full package gate.
- Repository-root and external-directory `make check` passed with JDK 17,
  including zero-finding debug/release lint, debug instrumentation APK
  assembly, and debug application APK assembly.
- No emulator, physical camera, or live disconnect/error callback was
  executed; runtime lifecycle confirmation remains part of the checked-in
  device verification matrix.
