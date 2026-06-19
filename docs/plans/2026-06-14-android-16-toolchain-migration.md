---
title: Android 16 Toolchain Migration
type: modernization
status: completed
date: 2026-06-14
---

# Android 16 Toolchain Migration

## Status: Completed

## Problem Frame

CameraApp still builds with Android Gradle Plugin 1.0.0, Gradle 2.2.1,
compile/target SDK 21, and three support-library artifacts that application
source does not use. Removing those artifacts in isolation exposed legacy
target-SDK lint coupling, so the dependency boundary cannot be corrected
truthfully without moving the build and runtime behavior to a supported Android
baseline. Targeting current Android also requires runtime camera permission and
modern manifest/build metadata that the SDK-21 sample never needed.

Primary Android documentation identifies Android Gradle Plugin 9.2.0 with
JDK 17 as the current stable compatibility line. Gradle 9.5.1 is the current
stable build runtime and satisfies AGP 9.2.0's minimum, while Android
16 development uses compile/target SDK 36 with current 36.x build tools.

## Prioritized Engineering Tasks

1. Upgrade the verified Gradle wrapper, Android Gradle Plugin, repositories,
   Java toolchain, and Android DSL to the current stable compatibility line.
2. Compile and target Android 16 while preserving the existing API-21 minimum.
3. Remove the unused support-v4, support-v13, and cardview-v7 dependency graph.
4. Add an explicit runtime camera-permission flow that opens the camera only
   after permission is granted and fails closed after denial.
5. Modernize instrumentation metadata/source-set configuration enough to keep
   the historical smoke test compilable without introducing AndroidX runtime
   dependencies.
6. Preserve zero-finding lint, debug APK assembly, camera lifecycle guards,
   resource integrity, and root/external Make behavior.

## Requirements

### R1. Current Supported Build Toolchain

- Pin Android Gradle Plugin 9.2.0 and Gradle 9.5.1.
- Pin the official Gradle distribution SHA-256 and retain wrapper URL
  validation.
- Build under JDK 17 and fail clearly on unsupported Java runtimes.
- Use `google()` and `mavenCentral()` only; do not restore JCenter or legacy
  repository URLs.

### R2. Android 16 Baseline

- Set compile and target SDK to 36 and use stable 36.x build tools.
- Preserve min SDK 21 and the existing application ID/package identity.
- Declare an explicit application namespace and modern lint DSL.
- Keep backup disabled and preserve the camera feature/permission manifest
  boundary.
- Target-36 edge-to-edge behavior must not place camera controls, permission
  explanations, or dialogs behind system bars; inset handling must preserve the
  full-bleed preview while protecting interactive UI.

### R3. Runtime Camera Permission

- API 23+ must check `CAMERA` permission before camera setup or open.
- A missing permission must launch one request at a time and must not acquire
  the camera semaphore or invoke `CameraManager.openCamera`.
- Grant resumes camera opening only while the fragment view is active.
- Denial shows a bounded user-visible explanation and leaves camera resources
  closed; no retry loop or settings redirect is introduced.
- API 21-22 behavior remains unchanged because install-time permission applies.

### R4. Dependency Boundary

- Application compile/runtime dependencies must be empty after migration.
- Java, XML, and manifests must remain free of `android.support`, AndroidX,
  support widgets, and compatibility fragments.
- Test-only dependencies may be added only when required for executable tests
  and must not enter the application runtime graph.

### R5. Verification And Mutation Resistance

- The SDK-free baseline must enforce toolchain versions, repository policy,
  SDK levels, namespace, dependency absence, and permission ordering.
- Android lint must report zero findings for debug and release variants.
- Debug Java compilation, instrumentation-test compilation, and APK assembly
  must pass under the pinned wrapper/JDK/SDK combination.
- GitHub Actions must provision JDK 17 and run the same SDK-backed lint/build
  gate with read-only permissions and bounded execution.
- Focused hostile mutations must be rejected for version drift, support
  dependency restoration, permission bypass, denial handling, weakened lint,
  wrapper provenance, documentation, and plan status.
- The completed plan must record actual commands and unavailable runtime
  coverage without inference.

## Scope Boundaries

- Preserve camera selection, preview sizing, capture output, orientation,
  background-thread, semaphore, ImageReader, and resource behavior unless a
  target-36 compatibility failure requires a narrow correction.
- Do not migrate platform fragments or views to AndroidX merely for style.
- Do not add Compose, Kotlin, dependency injection, navigation, or a new UI
  architecture.
- Do not lower lint severity, add blanket suppressions, or hide target-SDK
  findings.
- Do not merge or close any pull request without explicit owner authorization.

## Implementation Units

### U1. Modernize Build And Wrapper

Files:

- Modify `build.gradle`
- Modify `Application/build.gradle`
- Modify `settings.gradle`
- Modify `gradle/wrapper/gradle-wrapper.properties`
- Regenerate and verify `gradlew`, `gradlew.bat`, and
  `gradle/wrapper/gradle-wrapper.jar` only from current Gradle tooling

Approach:

- Move plugin repositories and dependency resolution to supported endpoints.
- Adopt the current application plugin DSL, namespace, SDK assignments, Java
  17 compatibility, modern lint block, and source-set syntax.
- Remove all application dependency declarations.

### U2. Add Permission-Safe Camera Startup

Files:

- Modify `Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java`
- Modify relevant strings and, only if required, layouts/styles

Approach:

- Gate the existing `openCamera` path before camera output setup and lock
  acquisition.
