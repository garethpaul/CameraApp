# CameraApp Changes

## 2026-06-26 06:58 PDT - P1 - Authorize opened-camera publication bytes

### Summary

The base-owned trusted verifier now authorizes exactly the nine reviewed files
for opened-device publication before camera callback semaphore release.

### Work completed

- Replaced the callback-lock templates with exact opened-camera publication
  templates, modes, size limits, and SHA-256 digests.
- Bound the next semantic repair to one direct child of this bootstrap base.
- Preserved hostile topology, byte, path, mode, size, and tool-injection tests.

### Validation

- Trusted verifier unit tests and the SDK-free source baseline pass.
- The exact nine-file synthetic semantic child is accepted with every reviewed
  digest in its receipt.
- Policy JSON parsing and `git diff --check` pass. Ordinary hosted and
  exact-head review evidence remain merge gates.

### Blockers

- The old protected gate must reject this policy-changing bootstrap by design.

### Next action

- Merge this bootstrap, then rebase and apply the reviewed semantic repair as
  one direct child of the new default branch.

## 2026-06-26 04:56 PDT - P1 - Preserve camera callback lock ownership

### Summary

Prevented a disconnect or error delivered after `onOpened` from releasing the
camera lifecycle semaphore a second time and weakening open/close serialization.

### Work completed

- Added one atomic callback-release token transferred immediately before the
  asynchronous camera open.
- Routed opened, disconnected, and error callbacks through a one-shot release
  helper while preserving callback-device closure and stale ownership guards.
- Revoked callback ownership before synchronous camera-open failure cleanup.
- Added SDK-free ordered contracts, four hostile mutations, synchronized
  guidance, and a completed implementation plan.

### Validation

- RED: the baseline rejected the missing atomic callback ownership token.
- GREEN: `scripts/check-baseline.sh` passes after implementation.
- Four isolated ownership mutations were rejected: direct extra release,
  missing error callback release, weakened atomic consumption, and stale
  synchronous-failure ownership.
- Root/external Make, hosted Android, trusted verifier, and exact-head review
  remain merge gates.

### Blockers

- No emulator, physical camera, or live post-open disconnect/error callback is
  available locally; runtime lifecycle confirmation remains in the device
  verification matrix.

### Next action

- Bootstrap the base-owned trusted policy for these exact eight semantic files,
  then merge only its one-commit direct child after every hosted gate passes.



## 2026-06-26 05:31 PDT - P1 - Finalize callback lock semantic history

### Summary

Made the exact callback-lock semantic changelog retain the corrective digest
marker itself, the earlier history marker, and the original policy bootstrap.

### Work completed

- Embedded this marker and all prior callback-lock rollout records in the exact
  semantic `CHANGES.md` template.
- Refreshed the trusted changelog digest and bounded size limit.
- Preserved the same eight-file semantic boundary and verifier behavior.

### Validation

- The full hermetic verifier suite passed.
- A literal one-commit synthetic semantic child was accepted with the final
  self-preserving changelog digest.
- Source baseline, JSON parsing, and `git diff --check` passed.

### Next action

- Merge this final base-only marker, then apply the reviewed semantic repair as
  one direct child of the new default branch.

## 2026-06-26 05:22 PDT - P1 - Preserve bootstrap history in semantic bytes

### Summary

Updated the trusted callback-lock changelog template so the semantic repair
retains the base-owned bootstrap record instead of replacing it.

### Work completed

- Added the merged bootstrap entry to the exact semantic `CHANGES.md` template.
- Refreshed only that template's SHA-256 policy digest.
- Preserved the same eight-file semantic boundary and all verifier behavior.

### Validation

- The full hermetic verifier suite passed.
- A literal one-commit synthetic semantic child was accepted with the refreshed
  changelog digest.
- Source baseline, JSON parsing, and `git diff --check` passed.

### Next action

- Merge this base-only digest marker, then apply the semantic repair as one
  direct child of the new default branch.

## 2026-06-26 05:05 PDT - P1 - Authorize callback lock ownership bytes

### Summary

The base-owned trusted verifier now authorizes exactly the eight reviewed files
for camera-open callback semaphore ownership.

### Work completed

- Replaced the completed preview-session templates with exact callback-lock
  ownership templates, modes, size limits, and SHA-256 digests.
