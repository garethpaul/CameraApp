# CameraApp ImageReader Backpressure Guard

## Status: Completed

## Goal

Prevent still-image callbacks from crashing when `ImageReader` cannot hand out
another image because previous captures have not been released yet.

## Scope

- Catch `IllegalStateException` around `acquireNextImage()`.
- Drop the backed-up frame without touching saved-image contents or capture UI.
- Keep existing image, file, plane, and buffer guards intact.
- Extend the SDK-free baseline and docs for the backpressure guard.

## Out Of Scope

- Changing the Camera2 capture state machine or preview behavior.
- Changing storage location, filename, or image format.
- Adding emulator/device camera verification on this host.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