- Track an outstanding request so repeated surface/resume callbacks cannot
  launch duplicate permission prompts.
- Re-enter camera startup after a grant only when attachment, view, texture,
  and lifecycle state still permit it.
- Keep denial handling finite and resource-free.
- Apply platform window insets to interactive controls without shrinking the
  camera preview surface.

### U3. Modernize Test And Manifest Metadata

Files:

- Modify `Application/src/main/AndroidManifest.xml`
- Modify `Application/tests/AndroidManifest.xml`
- Modify `Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java`
  only where current compilation requires it

Approach:

- Move package identity owned by the build into namespace/test namespace.
- Retain the platform instrumentation smoke boundary when it remains supported;
  otherwise replace it with the smallest executable current test surface that
  does not add application runtime dependencies.

### U4. Strengthen Gates And Documentation

Files:

- Modify `scripts/check-baseline.sh`
- Modify `Makefile` and `.github/workflows/check.yml` as required
- Modify `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, and `CHANGES.md`
- Complete this plan after measured verification

Approach:

- Replace legacy-version/checksum contracts with the modern toolchain and
  permission-ordering invariants.
- Require JDK 17 and explicit Android SDK 36 availability for SDK-backed gates.
- Keep CI action references immutable and install only the exact Android SDK
  packages required by the modern build.
- Keep generated build outputs ignored and prevent local SDK/JDK paths from
  entering tracked configuration.

## Verification Plan

- Verify official AGP compatibility metadata and Gradle distribution checksum.
- Install or provision only the missing stable Android 36 build-tools package
  under the existing SDK, with checksum verification.
- Run SDK-free baseline and wrapper provenance checks before network-backed
  Gradle execution.
- Run dependency reports, debug/release lint, Java/test compilation, debug APK
  assembly, `make check`, `make verify`, and external-working-directory gates
  with JDK 17 and the configured Android SDK.
- Inspect the merged manifest and built APK metadata for application ID,
  min/target SDK, camera permission, camera feature, backup policy, and absence
  of support-library runtime artifacts.
- Use static layout contracts and any available emulator/device runtime to
  verify system-inset protection for both portrait and landscape controls.
- Run focused mutation cases and exact-path artifact, secret, whitespace,
  conflict-marker, and dependency-lock audits.

## Runtime Qualification

An emulator or physical API-23+ camera device is required to prove the grant,
denial, resume, preview, and capture flows. If no compatible runtime is present,
the implementation may ship only with compilation, lint, manifest/APK, static
ordering, and mutation evidence, and the missing runtime coverage must remain an
explicit risk in the plan, PR, and tracker.

## Implementation Outcome

- Upgraded to Android Gradle Plugin 9.2.0, Gradle 9.5.1, JDK 17,
  compile/target SDK 36, and Build Tools 36.1.0 while preserving min SDK 21.
- Removed all application runtime dependencies. AndroidX core, runner, and
  JUnit integration remain confined to `androidTestImplementation`.
- Added permission-first camera startup, one-request-at-a-time handling,
  denial feedback, retained-view teardown, and target-36 system-bar insets for
  interactive controls.
- Added namespace-owned manifests, a required camera feature, explicit backup
  and device-transfer exclusions, a current instrumentation smoke test, and a
  full hosted SDK-backed gate.
- Kept hosted provisioning within repository policy by using the runner's
  preinstalled `$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager` rather than
  an unapproved third-party setup action.

## Verification Results

Completed on 2026-06-14 with JDK 17 and the Android SDK rooted at the explicit
`JAVA_HOME` and `ANDROID_HOME` values supplied to each command:

- `timeout 120 sh scripts/check-baseline.sh` passed.
- `timeout 900 env JAVA_HOME=... ANDROID_HOME=... ANDROID_SDK_ROOT=... make check`
  passed from the repository root.
- `timeout 900 env JAVA_HOME=... ANDROID_HOME=... ANDROID_SDK_ROOT=... make -f /absolute/path/to/Makefile check`
  passed from `/tmp`, proving external-working-directory resolution.
- `./gradlew :Application:dependencies --configuration debugRuntimeClasspath --no-daemon`
  reported `No dependencies`.
- Debug and release lint XML reports each contained zero issues.
- `aapt dump badging` confirmed application ID
  `com.example.android.camera2basic`, compile SDK 36, min SDK 21, target SDK
  36, CAMERA permission, and the complete mdpi-through-xxxhdpi launcher set.
- The merged debug manifest retained the required camera feature, disabled
  backup, Android 12+ extraction rules, legacy full-backup rules, and exported
  launcher activity. The app APK contained no Kotlin runtime entries.
- Thirteen isolated hostile mutations were rejected across AGP/wrapper drift,
  runtime dependencies, compile SDK, permission ordering/request/teardown,
  controls insets, backup policy, instrumentation runner, Make routing, CI SDK
  provisioning, and README toolchain evidence.

No camera-capable emulator or physical device was available. Permission grant,
permission denial, preview, still capture, system-bar appearance, and lifecycle
behavior therefore remain runtime qualification work and are not claimed as
executed by this plan.

## Primary References

- Android Gradle Plugin 9.2 release notes:
  https://developer.android.com/build/releases/gradle-plugin
- Android 16 SDK setup:
  https://developer.android.com/about/versions/16/setup-sdk
- Gradle 9.5.1 distribution checksum:
  https://services.gradle.org/distributions/gradle-9.5.1-bin.zip.sha256
