# CameraApp Save Success Notification

Status: Completed

## Problem

The still-capture callback displays `Picture saved` as soon as Camera2 reports
capture completion. The background `ImageSaver` has not opened or written the
destination file at that point, so file creation, write, or close failures are
reported to the user as successful saves.

## Requirements

1. Remove the success notification from Camera2 capture completion.
2. Notify the existing weak main-thread handler only after the JPEG file stream
   closes without error.
3. Do not report success for missing image state, missing planes or buffers,
   file-open failures, write failures, close failures, or rejected handler
   handoff.
4. Preserve exact-once `Image` closure, background file I/O, camera focus
   recovery, output path privacy, image format, capture sequencing, and weak
   fragment ownership.
5. Add mutation-sensitive portable contracts and truthful verification
   evidence without claiming emulator or physical-camera execution.

## Implementation Units

### 1. Transfer result-handler ownership

Files:

- `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`

Pass the existing weak main-thread message handler into `ImageSaver` when the
background handler accepts the save runnable.

### 2. Gate success on completed file output

Files:

- `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`
- `scripts/check-baseline.sh`

Use scoped file-output ownership, keep image closure in `finally`, and enqueue
the success message only after the output resource closes successfully.

### 3. Document the user-visible contract

Files:

- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`
- `docs/plans/2026-06-14-cameraapp-save-success-notification.md`

Record that capture completion and durable file-write success are separate
events and that only the latter produces the success notification.

## Verification

- Run `sh -n scripts/check-baseline.sh` and the focused portable checker.
- Run SDK-backed `make check` from the repository root and an unrelated working
  directory with the configured JDK 17 and Android 16 toolchain.
- Reject isolated mutations for premature notification, missing result-handler
  transfer, success before output close, success on I/O failure, missing image
  closure, documentation drift, and incomplete plan evidence.
- Audit the exact intended diff, generated Gradle artifacts, whitespace,
  conflict markers, and credential-shaped additions.

## Verification Completed

- `sh -n scripts/check-baseline.sh` and the focused portable checker passed.
- SDK-backed repository-root and external-directory `make check` passed with
  JDK 17, SDK 36, Build Tools 36.1.0, zero-finding debug/release lint,
  instrumentation APK assembly, and debug app APK assembly.
- Seven isolated mutations were rejected for premature notification, missing
  result-handler transfer, success before cleanup, success on I/O failure,
  missing image closure, documentation drift, and reopened plan status.
- Exact diff, generated-artifact, whitespace, conflict-marker, and
  credential-pattern audits passed.
- No camera hardware, storage-failure injection, emulator, or physical-device
  scenario was executed.

## Scope Boundaries

- Do not change filenames, storage location, JPEG bytes, image-reader capacity,
  camera state transitions, focus recovery, permissions, dependencies, or UI
  text.
- Do not claim camera hardware, storage-failure injection, emulator, or physical
  device execution.
- Do not merge or close stacked pull requests without explicit authorization.
