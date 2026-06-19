# Gradle 9.6 Wrapper Refresh

## Status: Completed

## Problem

The zero-finding Android lint gate began rejecting the authenticated Gradle
9.5.1 wrapper after Gradle 9.6.0 became the current stable release.

## Changes

- Regenerated all four wrapper artifacts with Gradle 9.6.0.
- Pinned the official binary distribution SHA-256 to
  `bbaeb2fef8710818cf0e261201dab964c572f92b942812df0c3620d62a529a01`.
- Updated active repository guidance and fail-closed wrapper byte contracts.
- Preserved Android Gradle Plugin 9.2.0, JDK 17, SDK 36, Build Tools 36.1.0,
  and the existing permission-denial runtime scope.

## Verification Results

- `scripts/check-baseline.sh` passed.
- `SKIP_ANDROID_INSTRUMENTATION=1 make check` passed from the repository root.
- The external-Makefile `make check` invocation passed.
- Debug and release lint retained zero findings.
- Instrumentation and debug APK assembly passed.
- Local runtime instrumentation remained explicitly skipped because no emulator
  is attached; no camera runtime claim was added.
