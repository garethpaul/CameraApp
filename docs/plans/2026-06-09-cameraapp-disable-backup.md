# CameraApp Disable Backup

Status: Completed
Date: 2026-06-09

## Goal

Keep the camera sample from opting app data into Android platform backup by
default.

## Changes

- Set `android:allowBackup="false"` in the application manifest.
- Extended the SDK-free baseline to enforce the disabled-backup contract.
- Documented the privacy baseline in the README, changelog, and vision.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew lint --no-daemon`
- `./gradlew assembleDebug --no-daemon`
- `git diff --check`
