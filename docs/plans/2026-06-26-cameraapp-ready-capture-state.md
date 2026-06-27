# CameraApp Ready Capture State

Status: Completed
Date: 2026-06-26

## Context

The autofocus-unavailable and exposure-converged branches submit a still image
immediately, but they first publish `STATE_WAITING_NON_PRECAPTURE`. The next
partial or total result can therefore enter that state and submit a second
still capture before the first completion restores preview.

## Decision

- Publish `STATE_PICTURE_TAKEN` immediately before each still submission that
  is already ready to capture.
- Keep `STATE_WAITING_NON_PRECAPTURE` only for the actual AE precapture path.
- Preserve session ownership guards, capture failure recovery, image handoff,
  and preview restart behavior.
- Add an SDK-free source contract requiring both ready branches to use the
  terminal capture state directly adjacent to submission.

## Verification

- The source baseline failed first on both incorrect ready-branch states.
- The corrected baseline requires exactly two adjacent picture-taken
  transitions in `STATE_WAITING_LOCK` and rejects waiting-state substitutions.
- Root/external `make check`, API 36 build/lint/instrumentation assembly,
  CodeQL, trusted exact-byte verification, and exact-head review remain merge
  gates.
- Physical AF-unavailable and already-converged AE behavior remains in
  `DEVICE_VERIFICATION.md`; no unexecuted camera run is claimed.
