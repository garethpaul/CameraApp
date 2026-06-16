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
- A signal-path test proving termination exits nonzero and removes temporary
  AVD state through the exit cleanup trap.
- Exact-head hosted push and pull-request instrumentation execution before
  closure.

## Verification Results

- Repository-root and external-directory `make check` passed from a clean
  generated state with JDK 17, Android SDK 36, and
  `SKIP_ANDROID_INSTRUMENTATION=1`; debug/release lint produced zero findings,
  the instrumentation APK assembled, and the debug APK assembled.
- Sequential lint was required because the combined clean-state invocation
  reproduced a missing lint partial-result failure; separate debug and release
  invocations passed consistently without weakening either lint gate.
- Fake-SDK tests proved successful connected-test invocation, early emulator
  exit rejection, bounded ADB discovery timeout, signal exit status 143, and
  temporary AVD cleanup.
- Twelve isolated hostile mutations were rejected across connected-test
  execution, boot deadline, cleanup and signal traps, bounded discovery,
  system-image and KVM provisioning, CI skip prevention, sequential lint, and
  completed plan evidence.
- The real API 36 emulator image could not be installed locally because the SDK
  unpack step reported `No space left on device`; only its explicit incomplete
  `.temp` and system-image paths were removed. Real emulator execution remains
  an exact-head hosted requirement and is not yet claimed here.

## Scope Boundary

The smoke test proves that `CameraActivity` creates its camera fragment before
permission grant. It does not prove camera permission, preview, capture,
rotation, lifecycle interruption, or physical-device behavior.
