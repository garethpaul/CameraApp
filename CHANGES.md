# CameraApp Changes

## 2026-06-09

- Guarded `ImageReader.acquireNextImage()` against backpressure exceptions so
  backed-up still-image callbacks are dropped instead of crashing capture.
- Extended the SDK-free baseline and README notes for ImageReader
  backpressure handling.

## 2026-06-08

- Added `make check` as the root wrapper for CameraApp source, lint, and
  debug build verification.
- Made camera background-thread startup idempotent to avoid duplicate handler
  threads during repeated lifecycle starts.
- Guarded Camera2 autofocus, preview session, still capture, and image-plane
  paths against null lifecycle state.
- Added a changelog for repository maintenance.
- Restored README verification notes for the legacy Android build hygiene baseline.
- Extended the baseline script to require changelog and documented Gradle verification commands.
