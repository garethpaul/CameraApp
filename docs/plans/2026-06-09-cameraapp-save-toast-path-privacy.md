# CameraApp Save Toast Path Privacy

Status: Completed
Date: 2026-06-09

## Goal

Keep successful capture UI from exposing the app-private file path used for the
saved JPEG.

## Changes

- Replaced the `Saved: <file>` toast with generic saved-copy.
- Added an SDK-free baseline guard that rejects file-path save toasts.
- Documented the saved-toast privacy contract in the README, changelog, and
  vision.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`

Gradle lint/build verification uses the configured Android SDK; device camera
verification still requires Android hardware or an emulator with camera support.
