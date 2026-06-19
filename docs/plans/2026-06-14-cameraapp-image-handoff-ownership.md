# CameraApp Image Handoff Ownership

Status: Completed

## Problem

The still-image callback acquires an `Image` and posts an `ImageSaver` to the
camera background handler. `Handler.post` can reject that runnable while its
looper is shutting down. The current callback ignores the return value, so in
that lifecycle race neither the callback nor a runnable closes the acquired
image, consuming one of the `ImageReader`'s two slots.

## Requirements

1. Snapshot the current background handler before transferring image ownership.
2. Close the acquired image immediately when the saving runnable is rejected.
3. Preserve successful save ownership, file selection, JPEG bytes, reader
   capacity, camera state, lifecycle order, and user-visible behavior.
4. Add mutation-sensitive static contracts for handler ownership, post-result
   handling, exact cleanup, documentation, and completed plan evidence.
5. Run the full SDK-backed repository gate from the repository root and an
   unrelated working directory.

## Scope Boundaries

- Do not change image format, dimensions, filename, storage location, reader
  capacity, capture sequencing, permissions, dependencies, or UI.
- Do not claim camera hardware or shutdown-race runtime injection.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Debug and release Java compilation passed with the repository's Temurin 17
  and Android 16 toolchain.
- Six hostile mutations were rejected for missing handler snapshot ownership,
  ambient-handler reuse, inverted or ignored post failure, removed image close,
  documentation drift, and reopened plan status.
- SDK-backed `make check` passed from the repository root and an unrelated
  working directory, including zero-finding debug/release lint, app Java
  compilation, instrumentation APK assembly, and debug app APK assembly.
- Camera hardware and shutdown-race runtime injection were not exercised.
