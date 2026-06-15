---
title: CameraApp Background Interrupt Restoration
type: reliability
status: planned
date: 2026-06-15
---

# CameraApp Background Interrupt Restoration

## Problem

`stopBackgroundThread()` catches interruption while joining the camera worker,
prints the stack trace, and returns with the thread's interrupt signal cleared.
Callers cannot observe cancellation, and the behavior differs from the nearby
camera-close lock path, which correctly restores the interrupt status before
propagating its failure.

## Priorities

1. P0: Restore the current thread's interrupt status when background-thread
   shutdown is interrupted.
2. P1: Remove throwable-bearing stack output from this lifecycle path.
3. P2: Preserve worker and handler ownership when the join does not complete.

## Requirements

- Replace `printStackTrace()` in the `stopBackgroundThread()` catch with
  `Thread.currentThread().interrupt()`.
- Do not clear `mBackgroundThread` or `mBackgroundHandler` when join is
  interrupted, because the worker's termination has not been confirmed.
- Preserve null-thread handling, safe quit, successful join, and successful
  ownership release.
- Add mutation-sensitive method-scoped source, guidance, and completed-plan
  contracts.
- Do not claim emulator, physical camera, or lifecycle runtime execution.

## Implementation Units

### U1: Shutdown Interrupt Contract

**File:**
`Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`

Restore interruption in the existing catch and leave ownership fields intact
unless `join()` succeeds.

### U2: Portable Lifecycle Contract

**File:** `scripts/check-baseline.sh`

Scope the `stopBackgroundThread()` body, require quit-before-join, successful
join-before-release, interrupt restoration in the catch, and absence of stack
trace or throwable-bearing logs.

### U3: Maintained Guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document that interrupted camera-worker shutdown preserves both the interrupt
signal and unresolved worker ownership.

## Verification

- Run POSIX shell validation and the focused baseline checker.
- Run SDK-backed debug/release tests, lint, and APK assembly through repository
  and external-directory `make check`.
- Reject isolated interrupt-removal, premature ownership release,
  stack-trace, guidance, and incomplete-plan mutations.
- Audit exact intended paths, generated artifacts, conflict markers,
  dependency/workflow drift, whitespace, and credential-shaped additions.

## Scope Boundaries

- Do not change camera setup, open/close locking, preview, capture, image saving,
  permissions, UI, dependencies, or workflow configuration.
- Keep this pull request stacked on PR #12 and preserve base-first ordering.
