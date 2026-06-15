---
title: CameraApp Preview Configuration Failure Ownership
type: reliability
status: planned
date: 2026-06-15
---

# CameraApp Preview Configuration Failure Ownership

## Problem

`createCameraPreviewSession()` binds successful configuration callbacks to the
exact initiating `CameraDevice`, but `onConfigureFailed()` always displays a
failure toast. A delayed failure from a camera that has already closed or been
replaced can therefore report an error during a newer camera lifetime. Cleanup
of the failed session is also left implicit.

## Priorities

1. P0: Prevent stale preview-configuration failures from affecting current UI.
2. P1: Close every failed preview session explicitly.
3. P2: Preserve current-camera failure notification and all successful preview
   behavior.

## Requirements

- Close the callback-owned `CameraCaptureSession` in `onConfigureFailed()`.
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

Explicitly close the failed session, reject stale initiating-camera ownership,
and retain the existing failure toast only for the current camera lifetime.

### U2: Portable Failure Contract

**File:** `scripts/check-baseline.sh`

Scope `onConfigureFailed()`, require close-before-identity-before-toast ordering,
and fail closed if cleanup or stale-callback suppression is weakened.

### U3: Maintained Guidance

**Files:** `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`, and this plan.

Document that failed asynchronous preview sessions close and may report UI only
while their initiating camera remains current.

## Verification

- Run POSIX shell validation and the focused static baseline.
- Run SDK-backed repository and external-directory `make check`.
- Reject isolated close, identity, return, ordering, toast, guidance, and
  incomplete-plan mutations.
- Audit exact intended paths, generated artifacts, dependency/workflow drift,
  conflict markers, whitespace, and credential-shaped additions.

## Scope Boundaries

- Do not change successful preview setup, camera selection, camera semaphore
  ownership, background threads, capture sequencing, image saving, permissions,
  resources, dependencies, project metadata, or workflows.
- Keep this pull request stacked on PR #15 and preserve base-first ordering.
