# CameraApp CI Baseline

## Status: Completed

## Context

`CameraApp` has an SDK-free Camera2 source baseline and guarded Gradle gates
behind `make check`. The repository needs the same wrapper to run in GitHub
Actions so camera lifecycle, privacy, and build hygiene contracts are checked
before review.

## Objectives

- Run the existing `make check` wrapper in GitHub Actions.
- Keep the CI job useful even when a legacy Android SDK is unavailable.
- Prevent hosted runner SDK variables from invoking the legacy Gradle stack.
- Minimize workflow token access and pin third-party action code by commit.
- Make the workflow presence part of the SDK-free baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Cleared `ANDROID_HOME` and `ANDROID_SDK_ROOT` so hosted runners take the
  intentional SDK-free path instead of invoking Gradle 2.2.1 on a modern JDK.
- Pinned `actions/checkout` to a reviewed commit, limited repository access to
  read-only, and bounded runs with a timeout and concurrency cancellation.
- Reused the existing guarded Makefile targets, which run SDK-free checks and
  skip Gradle work when the Android SDK is absent.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Add Android SDK-backed CI once the legacy build-tools and camera-capable test
  target are pinned for hosted runners.
