# CameraApp Capture Failure Recovery

## Status: In Progress

## Context

The still-capture callback unlocks focus after a successful capture, but it does
not handle `onCaptureFailed`. A failed current-session capture can therefore
leave autofocus locked and the preview state machine stuck. Recovery must keep
the existing stale-session ownership boundary.

## Objectives

- Unlock focus after a still-capture failure from the current capture session.
- Ignore failed callbacks from closed or replaced sessions.
- Preserve successful capture behavior, image saving, and the existing AF/AE
  state machine.
- Make the ownership and recovery ordering mutation-sensitive in the SDK-free
  baseline.

## Scope

- Update `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`.
- Extend `scripts/check-baseline.sh` with still-capture failure ownership and
  recovery contracts.
- Document the failure-recovery boundary in `AGENTS.md`, `README.md`,
  `SECURITY.md`, `VISION.md`, and `CHANGES.md`.

## Verification

- `sh -n scripts/check-baseline.sh`
- Focused SDK-free baseline validation
- Repository-root and external-directory `make check`
- Isolated mutations removing or reordering the failure guard and recovery
- `git diff --check`
- Exact-path, generated-artifact, sensitive-value, conflict-marker, and
  file-mode audits

## Risks

- Failure recovery must reject stale session callbacks before calling
  `unlockFocus()`.
- Source validation cannot reproduce Android camera failure timing; emulator
  and physical-camera execution remain in the device verification matrix.
- This PR is stacked on PR #18 and must retain base-first merge ordering.

## Out Of Scope

- Capture retry policy, AF/AE heuristics, camera selection, image persistence,
  UI changes, dependency/toolchain upgrades, and workflow changes.
