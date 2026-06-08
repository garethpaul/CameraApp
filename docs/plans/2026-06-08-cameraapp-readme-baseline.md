# CameraApp README Baseline

## Goal

Keep the generated README aligned with the legacy Android build hygiene baseline.

## Scope

- Document local Android SDK configuration without committing `local.properties`.
- Preserve the Gradle wrapper, Android Gradle Plugin, SDK, and Build Tools v24.0.3 baseline.
- Document the scoped `LintError` suppression used by the legacy lint runner.
- Avoid changing application source or Gradle dependency pins.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
