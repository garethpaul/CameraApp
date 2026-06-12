# CameraApp Changes

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
