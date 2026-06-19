---
title: CameraApp RTL Layout Anchors
type: fix
date: 2026-06-13
---

# CameraApp RTL Layout Anchors

## Summary

Enable RTL support and replace physical right-side layout attributes with
logical end-side attributes so camera controls preserve their intended
placement in both left-to-right and right-to-left locales.

## Problem Frame

Android lint reports two `RtlHardcoded` warnings: the portrait info button uses
`right` gravity and the landscape control panel is positioned `toRightOf` the
camera texture. The application targets API 21, where the equivalent logical
`end` attributes and the application-level RTL declaration are supported.

## Requirements

- R1. The portrait info button must use end-side gravity while remaining
  vertically centered.
- R2. The landscape control panel must be positioned after the camera texture
  with `layout_toEndOf`.
- R3. The application must explicitly enable RTL resource mirroring.
- R4. View IDs, dimensions, colors, camera bindings, and left-to-right visual
  placement must remain unchanged.
- R5. The static baseline must reject restoration of physical right-side
  attributes and Android lint must report 11 findings per variant with no RTL
  issue IDs.

## Key Technical Decisions

- **Use platform logical attributes:** `end` and `layout_toEndOf` are native at
  the repository's API 21 minimum and require no compatibility helper.
- **Declare RTL support explicitly:** `android:supportsRtl="true"` matches the
  logical attributes and prevents legacy lint from treating RTL behavior as
  undeclared.
- **Limit the patch to the two lint findings:** Overdraw, unused resources,
  density coverage, parent structure, and overlap warnings need separate
  behavior-aware changes.
- **Keep both layout variants structurally intact:** Only direction-sensitive
  attributes change, avoiding camera preview or control hierarchy churn.

## Implementation Units

### U1. Replace Physical Right-Side Anchors

- **Files:** `Application/src/main/AndroidManifest.xml`,
  `Application/src/main/res/layout/fragment_camera2_basic.xml`,
  `Application/src/main/res/layout-land/fragment_camera2_basic.xml`
- **Goal:** Use logical end-side positioning without changing IDs, sizes, or
  hierarchy, and declare RTL mirroring at the application boundary.
- **Covers:** R1, R2, R3, R4

### U2. Add Static And Maintenance Contracts

- **Files:** `scripts/check-baseline.sh`, `README.md`, `CHANGES.md`, `VISION.md`
- **Goal:** Require the logical attributes, reject physical right-side drift,
  and document the remaining device-validation boundary.
- **Covers:** R5

## Verification

- Run the focused static checker, root `make check`, and the external-directory
  wrapper with the configured Android SDK.
- Run Gradle lint and confirm both debug and release variants report 11 issues,
  with no `RtlHardcoded` entries.
- Assemble the debug APK and run shell syntax and diff checks.
- Apply isolated hostile mutations for each logical attribute and supporting
  documentation contract; each mutation must fail the checker.
- Do not claim emulator, physical-device, camera-session, or visual screenshot
  coverage when those environments are unavailable.

## Risks

- Right-to-left placement is verified by Android resource semantics and lint,
  not by a rendered device screenshot.
- Other existing lint findings remain intentionally out of scope.
