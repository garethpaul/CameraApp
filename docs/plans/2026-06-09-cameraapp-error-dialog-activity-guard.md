# CameraApp Error Dialog Activity Guard

Status: Completed

## Context

The unsupported-camera fallback already checks for an attached fragment manager
before showing `ErrorDialog`, but showing the dialog also depends on having an
attached activity available for alert construction. Retained fragment lifecycle
races can leave the fallback without a usable activity.

## Plan

- Require both an attached activity and fragment manager before showing
  `ErrorDialog`.
- Fall back to the generic unavailable toast when either attachment dependency
  is missing.
- Preserve the existing dialog implementation for attached fragments.
- Extend the SDK-free baseline and maintenance docs for the attached-activity
  requirement.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
- `make check`
