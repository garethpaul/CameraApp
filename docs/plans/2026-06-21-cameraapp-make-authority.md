# CameraApp Make Authority

Status: Completed

## Goal

Keep the root verification command authoritative when it is invoked from an
external directory with repository-owned Make inputs, and state the caller-owned
GNU Make boundary truthfully.

## Changes

- Resolve and freeze the canonical repository root before public recipes run.
- Require literal Android SDK, JDK, Gradle, and instrumentation-skip values.
- Fix the recipe shell and reject non-executing or error-ignoring Make modes.
- Preserve marker-backed controls showing that caller-supplied GNU Make startup
  files and additional `-f` makefiles remain caller parse authority: startup
  and later makefiles can execute code before repository checks.
- Reproduce later target-specific `MAKEFILE_LIST` restoration,
  `SHELL`/`.SHELLFLAGS` false-success, and double-colon recipe append behavior
  as caller-owned paths rather than claiming the repository Makefile blocks
  them.
- Keep a marker-backed rejection for a later makefile that does not restore the
  canonical `MAKEFILE_LIST` value.
- Caller-supplied later makefiles, including target-specific MAKEFILE_LIST restoration, target-specific SHELL/.SHELLFLAGS overrides, and double-colon public recipes, are outside the local Make trust boundary.
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
