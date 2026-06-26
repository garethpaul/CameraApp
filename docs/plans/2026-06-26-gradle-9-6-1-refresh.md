# Gradle 9.6.1 Refresh

## Status: Completed

## Context

The exact default branch used an authenticated Gradle 9.6.0 wrapper. On
2026-06-26 Android lint began reporting 9.6.1 as the current stable release,
which made the repository's zero-finding lint gate fail without a source
regression.

## Changes

- Regenerated `gradlew` and `gradlew.bat` with Gradle 9.6.1.
- Pinned `gradle-9.6.1-bin.zip` to SHA-256
  `9c0f7faeeb306cb14e4279a3e084ca6b596894089a0638e68a07c945a32c9e14`.
- Updated the SDK-free wrapper byte contracts and current documentation.
- Preserved the completed Gradle 9.6.0 plan as historical evidence.

## Verification Results

- `make check` passes with JDK 17, Android platform 36, and Build Tools 36.1.0.
- Debug and release lint produce zero findings.
- The instrumentation APK and debug APK assemble successfully.
- The base-owned verifier accepts the exact eleven-file semantic child and keeps
  all hostile topology and byte mutations rejected.

## Runtime Boundary

No camera-capable emulator or physical device was available. Instrumentation
runtime execution remains skipped; assembly and hosted exact-head validation
remain required.
