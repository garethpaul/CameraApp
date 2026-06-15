---
title: Camera Error Log Redaction
type: security
status: completed
date: 2026-06-15
---

# Camera Error Log Redaction

## Problem

Camera setup, preview, capture, and ImageReader backpressure failures still emit
full exception stack traces. Those diagnostics can expose device, file, thread,
and framework details in application logs even though the save path already
uses fixed failure categories.

## Priorities

1. P0: Remove full throwable and stack-trace logging from camera runtime paths.
2. P1: Preserve fixed operation-level failure categories for troubleshooting.
3. P2: Keep camera state, callbacks, retries, user messages, and lifecycle
   behavior unchanged.

## Requirements

- Replace every compiled camera `printStackTrace()` call with a fixed diagnostic.
- Remove the throwable argument from the ImageReader backpressure warning.
- Preserve catch boundaries, returns, camera state transitions, callbacks, and
  existing user-visible behavior.
- Add mutation-sensitive source, guidance, and completed-plan contracts.
- Do not claim emulator, physical-camera, or live logcat verification on Linux.

## Implementation Units

### U1: Fixed Camera Failure Categories

**File:** `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`

Use fixed messages for camera discovery, open, preview, focus, precapture,
capture, unlock, and ImageReader backpressure failures without serializing
exception objects.

### U2: Portable Privacy Contract

**File:** `scripts/check-baseline.sh`

Reject stack-trace calls and throwable-bearing log calls in the compiled camera
fragment, require representative fixed categories, and require maintained
guidance plus completed plan evidence.

### U3: Maintained Guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document that camera diagnostics retain operation-level categories and never
exception stack traces or throwable details.

## Verification

- Run POSIX shell validation and the focused static baseline.
- Run repository-root and external-directory `make check`.
- Reject isolated stack-trace, throwable-log, missing-category, guidance, and
  incomplete-plan mutations.
- Audit the exact diff, generated artifacts, dependency/workflow drift,
  conflict markers, whitespace, and credential-shaped additions.

## Completion Evidence

- Replaced eight camera-access stack traces and the ImageReader throwable log
  with fixed operation-level categories while preserving catch and state flow.
- Repository-root and external-directory `make check` passed the complete
  Android 16/JDK 17 gate, including zero-finding debug and release lint.
- Six hostile mutations were rejected for a restored stack trace, restored and
  additive throwable logs, removed category, missing guidance, and incomplete
  plan status.
- Exact-path diff, generated-artifact, dependency/workflow-drift,
  conflict-marker, whitespace, and credential-shaped-addition audits passed.
- No emulator, physical-camera, or live logcat verification was performed.

## Scope Boundaries

- Do not change permissions, camera requests, capture sequencing, image
  ownership, background-thread ownership, save behavior, or UI behavior.
- Do not update dependencies, Gradle metadata, Android resources, or workflows.
- Keep this pull request stacked on PR #13 and preserve base-first ordering.
