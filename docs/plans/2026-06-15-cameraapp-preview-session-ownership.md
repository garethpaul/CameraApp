---
title: CameraApp Preview Session Ownership
type: reliability
status: planned
date: 2026-06-15
---

# CameraApp Preview Session Ownership

## Problem

`createCameraPreviewSession()` reads mutable `mCameraDevice` state while
building an asynchronous session and accepts `onConfigured()` whenever any
camera device is non-null. A delayed callback from an older device can therefore
publish its session and request builder after the fragment has closed and
reopened a different camera.

## Priorities

1. P0: Prevent stale preview callbacks from replacing current camera state.
2. P1: Close configured sessions that no longer own the current device.
3. P2: Preserve preview request modes, callbacks, handler use, and user-visible
   behavior for the current device.

## Requirements

- Capture the exact `CameraDevice` that initiates preview-session creation.
- Build the preview request from that captured device, not later mutable state.
- In `onConfigured()`, require the captured device to remain the exact current
  `mCameraDevice` before publishing session or request-builder fields.
- Close and return from stale configured callbacks.
- Add mutation-sensitive method-scoped ownership, ordering, guidance, and
  completed-plan contracts.
- Do not claim emulator, physical-camera, or live preview execution on Linux.

## Implementation Units

### U1: Preview Ownership Boundary

**File:**
`Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`

Capture the initiating device and local request builder, close stale configured
sessions, and publish shared preview fields only after identity validation.

### U2: Portable Race Contract

**File:** `scripts/check-baseline.sh`

Scope preview-session creation, require captured-device construction and strict
stale-close-before-publication ordering, and fail closed on absent evidence.

### U3: Maintained Guidance

**Files:** `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`, and this plan.

Document that asynchronous preview sessions may publish state only while they
retain exact camera-device ownership.

## Verification

- Run POSIX shell validation and the focused static baseline.
- Run SDK-backed repository and external-directory `make check`.
- Reject isolated captured-device, stale-close, identity, publication-order,
  guidance, and incomplete-plan mutations.
- Audit exact intended paths, generated artifacts, dependency/workflow drift,
  conflict markers, whitespace, and credential-shaped additions.

## Scope Boundaries

- Do not change camera selection, open/close semaphore ownership, background
  thread ownership, capture sequencing, image saving, permissions, UI,
  dependencies, resources, project metadata, or workflows.
- Keep this pull request stacked on PR #14 and preserve base-first ordering.
