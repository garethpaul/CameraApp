# CameraApp Texture Resume Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep retained fragment resume events from starting camera work before the
`AutoFitTextureView` has been recreated.

## Changes

- Added an `onResume()` guard that returns when `mTextureView` is not available.
- Kept background-thread startup behind the texture-view guard so camera work is
  tied to the recreated view hierarchy.
- Extended the SDK-free baseline, README, changelog, and vision with the resume
  lifecycle contract.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Gradle lint/build verification uses the configured Android SDK; device camera
verification still requires Android hardware or an emulator with camera support.
