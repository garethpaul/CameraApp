---
title: CameraApp Permission Denial Instrumentation
type: reliability
date: 2026-06-16
status: completed
execution: code
---

# CameraApp Permission Denial Instrumentation

## Context

The hosted API 36 emulator now executes the CameraApp instrumentation suite,
but the maintained smoke test stops after confirming that the camera fragment
is installed before runtime permission is granted. The production denial path
therefore remains covered only by source contracts.

## Requirements

- Assert camera permission is denied on the fresh hosted install before the
  denial test launches the activity. Do not revoke from inside instrumentation,
  because revocation may terminate the target process under test.
- Drive the real API 36 permission-controller denial action rather than
  invoking the fragment callback directly.
- Prove the application processes the denial by observing a bounded denial
  callback state instead of relying only on accessibility-node disappearance.
- Prove the application settles the pending request and does not immediately
  re-request camera permission after denial.
- Assert that the activity and camera fragment remain alive after denial.
- Bound permission-controller discovery and fail with useful UI evidence when
  the expected denial action is unavailable.
- Keep the existing pre-permission startup smoke test.
- Add mutation-sensitive static contracts for dependency wiring, permission
  revocation, real denial interaction, bounded discovery, and post-denial
  assertions.
- Preserve the pinned emulator image, production permission behavior, and
  explicit local instrumentation skip.

## Verification

- Run shell syntax and the focused baseline checker.
- Run the full repository and external-directory gates with instrumentation
  skipped only for local validation.
- Reject isolated mutations to the denial interaction and its static
  contracts.
- Audit the exact diff, generated artifacts, and credential-shaped additions.
- Require exact-head push and pull-request hosted instrumentation success.

## Verification Results

- The instrumentation APK compiled successfully with Temurin 17 and Android
  SDK 36, including the UI Automator denial interaction.
- Shell syntax and the focused static contracts passed after implementation.
- Local emulator execution remains unavailable because the API 36 system image
  is not installed and the host emulator binary lacks `libpulse.so.0`.
- Exact-head push run `27656010921` and pull-request run `27656012503` both
  passed the full hosted instrumentation gate after the denial-latch fix.
- Initial exact-head push run `27655294552` passed, while pull-request run
  `27655300169` exposed a flaky accessibility-node disappearance assertion
  after the real deny click.
- Follow-up push run `27655608720` and pull-request run `27655610454` both
  showed that the request remained pending after the deny action. Production
  path inspection identified that the denial callback cleared the pending state
  before resume logic immediately requested camera permission again. The new
  follow-up records a fragment-lifetime denial latch, waits for that callback
  state, asserts the request is settled, and proves that no replacement
  permission dialog appears.
- The follow-up instrumentation APK compiled with Temurin 17 and Android SDK
  36. Repository-root and external-directory `make check` passed with only the
  documented local instrumentation skip.
- Six isolated hostile mutations were rejected across the production denial
  guard, denial latch, callback wait, settled-request assertion, no-reprompt
  assertion, and plan evidence.
- PR #24 was confirmed OPEN, CLEAN, and MERGEABLE at exact implementation head
  `0af9dcf0be82dec5ad4844f922e83a4f3d218eb0` after both canonical events passed.

## Scope Boundary

This change proves runtime camera permission denial on the pinned API 36
Google APIs emulator. It does not prove permission grant, camera preview,
still capture, rotation, lifecycle interruption, or physical-device behavior.
