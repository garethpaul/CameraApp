# CameraApp Open Callback Publication

Status: Completed
Date: 2026-06-26

## Problem

`CameraDevice.StateCallback.onOpened` currently releases the camera open/close
semaphore before publishing the opened device or submitting preview-session
creation. `onPause` can therefore acquire the semaphore, observe no shared
device, finish closing, and then allow the callback to publish and use a camera
after the fragment has paused.

Android documents `onOpened` as the point where the device becomes ready for
capture-session creation, and documents that calls after device closure can
fail. The semaphore boundary must therefore include shared-device publication
and the synchronous preview-session submission.

## Decision

- Publish the callback-owned device before beginning preview setup.
- Keep the callback's transferred semaphore ownership through synchronous
  preview-session submission.
- Release callback ownership from a `finally` block so every synchronous
  return or failure leaves camera closing unblocked.
- Preserve the existing one-shot atomic release token for later disconnect and
  error callbacks.

## Verification

- Add a RED SDK-free source contract for publication, preview submission, and
  `finally`-guarded release ordering.
- Reject isolated mutations that release before publication, release before
  preview submission, or remove the `finally` release boundary.
- Run `scripts/check-baseline.sh`, root and external-directory `make check`,
  `git diff --check`, hosted API 36 verification, CodeQL, and exact-head review.
- No physical camera is available locally, so pause-during-open runtime
  confirmation remains in the device verification matrix.

## Results

- RED: the source baseline rejected callback lock release before opened-device
  publication and synchronous preview-session submission.
- GREEN: `scripts/check-baseline.sh`, root Make authority, external-directory
  baseline execution, eight trusted-verifier tests, shell syntax, policy JSON,
  and `git diff --check` pass.
- Three isolated mutations were rejected: release before publication, release
  before preview submission, and removal of the `finally` release boundary.
- Full local Android verification stopped at the explicit toolchain gate because
  this runner has JDK 21 and no Android SDK; hosted JDK 17, API 36, Build Tools
  36.1.0, instrumentation, and CodeQL remain required before merge.
- No physical camera was available; pause-during-open runtime confirmation
  remains in the exact-head device verification matrix.