- Bound the next semantic repair to one direct child of this bootstrap base.
- Preserved hostile topology, byte, path, mode, size, and tool-injection tests.

### Validation

- Trusted verifier unit tests and the SDK-free source baseline passed.
- The exact eight-file synthetic semantic child was accepted with every
  reviewed digest in its receipt.
- Policy JSON parsing and `git diff --check` passed. Ordinary hosted and
  exact-head review evidence remain merge gates.

### Blockers

- The old protected gate must reject this policy-changing bootstrap by design.

### Next action

- Merge this bootstrap, then rebase and apply the reviewed semantic repair as
  one direct child of the new default branch.

## 2026-06-25 15:40 PDT - P1 - Recover failed preview startup ownership

### Summary

Synchronous preview-start failures no longer leave a failed capture session,
request builder, or request published as current shared camera state.

### Work completed

- Added an ownership-guarded `onConfigured()` recovery path for camera access,
  closed-session, and invalid repeating-request failures.
- Clear callback-owned preview fields before closing the failed session.
- Added an exact source contract and documented the reviewed behavior.

### Threads

- Continued: Camera2 callback ownership and synchronous failure recovery.
- Started or stopped: none.

### Files changed

- `Camera2BasicFragment.java` - recover failed preview startup ownership.
- `scripts/check-baseline.sh` - enforce unique cleanup markers and ordering.
- Repository guidance and the completed preview-recovery implementation plan.

### Validation

- RED: the source baseline rejected the missing ownership recovery marker.
- GREEN: focused, hostile mutation, full, trusted, hosted, and review evidence
  remains pending.

### Bugs / findings

- P1: `onConfigured()` published shared preview state before a repeating request
  could fail synchronously, leaving an unusable session visible to later work.

### Blockers

- The base-owned exact trusted-verifier policy must be bootstrapped and merged
  separately before this semantic child can be authorized.

### Next action

- Build the exact policy templates, merge the independently reviewed bootstrap,
  then apply this repair as one direct child of the new default branch.

## 2026-06-25 16:00 PDT - P1 - Authorize preview startup recovery bytes

### Summary

The base-owned trusted verifier now authorizes exactly the eight reviewed files
for synchronous preview-session startup recovery.

### Work completed

- Replaced the completed focus-recovery templates with exact preview-session
  recovery templates, modes, size limits, and SHA-256 digests.
- Bound the next semantic repair to one direct child of this bootstrap base.
- Preserved hostile topology, byte, path, mode, size, and tool-injection tests.

### Threads

- Started: exact authority for preview-session startup failure recovery.
- Continued or stopped: none.

### Files changed

- `trusted-verifier/policy.json` and `expected/preview-session/` - define the
  next exact eight-file semantic child.
- `scripts/check-baseline.sh` and the rollout plan - enforce the new authority.

### Validation

- All eight hermetic trusted-verifier acceptance and hostile cases passed.
- The exact eight-file synthetic semantic child was accepted with every
  reviewed digest in its receipt.
- `scripts/check-baseline.sh`, policy JSON parsing, and `git diff --check`
  passed. Ordinary hosted and exact-head review evidence remains pending.

### Bugs / findings

- P1: the current trusted policy correctly rejects the newly designed preview
  repair because it still authorizes only the completed focus-recovery bytes.

### Blockers

- The old trusted gate must reject this policy-changing bootstrap by design.

### Next action

- Merge this bootstrap only after ordinary checks and exact-head review, then
  apply the reviewed semantic bytes as one direct child.

## 2026-06-25 11:15 PDT - P1 - Recover focus and precapture state

### Summary

Camera2 focus and precapture startup failures now restore preview state, clear
stale AF/AE triggers, and resume repeating preview instead of waiting for
callbacks that cannot arrive.

### Work completed

- Restored preview state for missing dependencies, Camera2 access failures, and
  closed-session failures in both focus and precapture startup paths.
- Routed submitted-request failures through focus unlock and repeating-preview
  recovery, including an explicit precapture-trigger reset.
- Added ordered SDK-free contracts and hostile mutations for every recovery
  branch.

### Threads

- Reviewed: Codex review found missing dependency and trigger recovery; the
  equivalent final semantic bytes passed independent review.
- Started, continued, or stopped: none.

### Files changed

- `Camera2BasicFragment.java` - restores camera and capture state.
- `scripts/check-baseline.sh` - enforces dependency, exception, and trigger
  recovery.
