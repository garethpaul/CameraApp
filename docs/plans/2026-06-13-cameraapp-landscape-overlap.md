---
title: CameraApp Landscape Preview Separation
type: fix
status: completed
date: 2026-06-13
---

# CameraApp Landscape Preview Separation

## Status: Completed

## Problem Frame

Android lint reports `RelativeOverlap` in the landscape camera layout. The
control panel is full-width while constrained both below and to the end of a
wrap-content texture view, so localized control growth can overlap the preview
instead of reserving a separate end-side rail.

## Scope Boundaries

- Preserve picture/info IDs, text, icons, padding, blue control background,
  camera preview class, portrait layout, Java bindings, RTL mirroring, and
  capture behavior.
- Change only landscape resource constraints and supporting static/docs
  contracts; do not update Gradle, SDK, dependencies, Java, or assets.
- Use API 21 logical start/end attributes so left-to-right and right-to-left
  layouts reserve the same non-overlapping regions.
- Do not claim emulator, physical-device camera, or rendered screenshot coverage
  when those environments are unavailable.

## Implementation Units

### U1: Give The Landscape Control Rail Independent Bounds

Files:

- Modify `Application/src/main/res/layout-land/fragment_camera2_basic.xml`

Approach:

- Give the control `FrameLayout` a stable ID, wrap-content width, and full
  parent height while keeping it aligned to the logical end.
- Make the texture fill the parent area before the control rail with
  `layout_toStartOf` and match-parent dimensions.
- Remove the conflicting `layout_below` and `layout_toEndOf` constraints.

### U2: Extend SDK-Backed And Static Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Require exactly one control-rail ID, logical preview-to-controls anchor,
  end-aligned rail, non-overlapping dimensions, and absence of the old
  conflicting constraints.
- Require Android lint to report 10 findings per debug/release variant with no
  `RelativeOverlap` issue and preserve all existing RTL contracts.
- Record completed plan, hostile mutation, assembly, and limited visual
  verification evidence.

## Verification

- Focused Gradle lint, `make check`, and `make verify` passed with the configured
  Android SDK and checked-in Gradle wrapper.
- Debug APK assembly and absolute-path `make check` from `/tmp` passed.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Lint reported 10 issues per debug/release variant with zero `RelativeOverlap`
  findings; the remaining IDs are unchanged overdraw, unused-resource,
  density, and useless-parent findings.
- Ten isolated hostile mutations were rejected across preview width/height,
  logical anchor, AAPT-compatible ID declaration, control ID/width/height,
  removed below constraint, README evidence, and lint evidence.
- Tooling is unavailable; no emulator, physical-device camera, or rendered
  screenshot coverage is claimed.
