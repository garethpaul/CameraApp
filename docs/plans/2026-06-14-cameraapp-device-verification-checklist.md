# CameraApp Device Verification Checklist

Status: In Progress

## Problem

Portable checks cover the Android 16 toolchain, runtime permission ordering,
camera lifecycle guards, capture backpressure, image handoff ownership, layout
insets, and zero-finding lint. The repository does not yet define repeatable,
exact-head evidence for camera-capable emulator or physical-device behavior.

## Requirements

1. Add an exact-commit matrix for install, launch, permission grant and denial,
   preview, still capture, orientation, background/foreground lifecycle,
   rejected save handoff, sustained capture, and relaunch.
2. Require sanitized Android, device, camera, result, and evidence fields with
   explicit pass, fail, blocked, or not-run outcomes.
3. Keep repository, Gradle, lint, APK, emulator, and physical-camera evidence
   separate so portable checks cannot imply runtime execution.
4. Add mutation-sensitive contracts for the checklist, repository guidance,
   and completed plan evidence.

## Scope Boundaries

- Do not change Java, Gradle, manifests, resources, permissions, dependencies,
  camera behavior, capture output, or signing configuration.
- Do not add device identifiers, captured images, room imagery, APKs, logs,
  archives, credentials, signing material, or local SDK configuration.
- Do not claim emulator, camera, permission, preview, capture, or lifecycle
  execution from repository or Gradle checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded repository validation.
