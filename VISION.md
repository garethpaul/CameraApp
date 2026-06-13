## CameraApp Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)
Contribution guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)

CameraApp is an Android Camera2Basic sample. It demonstrates Camera2 device
selection, preview, focus locking, precapture, and still image capture.

The repository is useful as a preserved Android camera API sample with the
original multi-directory sample structure. Project background lives in
[`README.md`](README.md).

The goal is to keep the sample recognizable, buildable in the right legacy
toolchain, and safe around camera permissions and captured images.

The current focus is:

Priority:

- Preserve the Camera2 preview and still-capture flow
- Keep the sample-origin source layout and attribution intact
- Keep camera lifecycle startup tied to an available texture view
- Keep camera open/close semaphore ownership balanced across failure paths
- Keep interrupted camera close attempts from releasing unowned permits
- Keep layout control binding tolerant of missing optional controls
- Keep right-to-left camera control placement tied to logical layout anchors
- Keep non-overlapping landscape preview and control regions under localization
- Keep unreachable template resource surface out of the packaged camera sample
- Keep a single-owner camera window background without redundant full-screen paint
- Keep a complete xxxhdpi icon family and a zero-finding Android lint gate
- Keep unsupported-camera recovery tolerant of detached fragments
- Keep unsupported-camera dialogs tolerant of detached activities
- Keep image capture callbacks tolerant of lifecycle and backpressure edges
- Keep camera app data out of platform backup by default
- Keep UI copy from exposing app-private captured-image paths
- Make Android SDK and build-tool requirements visible
- Keep the SDK-free `make check` baseline running in GitHub Actions
- Keep the legacy Gradle runtime behind a checksum-verified direct wrapper
- Avoid changing camera behavior without device verification notes

Next priorities:

- Modernize Gradle, SDK levels, and support dependencies in a dedicated pass
- Add README notes for current Android Studio import and build expectations
- Add tests or manual verification steps for preview and capture behavior
- Review runtime permission handling for modern Android versions

Contribution rules:

- One PR = one focused camera, build, or documentation change.
- Preserve sample attribution and license text.
- Verify camera behavior on hardware or emulator when changing capture logic.
- Keep generated build artifacts and local SDK paths out of git.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Camera access is sensitive. Changes must not upload, log, or retain captured
images without explicit purpose and user control.

Permission changes should request only the access needed for preview and still
capture.

## What We Will Not Merge (For Now)

- Camera-data upload or analytics
- Broad project migrations mixed with capture behavior changes
- Attribution or license removals
- Permission expansion without documentation

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
