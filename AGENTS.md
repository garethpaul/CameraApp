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
- Android unit tests when the SDK is configured: `./gradlew test`
- Android debug build when the SDK is configured: `./gradlew assembleDebug`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

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
- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- Camera background thread startup is idempotent; repeated resume/start paths must not replace an already-running handler thread.
- ImageReader backpressure is handled by dropping a backed-up capture callback before it can crash the still-image save path.
- Android backup is disabled for the app because the sample handles camera capture state and app-specific image output.
- Resume skips camera open until the texture view is recreated, avoiding retained fragment camera work before the view hierarchy exists.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
