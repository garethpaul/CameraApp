# CameraApp Toast Handler Lifecycle

## Status: Completed

## Goal

Prevent queued toast messages from retaining a detached camera fragment while
preserving UI-thread delivery.

## Problem

`Camera2BasicFragment` used an anonymous non-static `Handler`. Android lint
reports this pattern because the handler implicitly retains its enclosing
fragment and queued messages can extend that fragment's lifetime beyond its
view or activity attachment.

## Scope

- Replace the anonymous handler with a static handler class.
- Bind the handler explicitly to the main looper.
- Hold the fragment through `WeakReference` and skip delivery after collection
  or activity detachment.
- Preserve existing toast text and call sites.
- Extend the SDK-free baseline and maintenance documentation.

## Out Of Scope

- Changing camera behavior, message text, or error recovery.
- Modernizing the Android plugin, support libraries, SDK levels, or UI layout.
- Resolving unrelated resource, density, overdraw, RTL, or layout lint findings.

## Verification

- `make check` with Java 8 and the configured Android SDK
- Android lint for debug and release variants
- `sh -n scripts/check-baseline.sh`
- Targeted handler lifecycle mutation checks
- `git diff --check`

The Android build and lint gate pass locally. Camera lifecycle behavior still
requires emulator or physical-device validation.
