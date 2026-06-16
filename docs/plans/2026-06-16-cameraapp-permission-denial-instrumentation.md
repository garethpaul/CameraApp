---
title: CameraApp Permission Denial Instrumentation
type: reliability
date: 2026-06-16
status: in_progress
execution: code
---

# CameraApp Permission Denial Instrumentation

## Context

The hosted API 36 emulator now executes the CameraApp instrumentation suite,
but the maintained smoke test stops after confirming that the camera fragment
is installed before runtime permission is granted. The production denial path
therefore remains covered only by source contracts.

## Requirements

- Revoke camera permission before the denial test launches the activity.
- Drive the real API 36 permission-controller denial action rather than
  invoking the fragment callback directly.
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

## Scope Boundary

This change proves runtime camera permission denial on the pinned API 36
Google APIs emulator. It does not prove permission grant, camera preview,
still capture, rotation, lifecycle interruption, or physical-device behavior.
