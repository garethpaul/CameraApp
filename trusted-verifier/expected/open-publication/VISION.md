## CameraApp Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)
Contribution guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)

CameraApp is an Android Camera2Basic sample. It demonstrates Camera2 device
selection, preview, focus locking, precapture, and still image capture.

The repository is useful as a preserved Android camera API sample with the
original multi-directory sample structure. Project background lives in
[`README.md`](README.md).

The goal is to keep the sample recognizable, buildable with a supported Android
toolchain, and safe around camera permissions and captured images.

The current focus is:

Priority:

- Preserve the Camera2 preview and still-capture flow
- Keep the sample-origin source layout and attribution intact
- Keep camera lifecycle startup tied to an available texture view
- Keep camera open/close semaphore ownership balanced across failure paths
- Keep all camera-open callbacks bound to one atomic semaphore-release token
- Keep opened-device publication and preview submission ahead of callback token release
- Keep interrupted camera close attempts from releasing unowned permits
- Interrupted camera-worker shutdown preserves the interrupt signal and unresolved worker ownership.
- Keep asynchronous preview callbacks bound to their initiating camera device
- Keep camera-device disconnect and error callbacks bound to the device that initiated them
- Capture-result and still-capture completion callbacks reject stale session ownership before mutating capture state or unlocking focus.
- Keep failed preview sessions out of shared capture state.
- Current-session still-capture failures unlock focus and resume preview; stale session failures are ignored.
- Synchronous still-capture and preview-restart failures restore preview state before Camera2 recovery work can throw.
- Closed-session still-capture and preview-restart operations use the same
  recovery path instead of escaping with `IllegalStateException`.
- Missing still-capture dependencies restore preview state before the capture path returns.
- Keep missing, failed, or closed-session focus and precapture operations from leaving the capture state machine waiting.
- Keep submitted focus and precapture failures from retaining stale AF/AE triggers or abandoning repeating preview.
- Report preview configuration failures only for the initiating camera lifetime
- Keep layout control binding tolerant of missing optional controls
- Keep right-to-left camera control placement tied to logical layout anchors
- Keep non-overlapping landscape preview and control regions under localization
- Keep unreachable template resource surface out of the packaged camera sample
- Keep a single-owner camera window background without redundant full-screen paint
- Keep a complete xxxhdpi icon family and a zero-finding Android lint gate
- Keep Android 16 edge-to-edge insets away from interactive camera controls
- Keep camera open and output setup behind the runtime permission grant
- Keep unsupported-camera recovery tolerant of detached fragments
- Keep unsupported-camera dialogs tolerant of detached activities
- Keep image capture callbacks tolerant of lifecycle and backpressure edges
- Keep rejected image-save handoffs from leaking reader capacity
- CameraApp reports picture-save success only after file output closes
  successfully
- Keep camera app data out of platform backup by default
- Keep UI copy from exposing app-private captured-image paths
- Image-save failures log a generic category without exception details or private output paths.
- Camera runtime diagnostics retain fixed operation categories without exception stack traces or throwable details.
- Make Android SDK and build-tool requirements visible
- Keep the SDK-free source checker available for focused mutation tests
- Keep the full JDK 17, SDK 36, lint, test-APK, and app-APK gate in GitHub Actions
- Keep pull-request merge authority in a base-owned trusted verifier that treats
  candidate bytes as data until exact semantic review passes
- Keep Gradle 9.6.0 behind a checksum-verified direct wrapper
- Keep the application runtime dependency graph empty
- Avoid changing camera behavior without device verification notes

Next priorities:

- Execute the CameraApp device verification matrix against an exact commit on
  a camera-capable emulator and physical device
- Exercise permission grant, denial, resume, preview, and capture behavior on a
  camera-capable API-23+ device or emulator
- Keep the deterministic pre-permission activity/fragment instrumentation smoke
  test running in hosted CI; retain camera preview and capture as device validation
- Reassess the two preview-SDK lint advisories when Android API 37 is stable

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
- Broad unrelated migrations mixed with capture behavior changes
- Attribution or license removals
- Permission expansion without documentation

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
