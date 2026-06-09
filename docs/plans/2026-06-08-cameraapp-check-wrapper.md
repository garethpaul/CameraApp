---
title: CameraApp Check Wrapper
type: chore
status: completed
date: 2026-06-08
---

# CameraApp Check Wrapper

## Summary

Expose CameraApp's SDK-free source baseline and SDK-backed Gradle lint/debug
build through the shared root `make check` command.

## Requirements

- R1. Preserve `scripts/check-baseline.sh` as the first verification step.
- R2. Run Gradle lint and debug assembly when `ANDROID_HOME` points to an
  installed Android SDK.
- R3. Keep instrumentation/device camera testing documented as follow-up
  verification on matching hardware or emulator support.
- R4. Document the wrapper in README and CHANGES.

## Verification

- `make check`
- `git diff --check`
