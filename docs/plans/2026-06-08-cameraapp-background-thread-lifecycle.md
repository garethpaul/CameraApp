---
title: CameraApp Background Thread Lifecycle
type: fix
status: completed
date: 2026-06-08
---

# CameraApp Background Thread Lifecycle

## Summary

Make Camera2 background-thread startup idempotent so repeated lifecycle starts
do not replace or leak an already-running handler thread.

## Requirements

- R1. `startBackgroundThread()` returns early when the background thread already exists.
- R2. Background-thread shutdown remains null-safe.
- R3. Existing Camera2 callback and image-save guards remain in place.
- R4. README and changelog notes document the lifecycle guard.
- R5. The SDK-free baseline verifies the source-level guard.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
