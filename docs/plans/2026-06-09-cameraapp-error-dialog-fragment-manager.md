# CameraApp Error Dialog Fragment Manager Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep unsupported-camera recovery from crashing when a retained fragment is
detached before the error dialog is shown.

## Changes

- Resolved `getFragmentManager()` into a local `FragmentManager` before showing
  the unsupported-camera dialog.
- Showed the dialog only when the fragment manager is attached.
- Fell back to the existing generic camera-unavailable message when detached.
- Extended the SDK-free baseline and documentation to enforce the guard.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
