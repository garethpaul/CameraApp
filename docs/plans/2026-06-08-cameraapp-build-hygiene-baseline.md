---
title: CameraApp Build Hygiene Baseline
type: fix
status: completed
date: 2026-06-08
---

# CameraApp Build Hygiene Baseline

## Summary

Raise the baseline for the legacy Android Camera2 sample by removing generated
IDE/build state from source control, stabilizing Gradle repository/build-tools
configuration, removing a duplicate legacy support dependency, fixing the stale
instrumentation test fixture, scoping legacy lint suppression, and adding a
local source check plus README verification guidance.
It also guards camera, output-file, image-save, and background-thread lifecycle
edges that can be unavailable on real devices.

---

## Problem Frame

The repository tracks `.gradle`, `.idea`, `local.properties`, module `.iml`, and
`Application/build` output. The module build still uses JCenter, build-tools
21.1.1, and a legacy duplicate `com.google.android:support-v4:r7` dependency.
The instrumentation smoke test calls support-fragment APIs even though
`CameraActivity` extends platform `Activity` and uses the platform fragment
manager.

---

## Requirements

- R1. Generated Gradle, Android Studio, local SDK, module metadata, and build output must not be tracked.
- R2. The app must keep compile SDK 21, target SDK 21, min SDK 21, package name, and Camera2 sample behavior unchanged.
- R3. Gradle resolution must use explicit HTTPS repositories instead of JCenter.
- R4. Build-tools must be pinned to host-compatible 24.0.3.
- R5. The duplicate legacy `com.google.android:support-v4:r7` dependency must be removed while keeping support 21.0.2 dependencies.
- R6. The instrumentation fixture must use the platform fragment manager.
- R7. Legacy lint suppression must be limited to the old toolchain's missing API database infrastructure issue.
- R8. Camera setup, image saving, and background-thread shutdown must tolerate missing lifecycle state.
- R9. The repository must include an SDK-free baseline check and README verification guidance.

---

## Key Technical Decisions

- **Keep the old Android plugin:** This pass preserves Android Gradle Plugin 1.0.0 and Gradle 2.2.1 to avoid a full sample migration.
- **Use Google Maven and Maven Central:** Support libraries resolve through Google Maven; the Android plugin resolves through Maven Central.
- **Pin build-tools 24.0.3:** The installed 24.0.3 tools provide host-compatible Android build tools while preserving SDK levels.
- **Scope lint suppression:** Android Gradle Plugin 1.0.0 cannot run modern lint API database checks cleanly, so only `LintError` is disabled.
- **Remove generated outputs:** Build products and IDE state are reproducible local state and should not be committed.

---

## Scope Boundaries

- This pass does not modernize Camera2 code, runtime permission handling, Gradle, or support libraries.
- This pass does not add emulator/device camera verification.
- This pass does not change screenshots, packaging metadata, or sample UI.

---

## Implementation Units

### U1. Stabilize Build Inputs

- **Goal:** Make local Gradle task discovery and debug assembly reproducible.
- **Files:** `Application/build.gradle`, `.gitignore`, generated tracked files.
- **Patterns:** Replace JCenter with HTTPS Maven Central plus Google Maven, pin build-tools 24.0.3, remove duplicate support dependency, and stop tracking generated files.
- **Test Scenarios:**
  - Source check fails if JCenter returns.
  - Source check fails if build-tools is not 24.0.3.
  - Source check fails if generated files remain tracked.
- **Verification:** `scripts/check-baseline.sh`, `./gradlew tasks --no-daemon`, `./gradlew assembleDebug --no-daemon`, `./gradlew assembleDebugTest --no-daemon`

### U2. Repair Test Fixture

- **Goal:** Keep the instrumentation smoke test compile-aligned with the activity implementation.
- **Files:** `Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java`
- **Patterns:** Use `getFragmentManager().findFragmentById(R.id.container)` rather than support-fragment APIs.
- **Test Scenarios:**
  - `assembleDebug` compiles app sources.
  - Source check fails if `getSupportFragmentManager()` returns.
- **Verification:** `scripts/check-baseline.sh`, `./gradlew assembleDebugTest --no-daemon`

### U3. Harden Camera Lifecycle Edges

- **Goal:** Avoid crashes when camera outputs, storage, or background thread state are unavailable.
- **Files:** `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`
- **Patterns:** Guard missing activity, camera manager, stream output sizes, camera setup, capture session, background thread, image, and output file state.
- **Test Scenarios:**
  - Source check fails if camera output arrays are not null/empty guarded.
  - Source check fails if image saving can run without an image or destination file.
  - Source check fails if `stopBackgroundThread` can dereference a null thread.
- **Verification:** `scripts/check-baseline.sh`, Gradle assemble

### U4. Document and Guard Baseline

- **Goal:** Provide maintainers a repeatable maintenance gate.
- **Files:** `README.md`, `scripts/check-baseline.sh`, `docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md`
- **Patterns:** Short toolchain, verification, and modernization notes; POSIX shell source checks.
- **Test Scenarios:**
  - README documents `scripts/check-baseline.sh`.
  - Script checks repositories, dependency pins, generated file hygiene, manifest package, camera permission, and test fixture shape.
- **Verification:** `scripts/check-baseline.sh`

---

## Risks & Dependencies

- Runtime camera behavior still requires an emulator or device with camera support.
- The app remains on old Camera2 sample code and pre-runtime-permission assumptions.
- Full Gradle migration should be a separate behavior-aware pass.

---

## Sources / Research

- `Application/build.gradle` declares repositories, build-tools, support dependencies, and source sets.
- `Application/src/main/AndroidManifest.xml` declares the Camera2 package and camera permission.
- `Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java` contains the smoke test fixture.
- `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java` owns camera setup and image saving.
- `gradle/wrapper/gradle-wrapper.properties` pins Gradle 2.2.1.
