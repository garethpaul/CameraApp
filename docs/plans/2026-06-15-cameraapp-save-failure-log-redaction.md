# Camera Save Failure Log Redaction

Status: Completed

## Problem

The capture UI no longer exposes the app-private output path, but `ImageSaver`
still prints the full `IOException` stack trace when file creation, writing, or
closing fails. Those exception details can include the private capture path in
logcat, bypassing the existing privacy boundary.

## Requirements

1. Replace throwable-bearing image-save failure output with one generic error
   message.
2. Keep save failure state false so no success message is sent.
3. Preserve image closure, file output ordering, success-only notification,
   capture sequencing, and background-thread ownership.
4. Add method-scoped mutation-sensitive contracts and synchronized guidance.
5. Record truthful portable and Android validation evidence.

## Implementation Units

### 1. Redact save failures

File:

- `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`

Log a fixed image-save failure category without the exception object, message,
stack trace, or output file path.

### 2. Protect the boundary

Files:

- `scripts/check-baseline.sh`
- `docs/plans/2026-06-15-cameraapp-save-failure-log-redaction.md`

Require one generic save-failure log inside `ImageSaver`, reject
`printStackTrace` and throwable-bearing logging in that scope, and preserve
failure-before-close-before-success ordering.

### 3. Document privacy behavior

Files:

- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`

Record that image-save failures log a generic category without exception or
private output-path details.

## Verification Completed

- `sh -n` and the focused portable baseline passed.
- Six isolated mutations were rejected for stack traces, throwable-bearing
  logging, missing generic logging, late failure state, guidance, and completed
  plan evidence.
- Repository and external-directory `make check` passed with Amazon Corretto
  17.0.19, SDK 36, and build-tools 36.1.0. Debug/release lint produced zero
  findings, and instrumentation plus app APK assembly succeeded.

## Scope Boundaries

- Do not change camera setup, capture state transitions, image bytes, output
  location, success notification text, handler ownership, or image closure.
- Do not broadly rewrite other legacy camera exception handling in this change.
- Do not claim emulator, physical camera, permission, preview, or live capture
  execution without evidence.
- Do not merge or close any pull request without explicit authorization.
