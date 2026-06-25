# CameraApp Preview Session Recovery

Status: Completed design; exact policy bootstrap required before merge.

## Problem

`onConfigured()` publishes `mCaptureSession`, `mPreviewRequestBuilder`, and the
built preview request before `setRepeatingRequest()` completes. A synchronous
camera-access, closed-session, or invalid-request failure can therefore leave a
failed session and unusable request state published as current.

## Requirements

- Preserve current-session publication before repeating callbacks can arrive.
- On synchronous startup failure, clear shared fields only when the callback
  still owns `mCaptureSession`.
- Close the failed callback-owned session after clearing shared state.
- Preserve generic diagnostics without exception details or private paths.
- Bind the exact semantic files through the base-owned trusted verifier before
  merging the one-commit repair.

## Implementation

- Catch `CameraAccessException`, `IllegalStateException`, and
  `IllegalArgumentException` around preview request configuration/submission.
- Guard cleanup with `mCaptureSession == cameraCaptureSession`.
- Clear the session, builder, and request before closing the failed session.
- Enforce unique markers and ordering in `scripts/check-baseline.sh`.

## Verification

- RED: the source baseline rejected the missing preview ownership guard.
- Require hostile marker/order mutations, SDK-free baseline, trusted-verifier
  tests, exact-child receipt, full Android/API 36 hosted checks, CodeQL, and
  exact-head Codex review before merge.
