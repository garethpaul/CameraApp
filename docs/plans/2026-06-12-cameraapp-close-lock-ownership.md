# CameraApp Camera Close Lock Ownership

## Status: Completed

## Goal

Keep the camera open/close semaphore balanced when `closeCamera()` is
interrupted before it acquires the permit.

## Problem

`closeCamera()` currently releases `mCameraOpenCloseLock` unconditionally in a
`finally` block. If the interruptible `acquire()` throws before ownership is
obtained, the release adds an extra permit. Later open and close operations can
then enter concurrently, defeating the semaphore's lifecycle serialization.
The catch also propagates failure without restoring the thread interrupt flag.

## Scope

- Track whether `closeCamera()` actually acquired the camera semaphore.
- Release the permit only while the close path owns it.
- Restore the current thread's interrupt status before propagating the existing
  runtime failure.
- Extend the SDK-free baseline and maintenance documentation for the ownership
  contract.

## Out Of Scope

- Changing camera close order, timeouts, preview behavior, or capture state.
- Modernizing Gradle, Android SDK, support libraries, or Camera2 APIs.
- Adding device-only camera instrumentation tests.

## Verification

- `make check`
- `sh -n scripts/check-baseline.sh`
- Targeted baseline mutation checks
- `git diff --check`

Live Camera2 lifecycle verification still requires Android hardware or an
emulator with camera support.
