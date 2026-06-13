---
title: CameraApp Landscape Preview Separation
type: fix
status: planned
date: 2026-06-13
---

# CameraApp Landscape Preview Separation

## Status: Planned

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

## Verification Plan

- Run focused `make lint`, then `make check` and `make verify` with the configured
  Android SDK and checked-in Gradle wrapper.
- Run absolute-path `make check` from `/tmp`, `sh -n`, and `git diff --check`.
- Parse lint XML to confirm 10 issues per variant and no `RelativeOverlap` ID.
- Require isolated hostile mutations of IDs, dimensions, anchors, removed
  constraints, lint evidence, and documentation to fail.
- Record emulator, physical-device camera, and rendered screenshot verification
  as unavailable rather than inferred.
