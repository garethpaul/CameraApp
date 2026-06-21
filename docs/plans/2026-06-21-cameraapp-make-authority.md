# CameraApp Make Authority

Status: Completed

## Goal

Keep the root verification command authoritative when it is invoked from an
external directory or with hostile Make startup files, later makefiles,
execution modes, shell overrides, or toolchain values.

## Changes

- Resolve and freeze the canonical repository root before public recipes run.
- Require literal Android SDK, JDK, Gradle, and instrumentation-skip values.
- Fix the recipe shell and reject startup makefiles, later public-target recipe
  replacement, and non-executing or error-ignoring Make modes.
- Exercise the authority boundary with a hermetic fake JDK, SDK, and Gradle
  harness that does not require Android packages.
- Use `/usr/bin/make check` in the normal hosted workflow without changing the
  base-owned trusted pull-request verifier.

## Verification

- `scripts/test-makefile-root.sh`
- `scripts/check-baseline.sh`
- `/usr/bin/python3 -I -S -B -m unittest discover -s trusted-verifier/tests -p 'test_*.py' -v`
- Hosted `/usr/bin/make check` with JDK 17, Android SDK 36, Build Tools 36.1.0,
  and API 36 instrumentation.
