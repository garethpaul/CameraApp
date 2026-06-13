# Complete CameraApp Xxxhdpi Icons

Status: In Progress

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
- `AGENTS.md`
- `README.md`
- `CHANGES.md`
- `VISION.md`

Protect resource presence, dimensions, zero-finding lint evidence, and the
completed plan without changing runtime code.

## Verification

Verification: Pending

- Run the SDK-free checker and focused icon dimension checks.
- Run the full SDK-backed `make check` with an explicit timeout.
- Run focused hostile mutations for resource removal, dimensions, docs, and
  completed plan evidence.
- Inspect the exact diff, generated artifacts, and credential-shaped additions.

## Scope Boundaries

- Do not replace existing density assets or change the application icon design.
- Do not suppress or disable Android lint.
- Do not claim emulator or physical-device visual verification.
