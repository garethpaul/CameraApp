---
title: CameraApp Instrumentation Execution
type: reliability
date: 2026-06-16
status: completed
execution: code
---

# CameraApp Instrumentation Execution

## Context

The canonical test gate assembled `Application-debug-androidTest.apk` but never
executed its activity/fragment startup assertion.

## Requirements

- Provision a repository-owned API 36 Google APIs emulator in hosted CI.
- Bound emulator discovery and boot completion to three minutes and fail if
  the process exits early.
- Guarantee emulator and temporary AVD cleanup on success, failure, or signal.
- Execute `:Application:connectedDebugAndroidTest` through `make test`.
- Preserve an explicit `SKIP_ANDROID_INSTRUMENTATION=1` local boundary.
- Run debug and release lint in separate Gradle invocations so a clean build
  cannot race over shared lint partial-result state before instrumentation.

## Verification

- Source contracts plus APK assembly, lint, and debug build with the explicit
  local runtime skip.
- A clean generated-state build proving sequential zero-finding debug and
  release lint before test APK assembly.
- Shell syntax and hostile mutations covering connected-test execution, boot
  timeout, bounded ADB discovery, cleanup, system-image provisioning, KVM
  setup, and CI skip attempts.
- Fake-SDK failure tests using a shortened deadline to prove early emulator
  exit and ADB discovery timeout handling without weakening the 180-second
  production default.
- Exact-head hosted push and pull-request instrumentation execution before
  closure.

## Scope Boundary

The smoke test proves that `CameraActivity` creates its camera fragment before
permission grant. It does not prove camera permission, preview, capture,
rotation, lifecycle interruption, or physical-device behavior.
