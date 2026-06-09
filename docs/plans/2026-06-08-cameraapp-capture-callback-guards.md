---
title: CameraApp Capture Callback Guards
type: fix
status: completed
date: 2026-06-08
---

# CameraApp Capture Callback Guards

## Summary

Harden the legacy Camera2 sample against null callback state that can appear
when autofocus metadata is missing or retained-fragment camera state has been
closed during lifecycle transitions.

## Requirements

- R1. Camera2 autofocus state must be handled as nullable metadata.
- R2. Preview session creation must return safely when texture, camera, image
  reader, or preview size state is unavailable.
- R3. Focus, precapture, still capture, and focus-unlock paths must guard closed
  capture sessions and request builders.
- R4. JPEG image saving must guard missing image planes before reading buffers.
- R5. The SDK-free baseline script must guard these lifecycle checks.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
