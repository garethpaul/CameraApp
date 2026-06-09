# CameraApp Control Binding Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep fragment view creation resilient when picture or info controls are missing
from a layout variant by avoiding unconditional listener binding.

## Changes

- Resolved the picture and info controls into local variables.
- Installed listeners only when each control is present in the current layout.
- Extended the SDK-free baseline and documentation to enforce the control
  binding guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
