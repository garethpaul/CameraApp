# Complete CameraApp Xxxhdpi Icons

Status: Completed

## Context

Android lint reports `IconMissingDensityFolder` for both debug and release
because the active launcher and info icon families stop at `xxhdpi`. Xxxhdpi
devices therefore scale lower-density assets at runtime.

## Requirements

- R1. Add exact-size `xxxhdpi` launcher and info icons derived from the existing
  reviewed assets.
- R2. Preserve every existing icon, application behavior, layout, and build
  target.
- R3. Require the active icon family and exact 192x192 launcher and 128x128 info
  dimensions in the SDK-free checker.
- R4. Run Android lint for debug and release and require zero findings without
  suppression.
- R5. Add mutation-sensitive static contracts and record exact local and hosted
  verification.

## Implementation Units

### 1. Xxxhdpi resources

Files:

- `Application/src/main/res/drawable-xxxhdpi/ic_launcher.png`
- `Application/src/main/res/drawable-xxxhdpi/ic_action_info.png`

Generate deterministic exact-size PNGs from the existing high-resolution
launcher source and reviewed `xxhdpi` info icon.

### 2. Baseline and guidance

Files:

- `scripts/check-baseline.sh`
- `Makefile`
- `AGENTS.md`
- `README.md`
- `CHANGES.md`
- `VISION.md`

Protect resource presence, dimensions, zero-finding lint evidence, and the
completed plan without changing runtime code.

## Verification

Verification: Completed

- Direct SDK-backed Gradle lint reports zero Android lint findings for both
  debug and release variants.
- The generated launcher and info PNGs are exactly 192x192 and 128x128, and the
  SDK-free baseline pins their reviewed SHA-256 digests.
- Full SDK-backed `make check` passes with zero Android lint findings and a
  successful debug APK assembly.
- Eight focused hostile mutations remove or corrupt either icon, substitute a
  lower-density launcher, remove or weaken zero-lint enforcement, delete
  documentation evidence, or stale the plan status; every mutation is rejected.
- Exact-diff review, generated artifact inspection, and credential-shaped
  addition scanning are completed before the implementation commit.

## Work Completed

- Added the missing `drawable-xxxhdpi` launcher and info resources.
- Derived the launcher from the existing 576px source and the info icon from the
  reviewed `xxhdpi` asset using deterministic bicubic scaling.
- Made SDK-backed `make lint` reject any issue entry in the generated XML report.
- Added static presence, digest, dimension, documentation, and completed-plan
  contracts without suppressing Android lint.

## Scope Boundaries

- Do not replace existing density assets or change the application icon design.
- Do not suppress or disable Android lint.
- Do not claim emulator or physical-device visual verification.
