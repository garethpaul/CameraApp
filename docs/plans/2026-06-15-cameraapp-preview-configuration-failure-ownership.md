---
title: CameraApp Preview Configuration Failure Ownership
type: reliability
status: completed
date: 2026-06-15
---

# CameraApp Preview Configuration Failure Ownership

## Problem

`createCameraPreviewSession()` binds successful configuration callbacks to the
exact initiating `CameraDevice`, but `onConfigureFailed()` always displays a
failure toast. A delayed failure from a camera that has already closed or been
replaced can therefore report an error during a newer camera lifetime. Camera2
already considers the failed session closed when this callback begins.

## Priorities

1. P0: Prevent stale preview-configuration failures from affecting current UI.
2. P1: Respect Camera2's already-closed failed-session contract.
3. P2: Preserve current-camera failure notification and all successful preview
   behavior.

## Requirements

- Do not invoke methods on the failed `CameraCaptureSession`; Camera2 already
  considers it closed when `onConfigureFailed()` begins.
- Compare the current `mCameraDevice` with the captured initiating device
  before displaying failure UI.
- Return silently for failures from closed or replaced camera lifetimes.
- Keep the current-camera failure toast unchanged.
- Add method-scoped, mutation-sensitive cleanup, identity, ordering, guidance,
  and completed-plan contracts.
- Do not claim emulator, physical-camera, or live close/reopen race execution.

## Implementation Units

### U1: Failed Session Ownership Boundary

**File:**
`Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`

Reject stale initiating-camera ownership without invoking the already-closed
session, and retain the existing failure toast only for the current lifetime.

### U2: Portable Failure Contract

**File:** `scripts/check-baseline.sh`

Scope `onConfigureFailed()`, reject session method calls, require
identity-before-toast ordering, and fail closed if stale suppression is weakened.

### U3: Maintained Guidance

**Files:** `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`, and this plan.

Document Camera2-owned failed-session closure and require failure UI to retain
initiating-camera ownership.

## Verification

- Run POSIX shell validation and the focused static baseline.
- Run SDK-backed repository and external-directory `make check`.
- Reject isolated session-use, identity, return, ordering, toast, guidance, and
  incomplete-plan mutations.
- Audit exact intended paths, generated artifacts, dependency/workflow drift,
  conflict markers, whitespace, and credential-shaped additions.

## Scope Boundaries

- Do not change successful preview setup, camera selection, camera semaphore
  ownership, background threads, capture sequencing, image saving, permissions,
  resources, dependencies, project metadata, or workflows.
- Keep this pull request stacked on PR #15 and preserve base-first ordering.

## Completion Evidence

- The focused source and guidance contract reached only this plan's intentional
  incomplete-status gate before the status was finalized.
- Corretto 17 with Android SDK 36 and Build Tools 36.1.0 passed debug/release
  lint with zero findings, instrumentation APK assembly, and debug app assembly.
- Repository-root and external-directory `make check` passed the complete JDK
  17, Android SDK 36, Build Tools 36.1.0, zero-finding debug/release lint,
  instrumentation APK, and debug application APK gate.
- Seven isolated hostile failure-ownership mutations were rejected across failed
  session method use, initiating-camera identity, stale return, callback ordering,
  current-camera failure UI, maintained guidance, and incomplete plan status.
- No emulator, physical camera, or live close/reopen preview race was exercised.
