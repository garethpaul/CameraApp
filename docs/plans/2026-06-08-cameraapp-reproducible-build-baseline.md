---
title: CameraApp Reproducible Build Baseline
type: chore
status: superseded
date: 2026-06-08
---

# CameraApp Reproducible Build Baseline

Superseded by `docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md`,
which keeps the generated-file cleanup and also removes JCenter, pins
host-compatible build-tools 24.0.3, drops the duplicate support dependency, and
repairs the instrumentation fixture.

## Summary

Raise the baseline for the legacy Android Camera2 sample by removing tracked
machine-local and generated build artifacts, restoring an executable Gradle
wrapper, aligning the build-tools pin with an installed SDK version, and adding
a source-level repository guard.

---

## Problem Frame

The repository tracked `.gradle/`, `.idea/`, `Application/build/`,
`Application/Application.iml`, and `local.properties`. The checked-in
`local.properties` pointed to `/opt/twitter/opt/android-sdk`, which breaks
builds on other machines before Gradle can resolve the project. The Gradle
wrapper also lacked executable mode, and the app requested build-tools `21.1.1`
even though the available SDK on this host provides `22.0.1`, `23.0.3`, and
`24.0.3`. After the SDK path was fixed, debug assembly also exposed duplicate
support-v4 dex classes from the obsolete `com.google.android:support-v4:r7`
dependency alongside `com.android.support:support-v4:21.0.2`. The legacy lint
runner reports a `LintError` because this host's API 21 platform is missing the
API database file, so the build suppresses that infrastructure issue while
leaving source lint errors enabled.

---

## Requirements

- R1. Machine-local SDK paths and generated Gradle/Android Studio artifacts must not be tracked.
- R2. `.gitignore` must keep those generated paths out of future commits.
- R3. `gradlew` must be executable for CLI verification.
- R4. The app must keep its legacy Gradle, Android plugin, compile SDK, min SDK, target SDK, and camera permission pins explicit.
- R5. The build-tools version must use an installed SDK baseline.
- R6. The dependency graph must not include duplicate support-v4 artifacts.
- R7. Lint must suppress only the missing API database infrastructure issue.
- R8. README and a baseline script must document and verify the reproducibility contract.

---

## Key Technical Decisions

- **Remove generated files from git:** Build output and IDE caches are
  deterministic products of the Gradle build or local editor state.
- **Do not track `local.properties`:** Developers should use `ANDROID_HOME` or
  their own untracked SDK path.
- **Use build-tools 24.0.3:** It is installed locally and avoids the host
  library issue hit by the older `22.0.1` `aapt` binary.
- **Keep the old plugin:** This pass avoids a larger Android Gradle Plugin
  migration and focuses on getting the existing project reproducible.
- **Remove the duplicate support-v4 artifact:** The app keeps
  `com.android.support:support-v4:21.0.2` and drops the older
  `com.google.android:support-v4:r7` declaration that causes duplicate dex
  classes.
- **Suppress only `LintError`:** This keeps the `check` task usable on the
  local SDK while avoiding `abortOnError false`, which would hide real lint
  errors.

---

## Implementation Units

### U1. Repository Hygiene

- **Goal:** Remove generated and machine-local files from version control.
- **Files:** `.gitignore`, removed `.gradle/`, `.idea/`, `Application/build/`, `Application/Application.iml`, `local.properties`
- **Verification:** `scripts/check-baseline.sh`

### U2. Legacy Build Baseline

- **Goal:** Make CLI Gradle invocation possible on a clean checkout with the
  installed SDK.
- **Files:** `gradlew`, `Application/build.gradle`, `README.md`
- **Verification:** `ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon`, `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`

### U3. Guard and Documentation

- **Goal:** Prevent generated artifacts or local SDK paths from re-entering the
  repository.
- **Files:** `scripts/check-baseline.sh`, `README.md`, this plan
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

---

## Risks & Dependencies

- The project still uses Gradle 2.2.1 and Android Gradle Plugin 1.0.0.
- A full dependency modernization would need a separate migration across
  AndroidX, newer Camera2 APIs, and current build tooling.
- Device/emulator camera behavior is not exercised by this source-level pass.

---

## Sources / Research

- `Application/build.gradle` defines the legacy Android build pins.
- `Application/src/main/AndroidManifest.xml` declares the camera permission.
- `gradle/wrapper/gradle-wrapper.properties` pins Gradle 2.2.1.
- Local SDK inspection showed build-tools `24.0.3` available.
