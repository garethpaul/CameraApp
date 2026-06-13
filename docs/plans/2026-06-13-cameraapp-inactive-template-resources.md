---
title: CameraApp Inactive Template Resource Pruning
type: maintenance
status: planned
date: 2026-06-13
---

# CameraApp Inactive Template Resource Pruning

## Status: Planned

## Problem Frame

Android lint reports nine findings from an unreachable Android sample-template
screen: an unused `activity_main` layout, its unused dimensions, its widget
styles, and a `tile.9.png` asset missing density variants. `CameraActivity`
inflates only `activity_camera`, so packaging this scaffold increases APK and
maintenance surface without participating in the camera flow.

## Scope Boundaries

- Preserve `AppTheme`, `Theme.Sample`, `Theme.Base`, `intro_message`, all active
  camera layouts, Java behavior, Gradle configuration, SDK levels, and icons.
- Remove only resources reachable exclusively from unused `activity_main`.
- Do not alter the remaining `Overdraw` finding; visual background ownership
  requires a separate rendered-layout decision.
- Do not claim emulator, physical-device camera, or screenshot validation.

## Requirements

- R1. Remove the unused `activity_main` layout.
- R2. Remove template-only dimensions and the tablet overrides that reference
  them.
- R3. Remove sample-message widget styles while retaining the active app theme.
- R4. Remove `tile.9.png` after its sole style reference is removed.
- R5. Android lint must report exactly one finding per variant: `Overdraw`.
- R6. Debug APK assembly and the repository static baseline must pass.
- R7. Static contracts must reject restoration of any pruned template resource,
  removal of `AppTheme`, stale plan status, or missing verification evidence.

## Verification

- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make lint`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make test`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make build`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make check`
- `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make verify`
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated hostile mutations must be rejected for each resource-restoration class,
  removed active theme, stale completion status, and missing evidence.
