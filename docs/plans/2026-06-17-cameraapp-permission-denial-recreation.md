---
title: CameraApp Permission Denial Recreation
type: reliability
date: 2026-06-17
status: implemented
execution: code
---

# CameraApp Permission Denial Recreation

## Context

The hosted API 36 instrumentation proves that a fresh install can deny camera
permission without immediately reopening the permission dialog. The production
fragment is retained across configuration changes, but the maintained test ends
before recreating the activity. A regression that loses or ignores the denial
latch during recreation could therefore restore the re-prompt loop without
failing the current gate.

## Priorities

1. Prove camera-permission denial remains settled across activity recreation.
2. Add permission-grant and live-preview instrumentation on a camera-capable
   emulator once the hosted camera boundary is explicitly configured.
3. Execute still capture, rotation, interruption, storage delivery, and
   physical-device verification using `DEVICE_VERIFICATION.md`.

This change implements only priority 1. The later priorities require a broader
runtime fixture and must not be inferred from denial-only evidence.

## Requirements

- Extend the real permission-controller denial test rather than adding a
  callback-only unit or source simulation.
- Recreate `CameraActivity` after the denial callback has settled.
- Prove the recreated activity still owns a live camera fragment.
- Prove the retained fragment still records denial and has no pending camera
  permission request after recreation.
- Prove the permission dialog does not reappear after recreation.
- Keep the existing fresh-install denial precondition, bounded UI discovery,
  and post-denial permission assertion.
- Add mutation-sensitive baseline contracts for recreation, retained denial,
  settled request state, and no re-prompt assertion ordering.
- Keep the pinned API 36 emulator image and explicit local instrumentation
  skip behavior unchanged.

## Implementation

### Instrumentation lifecycle assertion

Update `Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java`
to recreate the active scenario after the current denial assertions, then
repeat the fragment-state and dialog-absence checks against the recreated
activity. Reuse the existing bounded helpers so the test continues to diagnose
missing callbacks and permission-controller UI clearly.

### Static contract

Update `scripts/check-baseline.sh` to require the recreation call and the
post-recreation denial, pending-request, dialog-absence, and fragment-liveness
assertions. The contract should reject removal or reordering that would make
the test pass without observing the recreated state.

### Documentation

Update `README.md`, `CHANGES.md`, and this plan after validation so they state
only that denial persistence across activity recreation is covered. Do not
claim permission grant, preview, capture, or physical-device coverage.

## Verification

- Run shell syntax and the focused baseline checker.
- Compile the instrumentation APK with JDK 17 and Android SDK 36.
- Run repository-root and external-directory `make check` with runtime
  instrumentation skipped locally only when the emulator boundary is absent.
- Reject isolated mutations to recreation and each post-recreation assertion.
- Audit the exact diff, generated artifacts, and credential-shaped additions.
- Require exact-head push and pull-request hosted instrumentation success.

## Verification Results

- Shell syntax and the focused baseline checker passed from the repository and
  an external working directory.
- The instrumentation APK compiled successfully with JDK 17, Android SDK 36,
  and Build Tools 36.1.0.
- Repository-root and external-directory `make check` passed with zero-finding
  debug/release lint, instrumentation APK assembly, and debug APK assembly.
  Runtime instrumentation was explicitly skipped locally because the host does
  not retain the pinned API 36 emulator image and audio runtime.
- Seven isolated mutations were rejected across recreation, retained denial,
  settled request state, dialog absence, fragment liveness, README scope, and
  plan-contract coverage.
- Exact-head hosted push and pull-request instrumentation remain pending until
  the implementation commit is pushed.

## Risks

- `ActivityScenario.recreate()` can expose timing assumptions in retained
  platform fragments; all post-recreation reads must remain bounded and run on
  the activity thread through the existing helpers.
- The hosted emulator still does not prove camera grant, preview, or capture.
- PR delivery remains stacked on the existing permission-denial branch and
  must not merge or close prior pull requests without authorization.
