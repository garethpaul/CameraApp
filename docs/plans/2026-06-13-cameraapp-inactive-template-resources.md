---
title: CameraApp Inactive Template Resource Pruning
type: maintenance
status: completed
date: 2026-06-13
---

# CameraApp Inactive Template Resource Pruning

## Status: Completed

## Problem Frame

Android lint reports eight findings from an unreachable Android sample-template
screen: an unused `activity_main` layout, its unused dimensions, its widget
styles, and a `tile.9.png` asset missing density variants. `CameraActivity`
inflates only `activity_camera`, so packaging this scaffold increases APK and
maintenance surface without participating in the camera flow.

## Scope Boundaries

- Preserve the manifest's active `MaterialTheme`, `intro_message`, all active
  camera layouts, Java behavior, Gradle configuration, SDK levels, and icons.
- Remove only resources reachable exclusively from unused `activity_main`.
- Do not alter the remaining `Overdraw` finding; visual background ownership
  requires a separate rendered-layout decision.
- Do not claim emulator, physical-device camera, or screenshot validation.

## Requirements

- R1. Remove the unused `activity_main` layout.
- R2. Remove template-only dimensions and the tablet overrides that reference
  them.
- R3. Remove the inactive `AppTheme`, `Theme.Sample`, `Theme.Base`, and
  sample-message style hierarchy while retaining active `MaterialTheme`.
- R4. Remove `tile.9.png` after its sole style reference is removed.
- R5. Android lint must report exactly two findings per variant: `Overdraw` and
  the active icon set's existing `IconMissingDensityFolder` warning.
- R6. Debug APK assembly and the repository static baseline must pass.
- R7. Static contracts must reject restoration of any pruned template resource,
  removal of `MaterialTheme`, stale plan status, or missing verification evidence.

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

## Work Completed

- Removed the unreachable `activity_main` layout, template dimension files,
  inactive theme/widget style hierarchy, and sole tile asset.
- Preserved the manifest's active `MaterialTheme`, dialog `intro_message`, camera
  layouts, Java behavior, Gradle configuration, SDK levels, and active icons.
- Added SDK-free contracts for all pruned paths, removed references, active theme
  ownership, documentation, and completed plan evidence.
- Updated maintenance documentation without changing camera behavior or build
  dependencies.

## Verification Completed

- SDK-backed `make lint`, `make test`, `make build`, `make check`, and
  `make verify` passed.
- Android lint reported 2 issues for both debug and release: `Overdraw` and
  `IconMissingDensityFolder`; all eight template-owned findings were removed.
- Debug APK assembly passed with the legacy Android Gradle toolchain.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Five isolated hostile source mutations were rejected: restored layout,
  dimensions, styles, tile asset, and removed active theme.
- Two isolated hostile plan mutations were rejected: stale completion status
  and missing mutation-verification evidence.
- No emulator, physical-device camera, or rendered screenshot coverage is
  claimed.
