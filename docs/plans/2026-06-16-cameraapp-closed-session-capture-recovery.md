# CameraApp Closed-Session Capture Recovery

## Status: Completed

## Context

`captureStillPicture()` and `unlockFocus()` recover preview state when Camera2
operations throw `CameraAccessException`. Android's Camera2 API also specifies
that methods on a closed or replaced `CameraCaptureSession` throw
`IllegalStateException`. A session can close after the existing non-null check,
so still submission or preview restart can still crash instead of completing
the established recovery path.

Primary references:

- Android `CameraCaptureSession` API:
  https://developer.android.com/reference/android/hardware/camera2/CameraCaptureSession
- Android `CameraDevice` API:
  https://developer.android.com/reference/android/hardware/camera2/CameraDevice

## Objectives

- Route closed-session still-capture submission through the existing focus and
  preview recovery path.
- Prevent closed-session focus-cancel or preview-restart operations from
  escaping after `STATE_PREVIEW` has already been published.
- Preserve stale-session callback ownership, successful capture behavior,
  fixed-category logging, and all existing Camera2 state transitions.
- Add mutation-sensitive static coverage for both recovery catch boundaries.

## Scope

- Update only the existing `captureStillPicture()` and `unlockFocus()` catch
  boundaries to include `IllegalStateException`.
- Update the SDK-free checker and maintained guidance.
- Do not change lock/precapture sequencing, retry policy, camera reopening,
  AF/AE policy, UI, persistence, dependencies, workflows, or toolchains.
- Stack the successor pull request on open terminal-green PR #21 without
  merging or closing either pull request.

## Verification

- Prove the pre-change source lacks closed-session recovery at both boundaries.
- Run `sh -n`, the focused SDK-free baseline, and repository/external
  `make check` with explicit timeouts.
- Reject isolated mutations that remove either `IllegalStateException`
  boundary, weaken checker coverage, remove guidance, or reopen plan status.
- Audit exact paths, generated artifacts, credentials, conflict markers,
  dependency/workflow drift, binaries, large files, file modes, and whitespace.

## Risks

- Source contracts cannot reproduce a physical camera session closing between
  the guard and Camera2 operation.
- No emulator, physical camera, or live capture race is exercised locally.

## Work Completed

- Extended the existing still-capture and preview-restart recovery catches to
  include closed or replaced Camera2 sessions.
- Preserved preview-state publication, focus recovery, stale-session callback
  ownership, and fixed-category error logging.
- Added catch-inventory and method-specific static contracts plus synchronized
  maintained guidance.

## Verification Results

- The pre-change source lacked closed-session recovery at both established
  synchronous recovery boundaries.
- `sh -n`, the focused SDK-free baseline, and repository and external-directory
  make check passed with explicit timeouts.
- Five isolated closed-session mutations were rejected: removing either
  recovery catch, broadening an unrelated catch boundary, deleting maintained
  security guidance, and reopening plan status.
- Exact diff, generated-artifact, credential-pattern, conflict-marker,
  dependency/workflow drift, binary, size, mode, and whitespace audits passed.
- No emulator, physical camera, or live closed-session race was executed.
