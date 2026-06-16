---
title: CameraApp Permission Denial Instrumentation
type: reliability
date: 2026-06-16
status: pending_hosted_validation
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
- Prove the application processes the denial by observing the bounded pending
  permission-request state transition instead of relying on accessibility-node
  disappearance after the dialog closes.
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
- Exact-head push and pull-request hosted instrumentation remain required
  before this plan can be marked completed.
- Initial exact-head push run `27655294552` passed, while pull-request run
  `27655300169` exposed a flaky accessibility-node disappearance assertion
  after the real deny click. The follow-up now waits for the fragment's
  permission-request state to transition from pending to settled, reasserts
  denied permission, and preserves the post-denial activity/fragment check.

## Scope Boundary

This change proves runtime camera permission denial on the pinned API 36
Google APIs emulator. It does not prove permission grant, camera preview,
still capture, rotation, lifecycle interruption, or physical-device behavior.
