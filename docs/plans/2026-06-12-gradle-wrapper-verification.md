---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Authenticate the direct Gradle wrapper used by Make and stop hosted checkout
credentials from persisting, while retaining Gradle 2.2.1, Android Gradle
Plugin 1.0.0, API 21, build-tools 24.0.3, and camera behavior.

## Requirements

- Regenerate all wrapper artifacts with official Gradle 8.14.5 tooling while
  retaining the official Gradle 2.2.1 all distribution.
- Pin the official distribution SHA-256 and exact generated wrapper artifacts.
- Keep Make using the direct wrapper and preserve all Android build/runtime
  versions, modules, sources, manifests, and camera behavior.
- Disable checkout credential persistence and enforce exact workflow trust
  contracts without weakening Check or default CodeQL.
- Pass fresh-cache bootstrap, incorrect-checksum rejection, SDK-free and
  SDK-backed gates, external-working-directory execution, hostile mutations,
  and exact-head hosted checks.

## Scope And Verification

This unit changes only the four wrapper files, Check workflow, static checker,
guidance, and evidence. It does not change application or Gradle build logic.

## Sources

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle 2.2.1 checksum](https://services.gradle.org/distributions/gradle-2.2.1-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)

## Work Completed

- Regenerated all four wrapper artifacts with official Gradle 8.14.5 tooling
  while retaining the Gradle 2.2.1 all distribution and app build logic.
- Added the official distribution checksum, exact artifact contracts, and
  credential-free checkout enforcement.
- Preserved every application, manifest, Gradle build, and camera behavior file.

## Verification Completed

- A fresh temporary Gradle user home authenticated and launched Gradle 2.2.1
  under Java 8; an incorrect checksum was rejected before execution.
- SDK-backed `make check` passed with the existing 13 lint findings per variant
  and debug APK assembly; SDK-free and external working directory gates passed.
- Focused hostile mutations rejected wrapper, checksum, workflow, documentation,
  and incomplete-plan drift; all hostile mutations rejected.
- YAML/shell parsing, `git diff --check`, and secret scanning passed.

## Hosted Verification

Exact-head Check and default CodeQL evidence will be recorded after push.
Tracker reconciliation remains pending until both are terminal green.
