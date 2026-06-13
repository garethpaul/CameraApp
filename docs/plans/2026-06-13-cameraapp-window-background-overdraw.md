---
title: CameraApp Window Background Ownership
type: performance
status: planned
date: 2026-06-13
---

# CameraApp Window Background Ownership

## Status: Planned

## Problem Frame

Android lint reports `Overdraw` because `activity_camera` paints an opaque black
root background over the default light theme window background. Both layers
cover the full activity, so every frame begins with a redundant full-screen
paint even though the intended launch and camera fallback surface is simply
black.

## Scope Boundaries

- Preserve the black launch/fallback surface, fullscreen no-action-bar theme,
  camera fragment, portrait and landscape layouts, controls, icons, and Java
  behavior.
- Move background ownership only; do not make the activity transparent.
- Leave the active icon set and its `IconMissingDensityFolder` warning for a
  separate asset-quality change.
- Do not update Gradle, SDK levels, dependencies, application metadata, or
  camera lifecycle code.
- Do not claim emulator, physical-device camera, or rendered screenshot coverage.

## Requirements

- R1. `MaterialTheme` must own an opaque black `android:windowBackground`.
- R2. `activity_camera` must not paint its own root background.
- R3. Android lint must report only the existing
  `IconMissingDensityFolder` warning for debug and release.
- R4. Debug APK assembly and the repository static baseline must pass.
- R5. Static contracts must reject a restored root background, a missing or
  non-black window background, stale plan status, or missing verification
  evidence.
- R6. Maintenance documentation must describe the single background owner and
  link this completed plan.

## Implementation

1. Expand `MaterialTheme` and set `android:windowBackground` to black.
2. Remove the redundant black background from the activity root container.
3. Add exact theme, layout, documentation, and completed-plan contracts to the
   SDK-free checker.
4. Record the reduced lint result without weakening lint configuration.

## Verification

- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make lint`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make test`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make build`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make check`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make verify`
- External-working-directory `make check`
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated hostile mutations for a restored root background, missing theme
  background, non-black theme background, stale completion status, and missing
  verification evidence must each fail the checker.
