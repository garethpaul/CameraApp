# CameraApp

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/CameraApp` is an Android application or sample. The checked-in files describe a Android application or sample with the structure summarized below.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Java (4), shell (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `build.gradle` - Android or Gradle build configuration
- `.google` - source or example code
- `Application` - source or example code
- `docs` - source or example code
- `gradle` - source or example code
- `gradlew` - Android or Gradle build configuration
- `scripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: .google, Application, docs, gradle, scripts
- Dependency and build manifests: build.gradle, gradlew
- Entry points or build surfaces: Gradle build files
- Test-looking files: Application/tests/AndroidManifest.xml, Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java

## Getting Started

### Prerequisites

- Git
- Android Studio or a compatible Android SDK
- Gradle or the checked-in Gradle wrapper when present

### Setup

```bash
git clone https://github.com/garethpaul/CameraApp.git
cd CameraApp
```

Configure the Android SDK with `ANDROID_HOME` or an untracked `local.properties` file:

```properties
sdk.dir=/path/to/android-sdk
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.
- This legacy sample uses Gradle 2.2.1, Android Gradle Plugin 1.0.0, compile/min/target SDK 21, and Android Build Tools v24.0.3.

## Testing and Verification

Run the SDK-free source baseline check first:

```sh
make check
scripts/check-baseline.sh
```

Then run Gradle after Android SDK configuration is available:

```sh
ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon
```

The Gradle lint configuration suppresses only the legacy `LintError` for the missing API database infrastructure issue. Instrumentation tests require an Android device or emulator with camera support.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.

## Security and Privacy Notes

- Review changes touching authentication or token handling; examples from the scan include Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java, docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md, scripts/check-baseline.sh.
- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include docs/plans/2026-06-08-cameraapp-reproducible-build-baseline.md.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include Application/build.gradle, Application/src/main/AndroidManifest.xml, Application/src/main/java/com/example/android/camera2basic/AutoFitTextureView.java, Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java, and 6 more.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include .google/packaging.yaml, Application/src/main/AndroidManifest.xml, Application/src/main/java/com/example/android/camera2basic/AutoFitTextureView.java, Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java, and 6 more.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include Application/src/main/AndroidManifest.xml, Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java, Application/src/main/res/layout/activity_camera.xml, Application/src/main/res/layout/fragment_camera2_basic.xml, and 6 more.
- Review changes touching database, model, or persistence code; examples from the scan include docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md, docs/plans/2026-06-08-cameraapp-reproducible-build-baseline.md.

## Maintenance Notes

- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- Camera background thread startup is idempotent; repeated resume/start paths
  must not replace an already-running handler thread.
- ImageReader backpressure is handled by dropping a backed-up capture callback
  before it can crash the still-image save path.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for the maintenance history.
- See `docs/plans/2026-06-08-cameraapp-check-wrapper.md` for the root
  verification wrapper baseline.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
