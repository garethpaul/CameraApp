# Remove Unused Android Support Dependencies

Status: Planned

## Problem

The application module declares support-v4, support-v13, and cardview-v7
21.0.2, but the checked-in Java and XML use platform framework fragments,
dialogs, activities, views, and layouts only. These unused 2014-era artifacts
expand the legacy build graph and repository trust surface without providing
runtime behavior.

## Prioritized Tasks

1. Remove all unused support-library declarations and the now-empty
   application dependency repository block.
2. Add dependency-free static contracts so platform-only source cannot silently
   regain support-library or AndroidX coupling.
3. Preserve the existing Camera2 lifecycle, UI, resource, SDK, lint, and APK
   behavior through the full Android gate.
4. Document the narrower dependency boundary and measured Gradle evidence.

## Requirements

1. `Application/build.gradle` must not declare app runtime or compile
   dependencies after the cleanup.
2. Application Java and XML must remain free of `android.support`, `androidx`,
   and support-widget references.
3. The SDK-free checker must reject restored dependency or support-import
   mutations.
4. Android lint must remain at zero findings and the debug APK must assemble.
5. The plan and repository guidance must record completed, truthful
   verification.

## Scope Boundaries

- Do not change the Gradle wrapper, Android Gradle Plugin, compile/target SDK,
  Java language level, package name, camera behavior, or UI resources.
- Do not migrate platform fragments to AndroidX in this narrow cleanup.
- Keep buildscript repositories required by the historical Android Gradle
  Plugin unchanged.
- Do not merge or close any pull request without explicit owner authorization.

## Implementation

- Modify `Application/build.gradle` to remove the unused application
  repositories and dependencies blocks.
- Extend `scripts/check-baseline.sh` with build-file and source-tree contracts.
- Update `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, and `CHANGES.md`.
- Complete this plan only after local and mutation verification is measured.

## Verification

- Compare Gradle dependency reports before and after the cleanup.
- Run the dependency-free baseline, Gradle lint, debug assembly, and full
  `make check`/`make verify` wrappers with the configured Android SDK.
- Reject mutations restoring each dependency, adding a support/AndroidX import,
  weakening the checker, removing guidance, or reopening plan status.
- Audit exact paths, generated artifacts, whitespace, conflict markers, shell
  syntax, and credential-shaped additions.

## Residual Risks

- The Gradle 2.2.1, Android Gradle Plugin 1.0.0, and target SDK 21 stack remains
  legacy and should be modernized in a separate compatibility-focused change.
- No emulator or physical camera session is exercised by this dependency-only
  cleanup.