- Maintenance docs and plan - record the invariant and device boundary.

### Validation

- `scripts/check-baseline.sh` - passed.
- `scripts/test-makefile-root.sh` - passed.
- Five hostile state and trigger recovery mutations - rejected as expected.
- Exact rebased head review and hosted API 36 checks are required before merge.

### Bugs / findings

- P1: synchronous focus or precapture failures could strand the capture state
  machine outside preview with stale AF/AE trigger state.

### Blockers

- Local Android compilation and camera execution remain unavailable because the
  environment has no Android SDK, emulator, or physical camera.

### Next action

- Merge only after the base-owned trusted gate, both API 36 checks, CodeQL, and
  exact-head Codex review pass.

## 2026-06-25 11:00 PDT - P1 - Close trusted recovery-check gap

### Summary

The exact focus-recovery checker now requires one recovery capture submission
before comparing its ordering with the AF/AE trigger reset.

### Work completed

- Added a unique recovery-capture marker contract to the reviewed semantic
  checker and its base-owned policy assertion.
- Updated the trusted script and changelog digests without broadening the
  eight-file semantic boundary.

### Threads

- Reviewed: Codex review found the missing-marker false-negative.
- Started, continued, or stopped: none.

### Files changed

- `scripts/check-baseline.sh` and its trusted template - reject missing or
  duplicated recovery capture submissions.
- `trusted-verifier/policy.json` - binds the corrected script and changelog.

### Validation

- Missing recovery-capture hostile mutation - rejected.
- Trusted verifier tests and exact synthetic child - passed.

### Bugs / findings

- P1: an empty line-number operand inside a shell `if` could emit an error yet
  allow the checker to continue successfully.

### Blockers

- The old trusted policy must reject this policy-changing bootstrap by design.

### Next action

- Verify, review, and merge this narrow bootstrap, then rebuild PR #34 from the
  corrected exact templates.

## 2026-06-25 10:33 PDT - P1 - Prepare exact focus-recovery authority

### Summary

The base-owned verifier now reviews the complete focus and precapture recovery
change instead of remaining frozen to the completed permission-retry rollout.

### Work completed

- Replaced the historical single-file policy with eight exact semantic file
  contracts, reviewed modes, size bounds, and SHA-256 digests.
- Generalized hostile verifier tests to derive candidate files from policy.

### Threads

- Started, continued, stopped, or reviewed: none.

### Files changed

- `trusted-verifier/policy.json` and `trusted-verifier/expected/focus-state/` -
  define the next exact semantic child.
- `trusted-verifier/tests/test_bootstrap.py` - exercises every policy file.
- `scripts/check-baseline.sh` and rollout plan - enforce the new authority.

### Validation

- Eight trusted verifier acceptance and hostile candidate tests - passed.
- Exact synthetic semantic child - accepted with all eight reviewed digests.
- `scripts/check-baseline.sh` - passed.

### Bugs / findings

- P1: the trusted gate was non-authoritative in branch protection and still
  accepted only the completed June 20 permission-retry template.

### Blockers

- The bootstrap policy PR is expected to fail the old semantic allowlist; it
  must pass ordinary hosted checks and independent review before merging.

### Next action

- Open and independently review this bootstrap, merge it after ordinary hosted
  checks pass, then rebase the focus-recovery PR onto it.

## 2026-06-21

- Bound the public verification targets to the repository Makefile, canonical
  root, system shell, literal Android/JDK/Gradle inputs, and executing Make
  modes, with a hermetic hostile-invocation regression harness.
- Invoke the normal hosted gate through `/usr/bin/make` while preserving the
  base-owned trusted pull-request verifier and full API 36 instrumentation.

## 2026-06-20

- Added a base-owned trusted `pull_request_target` bootstrap that treats
  pull-request CameraApp checkouts as data, rejects v2 direct-gate replacement
  candidates, and documents the protected-environment rollout prerequisite.
- Retry a freshly acquired permission-dialog denial control within the existing
  timeout when API 36 drops an emulator touch, while retaining callback and
  recreation assertions.

## 2026-06-19

- Bound emulator cleanup in a per-run cgroup v2 containment unit and run
  cleanup helpers, including `adb emu kill`, under short timeouts so hung
  helpers cannot block TERM or `cgroup.kill` escalation.
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
