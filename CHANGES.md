# CameraApp Changes

## 2026-06-19

- Use a standard-duration hosted permission-denial gesture and wait for the
  dialog to disappear before polling the app's callback, removing an
  intermittent instrumentation race on the default branch.
- Refreshed the authenticated Gradle wrapper from 9.5.1 to 9.6.0 after the
  zero-finding lint gate began rejecting the superseded wrapper release.

## 2026-06-17

- Extended hosted camera-permission denial coverage across activity recreation
  and verified that the retained fragment neither loses denial state nor
  restarts the permission request.

## 2026-06-16

- Extended hosted API 36 instrumentation through the real camera-permission
  denial action and asserted that the activity and fragment remain stable.
- Added bounded API 36 emulator provisioning and executed the existing
  pre-permission CameraActivity instrumentation smoke test in hosted CI.
- Serialized debug and release lint so clean builds cannot race over shared
  Android lint partial-result state.
- Capture-result and still-capture completion callbacks reject stale session ownership before mutating capture state or unlocking focus.
- Current-session still-capture failures unlock focus and resume preview; stale session failures are ignored.
- Synchronous still-capture and preview-restart failures restore preview state before Camera2 recovery work can throw.
- Closed-session still-capture and preview-restart operations now recover
  instead of escaping with `IllegalStateException`.
- Missing still-capture dependencies restore preview state before the capture path returns.

## 2026-06-15

- Interrupted camera-worker shutdown preserves the interrupt signal and unresolved worker ownership.
- Bound camera-device disconnect and error side effects to current-device ownership.
- Bound configured preview sessions to their exact initiating camera device and
  closed stale sessions before shared preview state publication.
- Suppressed stale camera-lifetime preview failure UI without invoking failed sessions.
- Camera runtime diagnostics retain fixed operation categories without exception stack traces or throwable details.
- Image-save failures log a generic category without exception details or private output paths.

## 2026-06-14

- Added an exact-head CameraApp device verification matrix with privacy-safe
  evidence fields and every runtime row explicitly unexecuted.
- Migrated the build to Android Gradle Plugin 9.2.0, Gradle 9.5.1, JDK 17,
  compile/target SDK 36, and Android Build Tools 36.1.0.
- Removed unused support-library runtime dependencies while retaining
  AndroidX only for the compiled instrumentation smoke test.
- Added runtime camera permission ordering for API 23+, target-36 system-bar
  inset protection, and explicit Android 12+ backup rules.
- Cleared retained texture-view references at view teardown so delayed
  permission results cannot reopen the camera against a stale hierarchy.
- Expanded `make check` and hosted CI to require zero-finding debug/release
  lint, app APK assembly, and instrumentation APK assembly.
- Retained an authenticated Gradle wrapper and non-persisted, read-only hosted
  checkout credentials on the modern toolchain.
- Closed callback-owned images when the background handler rejects a save
  runnable during lifecycle shutdown.
- CameraApp reports picture-save success only after file output closes
  successfully instead of treating Camera2 capture completion as persistence.

## 2026-06-13

- Added a complete xxxhdpi icon family and made SDK-backed `make lint` reject
  every remaining Android lint finding.
- Moved the black camera launch surface into the active window theme and removed
  the redundant activity-root background paint.
- Pruned the unreachable sample-template layout, dimensions, widget styles, and
  tile asset while retaining the active application theme and camera resources.
- Removed the landscape preview/control overlap warning by giving the camera
  surface and end-side control rail independent relative-layout bounds.
- Enabled RTL mirroring and replaced physical right-side camera control
  attributes with logical end-side anchors, resolving the RTL lint findings
  while preserving left-to-right placement.
- Added SDK-backed lint and static regression coverage for the two layout
  attributes.

## 2026-06-12

- Added an authenticated Gradle wrapper bootstrap for the legacy 2.2.1 runtime
  and disabled hosted checkout credential persistence.
- Balanced `closeCamera` semaphore ownership so interrupted acquisition no
  longer adds an extra permit to the camera lifecycle lock.
- Restored the current thread's interrupt flag before propagating close-lock
  interruption and extended the SDK-free regression baseline.
- Replaced the fragment-retaining toast handler with a static main-looper
  handler backed by a weak fragment reference.

## 2026-06-10

- Released the camera open/close semaphore when `openCamera` fails before its
  asynchronous state callback takes ownership, preventing pause-time deadlock.
- Made Gradle verification location-independent and pinned CI to the stable
  Ubuntu 24.04 runner image.
- Added a lightweight GitHub Actions workflow that runs `make check` for the
  Camera2 source baseline.
- Pinned the checkout action, limited repository access to read-only, and
  cleared hosted Android SDK variables for deterministic SDK-free checks.
- Extended the SDK-free baseline to require the CI workflow and completed CI
  plan.

## 2026-06-09

- Guarded unsupported-camera dialog creation when retained fragments have no
  attached activity.
- Guarded the unsupported-camera error dialog so detached retained fragments do
  not call `show()` with a missing fragment manager.
- Guarded picture and info control listener binding so layout drift does not
  crash fragment view creation.
- Replaced the capture completion toast with generic saved-copy so the UI does
  not expose the app-private output file path.
- Guarded `onResume()` so retained fragments wait for the texture view before
  starting camera background work.
- Disabled Android backup for the camera sample so camera-capture app state is
  not opt-in to platform backup by default.
- Guarded `ImageReader.acquireNextImage()` against backpressure exceptions so
  backed-up still-image callbacks are dropped instead of crashing capture.
- Extended the SDK-free baseline and README notes for ImageReader
  backpressure handling.

## 2026-06-08

- Added `make check` as the root wrapper for CameraApp source, lint, and
  debug build verification.
- Made camera background-thread startup idempotent to avoid duplicate handler
  threads during repeated lifecycle starts.
- Guarded Camera2 autofocus, preview session, still capture, and image-plane
  paths against null lifecycle state.
- Added a changelog for repository maintenance.
- Restored README verification notes for the legacy Android build hygiene baseline.
- Extended the baseline script to require changelog and documented Gradle verification commands.
