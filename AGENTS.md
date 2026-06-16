# AGENTS.md

## Repository purpose

`garethpaul/CameraApp` is an Android application or sample. The checked-in files describe a Android application or sample with the structure summarized below.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `Application` - application module
- `build.gradle` - Gradle build configuration
- `gradlew` - checked-in Gradle wrapper

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Source-only contract: `scripts/check-baseline.sh`
- Android instrumentation APK: `./gradlew :Application:assembleDebugAndroidTest`
- Android debug build: `./gradlew :Application:assembleDebug`
- Use JDK 17, SDK platform 36, and Build Tools 36.1.0. Runtime permission,
  preview, and capture claims additionally require a camera-capable device.

## Coding conventions

- Language mix noted in the README: Java (4), shell (1).
- Use the checked-in Gradle wrapper for Android builds when an SDK is configured.

## Testing guidance

- Test-related files detected: `Application/tests/`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.
- This is a preserved Camera2 sample on AGP 9.2.0 and Gradle 9.5.1. Keep JDK
  17, SDK 36, Build Tools 36.1.0, and the wrapper checksum aligned.
- The application runtime dependency graph is empty; AndroidX belongs only in
  instrumentation test configurations.
- API-23+ camera setup and open operations must remain ordered after the
  runtime permission grant.
- Retained fragments must clear texture-view references in `onDestroyView`
  before delayed permission results can be delivered.
- Target-36 edge-to-edge behavior must keep interactive camera controls inside
  system-bar insets without shrinking the full-bleed preview.
- Camera background thread startup is idempotent; repeated resume/start paths must not replace an already-running handler thread.
- Interrupted camera-worker shutdown preserves the interrupt signal and unresolved worker ownership.
- Device disconnect and error callbacks close their callback-owned device before rejecting stale shared ownership.
- Capture-result and still-capture completion callbacks reject stale session ownership before mutating capture state or unlocking focus.
- ImageReader backpressure is handled by dropping a backed-up capture callback before it can crash the still-image save path.
- During background-thread shutdown, rejected image-save handoffs close the
  callback-owned image instead of consuming `ImageReader` capacity.
- Image-save failures log a generic category without exception details or private output paths.
- Camera runtime diagnostics retain fixed operation categories without exception stack traces or throwable details.
- Android backup is disabled for the app because the sample handles camera capture state and app-specific image output.
- Resume skips camera open until the texture view is recreated, avoiding retained fragment camera work before the view hierarchy exists.

## Agent workflow

- Preserve the complete xxxhdpi icon family and the zero-finding Android lint
  gate when changing active camera resources.

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
