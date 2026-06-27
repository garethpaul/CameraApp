#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_BUILD="$ROOT_DIR/Application/build.gradle"
ROOT_BUILD="$ROOT_DIR/build.gradle"
SETTINGS="$ROOT_DIR/settings.gradle"
GRADLE_PROPERTIES="$ROOT_DIR/gradle.properties"
MANIFEST="$ROOT_DIR/Application/src/main/AndroidManifest.xml"
README="$ROOT_DIR/README.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md"
GITIGNORE="$ROOT_DIR/.gitignore"
TEST_MANIFEST="$ROOT_DIR/Application/tests/AndroidManifest.xml"
TEST_FIXTURE="$ROOT_DIR/Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java"
FRAGMENT="$ROOT_DIR/Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java"
TEXTURE_RESUME_PLAN="$ROOT_DIR/docs/plans/2026-06-09-cameraapp-texture-resume-guard.md"
SAVE_TOAST_PLAN="$ROOT_DIR/docs/plans/2026-06-09-cameraapp-save-toast-path-privacy.md"
CONTROL_BINDING_PLAN="$ROOT_DIR/docs/plans/2026-06-09-cameraapp-control-binding-guard.md"
ERROR_DIALOG_PLAN="$ROOT_DIR/docs/plans/2026-06-09-cameraapp-error-dialog-fragment-manager.md"
ERROR_DIALOG_ACTIVITY_PLAN="$ROOT_DIR/docs/plans/2026-06-09-cameraapp-error-dialog-activity-guard.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
CAMERA_OPEN_LOCK_PLAN="$ROOT_DIR/docs/plans/2026-06-10-cameraapp-open-lock-release.md"
CAMERA_CLOSE_LOCK_PLAN="$ROOT_DIR/docs/plans/2026-06-12-cameraapp-close-lock-ownership.md"
CAMERA_OPEN_CALLBACK_LOCK_PLAN="$ROOT_DIR/docs/plans/2026-06-26-cameraapp-open-callback-lock-ownership.md"
CAMERA_OPEN_CALLBACK_PUBLICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-26-cameraapp-open-callback-publication.md"
TOAST_HANDLER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-cameraapp-toast-handler-lifecycle.md"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
RTL_LAYOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-13-cameraapp-rtl-layout.md"
LANDSCAPE_OVERLAP_PLAN="$ROOT_DIR/docs/plans/2026-06-13-cameraapp-landscape-overlap.md"
INACTIVE_TEMPLATE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-cameraapp-inactive-template-resources.md"
WINDOW_BACKGROUND_PLAN="$ROOT_DIR/docs/plans/2026-06-13-cameraapp-window-background-overdraw.md"
XXXHDPI_ICON_PLAN="$ROOT_DIR/docs/plans/2026-06-13-cameraapp-xxxhdpi-icons.md"
ANDROID_16_PLAN="$ROOT_DIR/docs/plans/2026-06-14-android-16-toolchain-migration.md"
IMAGE_HANDOFF_PLAN="$ROOT_DIR/docs/plans/2026-06-14-cameraapp-image-handoff-ownership.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-cameraapp-device-verification-checklist.md"
SAVE_SUCCESS_PLAN="$ROOT_DIR/docs/plans/2026-06-14-cameraapp-save-success-notification.md"
SAVE_FAILURE_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-cameraapp-save-failure-log-redaction.md"
BACKGROUND_INTERRUPT_PLAN="$ROOT_DIR/docs/plans/2026-06-15-cameraapp-background-interrupt-restoration.md"
CAMERA_ERROR_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-cameraapp-camera-error-log-redaction.md"
PREVIEW_SESSION_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-15-cameraapp-preview-session-ownership.md"
PREVIEW_FAILURE_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-15-cameraapp-preview-configuration-failure-ownership.md"
DEVICE_CALLBACK_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-15-cameraapp-device-callback-ownership.md"
CAPTURE_CALLBACK_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-capture-callback-ownership.md"
CAPTURE_FAILURE_RECOVERY_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-capture-failure-recovery.md"
SYNCHRONOUS_CAPTURE_RECOVERY_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-synchronous-capture-recovery.md"
MISSING_CAPTURE_DEPENDENCY_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-missing-capture-dependency-recovery.md"
CLOSED_SESSION_CAPTURE_RECOVERY_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-closed-session-capture-recovery.md"
FOCUS_STATE_RECOVERY_PLAN="$ROOT_DIR/docs/plans/2026-06-25-cameraapp-focus-state-recovery.md"
PREVIEW_SESSION_RECOVERY_PLAN="$ROOT_DIR/docs/plans/2026-06-25-cameraapp-preview-session-recovery.md"
INSTRUMENTATION_EXECUTION_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-instrumentation-execution.md"
PERMISSION_DENIAL_INSTRUMENTATION_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-permission-denial-instrumentation.md"
PERMISSION_DENIAL_RECREATION_PLAN="$ROOT_DIR/docs/plans/2026-06-17-cameraapp-permission-denial-recreation.md"
GRADLE_96_REFRESH_PLAN="$ROOT_DIR/docs/plans/2026-06-19-gradle-9-6-refresh.md"
INSTRUMENTATION_RUNNER="$ROOT_DIR/scripts/run-instrumentation.sh"
INSTRUMENTATION_CLEANUP_TEST="$ROOT_DIR/scripts/tests/run-instrumentation-cleanup-test.sh"
XXXHDPI_LAUNCHER="$ROOT_DIR/Application/src/main/res/drawable-xxxhdpi/ic_launcher.png"
XXXHDPI_INFO="$ROOT_DIR/Application/src/main/res/drawable-xxxhdpi/ic_action_info.png"
ACTIVITY_LAYOUT="$ROOT_DIR/Application/src/main/res/layout/activity_camera.xml"
PORTRAIT_LAYOUT="$ROOT_DIR/Application/src/main/res/layout/fragment_camera2_basic.xml"
LANDSCAPE_LAYOUT="$ROOT_DIR/Application/src/main/res/layout-land/fragment_camera2_basic.xml"
ACTIVE_STYLES="$ROOT_DIR/Application/src/main/res/values/styles.xml"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
TRUSTED_GATE_WORKFLOW="$ROOT_DIR/.github/workflows/trusted-cameraapp-gate.yml"
TRUSTED_GATE_PLAN="$ROOT_DIR/docs/plans/2026-06-20-cameraapp-trusted-direct-gate-v3.md"
TRUSTED_GATE_POLICY="$ROOT_DIR/trusted-verifier/policy.json"
TRUSTED_GATE_RUNNER="$ROOT_DIR/trusted-verifier/run-hermetic.sh"
TRUSTED_GATE_VERIFIER="$ROOT_DIR/trusted-verifier/verify_candidate.py"
TRUSTED_ENV_VERIFIER="$ROOT_DIR/trusted-verifier/verify_environment.py"
TRUSTED_GATE_TEST="$ROOT_DIR/trusted-verifier/tests/test_bootstrap.py"
TRUSTED_GATE_EXPECTED_ROOT="$ROOT_DIR/trusted-verifier/expected/ready-capture-state"
PREVIEW_TRUSTED_POLICY_PLAN="$ROOT_DIR/docs/plans/2026-06-25-cameraapp-preview-trusted-policy.md"
CALLBACK_LOCK_TRUSTED_POLICY_PLAN="$ROOT_DIR/docs/plans/2026-06-26-cameraapp-callback-lock-trusted-policy.md"
OPEN_PUBLICATION_TRUSTED_POLICY_PLAN="$ROOT_DIR/docs/plans/2026-06-26-cameraapp-open-publication-trusted-policy.md"
GRADLE_961_TRUSTED_POLICY_PLAN="$ROOT_DIR/docs/plans/2026-06-26-gradle-9-6-1-trusted-policy.md"
READY_CAPTURE_TRUSTED_POLICY_PLAN="$ROOT_DIR/docs/plans/2026-06-26-cameraapp-ready-capture-trusted-policy.md"
READY_CAPTURE_POLICY_CORRECTION_PLAN="$ROOT_DIR/docs/plans/2026-06-26-cameraapp-ready-capture-policy-correction.md"
BACKUP_RULES="$ROOT_DIR/Application/src/main/res/xml/backup_rules.xml"
DATA_EXTRACTION_RULES="$ROOT_DIR/Application/src/main/res/xml/data_extraction_rules.xml"

require_sha256() {
  file=$1
  expected=$2
  message=$3
  if [ "$(sha256sum "$file" | awk '{print $1}')" != "$expected" ]; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

expected_wrapper_properties() {
  cat <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=9c0f7faeeb306cb14e4279a3e084ca6b596894089a0638e68a07c945a32c9e14
distributionUrl=https\://services.gradle.org/distributions/gradle-9.6.1-bin.zip
networkTimeout=10000
retries=0
retryBackOffMs=500
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
}

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md must document repository maintenance." >&2
  exit 1
fi

if ! grep -Fq "CameraApp Changes" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must identify the project." >&2
  exit 1
fi

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".gitignore" \
  ".github/workflows/check.yml" \
  ".github/workflows/trusted-cameraapp-gate.yml" \
  "README.md" \
  "docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md" \
  "docs/plans/2026-06-09-cameraapp-image-reader-backpressure.md" \
  "docs/plans/2026-06-09-cameraapp-disable-backup.md" \
  "docs/plans/2026-06-09-cameraapp-texture-resume-guard.md" \
  "docs/plans/2026-06-09-cameraapp-save-toast-path-privacy.md" \
  "docs/plans/2026-06-09-cameraapp-control-binding-guard.md" \
  "docs/plans/2026-06-09-cameraapp-error-dialog-fragment-manager.md" \
  "docs/plans/2026-06-09-cameraapp-error-dialog-activity-guard.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-10-cameraapp-open-lock-release.md" \
  "docs/plans/2026-06-12-cameraapp-close-lock-ownership.md" \
  "docs/plans/2026-06-12-cameraapp-toast-handler-lifecycle.md" \
  "docs/plans/2026-06-12-gradle-wrapper-verification.md" \
  "docs/plans/2026-06-13-cameraapp-rtl-layout.md" \
  "docs/plans/2026-06-13-cameraapp-landscape-overlap.md" \
  "docs/plans/2026-06-13-cameraapp-inactive-template-resources.md" \
  "docs/plans/2026-06-13-cameraapp-window-background-overdraw.md" \
  "docs/plans/2026-06-13-cameraapp-xxxhdpi-icons.md" \
  "docs/plans/2026-06-14-android-16-toolchain-migration.md" \
  "docs/plans/2026-06-14-cameraapp-save-success-notification.md" \
  "docs/plans/2026-06-15-cameraapp-preview-session-ownership.md" \
  "docs/plans/2026-06-15-cameraapp-device-callback-ownership.md" \
  "docs/plans/2026-06-16-cameraapp-capture-failure-recovery.md" \
  "docs/plans/2026-06-16-cameraapp-synchronous-capture-recovery.md" \
  "docs/plans/2026-06-16-cameraapp-missing-capture-dependency-recovery.md" \
  "docs/plans/2026-06-16-cameraapp-closed-session-capture-recovery.md" \
  "docs/plans/2026-06-16-cameraapp-instrumentation-execution.md" \
  "docs/plans/2026-06-17-cameraapp-permission-denial-recreation.md" \
  "docs/plans/2026-06-19-gradle-9-6-refresh.md" \
  "docs/plans/2026-06-20-cameraapp-trusted-direct-gate-v3.md" \
  "docs/plans/2026-06-25-cameraapp-focus-trusted-policy.md" \
  "docs/plans/2026-06-25-cameraapp-preview-trusted-policy.md" \
  "docs/plans/2026-06-25-cameraapp-preview-session-recovery.md" \
  "docs/plans/2026-06-26-cameraapp-callback-lock-trusted-policy.md" \
  "docs/plans/2026-06-26-cameraapp-open-publication-trusted-policy.md" \
  "docs/plans/2026-06-26-gradle-9-6-1-trusted-policy.md" \
  "docs/plans/2026-06-26-cameraapp-ready-capture-trusted-policy.md" \
  "docs/plans/2026-06-26-cameraapp-ready-capture-policy-correction.md" \
  "scripts/run-instrumentation.sh" \
  "scripts/tests/run-instrumentation-cleanup-test.sh" \
  "trusted-verifier/policy.json" \
  "trusted-verifier/run-hermetic.sh" \
  "trusted-verifier/verify_candidate.py" \
  "trusted-verifier/verify_environment.py" \
  "trusted-verifier/tests/test_bootstrap.py" \
  "trusted-verifier/expected/ready-capture-state/AGENTS.md" \
  "trusted-verifier/expected/ready-capture-state/Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java" \
  "trusted-verifier/expected/ready-capture-state/CHANGES.md" \
  "trusted-verifier/expected/ready-capture-state/DEVICE_VERIFICATION.md" \
  "trusted-verifier/expected/ready-capture-state/README.md" \
  "trusted-verifier/expected/ready-capture-state/SECURITY.md" \
  "trusted-verifier/expected/ready-capture-state/VISION.md" \
  "trusted-verifier/expected/ready-capture-state/docs/plans/2026-06-26-cameraapp-ready-capture-state.md" \
  "trusted-verifier/expected/ready-capture-state/scripts/check-baseline.sh" \
  "Application/src/main/res/drawable-xxxhdpi/ic_launcher.png" \
  "Application/src/main/res/drawable-xxxhdpi/ic_action_info.png" \
  "gradlew" \
  "gradlew.bat" \
  "gradle/wrapper/gradle-wrapper.properties" \
  "gradle/wrapper/gradle-wrapper.jar" \
  "settings.gradle" \
  "build.gradle" \
  "gradle.properties" \
  "Application/build.gradle" \
  "Application/src/main/AndroidManifest.xml" \
  "Application/src/main/res/xml/backup_rules.xml" \
  "Application/src/main/res/xml/data_extraction_rules.xml" \
  "Application/src/main/res/layout/fragment_camera2_basic.xml" \
  "Application/src/main/res/layout-land/fragment_camera2_basic.xml" \
  "Application/tests/AndroidManifest.xml" \
  "Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java" \
  "scripts/test-makefile-root.sh" \
  "Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java"; do
  require_file "$path"
done

require_sha256 "$XXXHDPI_LAUNCHER" \
  "bc7526f26217f5a41e01253cf46b90964ec5b02f2e442bacff06acd8c3050505" \
  "The reviewed xxxhdpi launcher icon bytes changed."
require_sha256 "$XXXHDPI_INFO" \
  "e82ce6692ea558584be4f6c52a8ab3677f8f77da6dc9597ccbd67f6f3750baf8" \
  "The reviewed xxxhdpi info icon bytes changed."

if ! file "$XXXHDPI_LAUNCHER" | grep -Fq "192 x 192" || \
   ! file "$XXXHDPI_INFO" | grep -Fq "128 x 128"; then
  printf '%s\n' "CameraApp xxxhdpi icons must retain their exact launcher and action dimensions." >&2
  exit 1
fi

if ! grep -Fq "Android lint must produce zero-finding debug and release XML reports." "$ROOT_DIR/Makefile" || \
   ! grep -Fq "grep -Eq '<issue([[:space:]>])'" "$ROOT_DIR/Makefile" || \
   ! grep -Fq ":Application:assembleDebugAndroidTest" "$ROOT_DIR/Makefile" || \
   ! grep -Fq 'override SKIP_ANDROID_INSTRUMENTATION := 0' "$ROOT_DIR/Makefile" || \
   ! grep -Fq "GRADLE='\$(REPOSITORY_GRADLE_LITERAL)' /bin/sh '\$(REPOSITORY_ROOT_LITERAL)/scripts/run-instrumentation.sh'" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Make lint must reject every Android lint finding without suppression." >&2
  exit 1
fi

for lint_contract in \
  ':Application:lintDebug --no-daemon' \
  ':Application:lintRelease --no-daemon'; do
  if ! grep -Fq "$lint_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Make lint must keep sequential variant contract: $lint_contract" >&2
    exit 1
  fi
done
if grep -Fq ':Application:lintDebug :Application:lintRelease' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Debug and release lint must not share one racy Gradle invocation." >&2
  exit 1
fi

if [ ! -x "$INSTRUMENTATION_RUNNER" ] || ! sh -n "$INSTRUMENTATION_RUNNER"; then
  printf '%s\n' "Instrumentation runner must exist and pass POSIX shell syntax checks." >&2
  exit 1
fi

if [ ! -x "$TRUSTED_GATE_RUNNER" ] || ! sh -n "$TRUSTED_GATE_RUNNER" || \
   [ ! -x "$TRUSTED_GATE_VERIFIER" ] || ! /usr/bin/python3 -m py_compile "$TRUSTED_GATE_VERIFIER" || \
   [ ! -x "$TRUSTED_ENV_VERIFIER" ] || ! /usr/bin/python3 -m py_compile "$TRUSTED_ENV_VERIFIER"; then
  printf '%s\n' "Trusted CameraApp verifier launchers must be executable and parseable." >&2
  exit 1
fi

if [ ! -d "$TRUSTED_GATE_EXPECTED_ROOT" ] || \
   [ "$(find "$TRUSTED_GATE_EXPECTED_ROOT" -type f | wc -l | tr -d ' ')" -ne 9 ]; then
  printf '%s\n' "Trusted ready-capture policy must retain all nine reviewed semantic templates." >&2
  exit 1
fi

if [ "$(grep -Fc 'mState = STATE_PICTURE_TAKEN;' "$TRUSTED_GATE_EXPECTED_ROOT/Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java")" -lt 3 ] || \
   ! grep -Fq 'Immediately-ready AF/AE results must publish picture-taken state before each still capture.' "$TRUSTED_GATE_EXPECTED_ROOT/scripts/check-baseline.sh"; then
  printf '%s\n' "Trusted ready-capture templates must retain terminal-state source and checker bytes." >&2
  exit 1
fi

for runner_contract in \
  'SYSTEM_IMAGE=${ANDROID_SYSTEM_IMAGE:-system-images;android-36;google_apis;x86_64}' \
  'trap cleanup 0' \
  "trap 'exit 129' 1" \
  "trap 'exit 130' 2" \
  "trap 'exit 143' 15" \
  '"$AVDMANAGER" create avd' \
  '-no-window' \
  '-no-snapshot' \
  'get-state' \
  'sys.boot_completed' \
  'HELPER_TIMEOUT_SECONDS=${ANDROID_EMULATOR_HELPER_TIMEOUT_SECONDS:-1}' \
  'SETUP_HELPER_TIMEOUT_SECONDS=${ANDROID_EMULATOR_SETUP_HELPER_TIMEOUT_SECONDS:-5}' \
  'find_standard_tool sleep /bin/sleep /usr/bin/sleep' \
  'CGROUP_ROOT=${ANDROID_EMULATOR_CGROUP_ROOT:-/sys/fs/cgroup}' \
  'cgroup.kill' \
  'run_bounded_command' \
  'finish_async_bounded_helper' \
  'run_cgroup_admin_with_timeout' \
  'prepare_emulator_containment' \
  'attach_emulator_to_containment "$emulator_pid"' \
  'mkfifo "$launcher_fifo"' \
  'signal_containment_term' \
  'kill_containment_unit' \
  'wait_for_containment_empty' \
  'remove_containment_unit' \
  'pid_is_live "$emulator_pid"' \
  'Emulator containment cleanup failed.' \
  'exit "$cleanup_status"' \
  ':Application:connectedDebugAndroidTest --no-daemon'; do
  if ! grep -Fq -- "$runner_contract" "$INSTRUMENTATION_RUNNER"; then
    printf '%s\n' "Instrumentation runner contract is missing: $runner_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc 'BOOT_TIMEOUT_SECONDS=${ANDROID_BOOT_TIMEOUT_SECONDS:-180}' "$INSTRUMENTATION_RUNNER")" -ne 1 ]; then
  printf '%s\n' "Instrumentation runner must keep a testable three-minute default boot deadline." >&2
  exit 1
fi

if [ "$(grep -Fc 'SHUTDOWN_TIMEOUT_SECONDS=${ANDROID_EMULATOR_SHUTDOWN_TIMEOUT_SECONDS:-10}' "$INSTRUMENTATION_RUNNER")" -ne 1 ]; then
  printf '%s\n' "Instrumentation runner must keep a testable ten-second default shutdown deadline." >&2
  exit 1
fi

if [ "$(grep -Fc 'HELPER_TIMEOUT_SECONDS=${ANDROID_EMULATOR_HELPER_TIMEOUT_SECONDS:-1}' "$INSTRUMENTATION_RUNNER")" -ne 1 ]; then
  printf '%s\n' "Instrumentation runner must keep a bounded one-second cleanup helper default." >&2
  exit 1
fi

if grep -Fq 'wait-for-device' "$INSTRUMENTATION_RUNNER"; then
  printf '%s\n' "Instrumentation runner must not block outside the bounded boot loop." >&2
  exit 1
fi

if ! sh -n "$INSTRUMENTATION_CLEANUP_TEST"; then
  printf '%s\n' "Instrumentation cleanup regression test must pass POSIX shell syntax checks." >&2
  exit 1
fi

for cleanup_test_contract in \
  'fake-emulator.c' \
  'setsid()' \
  'double-fork-setsid' \
  'resistant-tree' \
  'fork-race' \
  'fork-storm' \
  'unrelated-decoy' \
  'malformed-cgroup-pids' \
  'missing-containment' \
  'hung-adb-kill' \
  'failing-adb-kill' \
  'missing-adb' \
  'helper-term-resistance' \
  'simultaneous-signals' \
  'cgroup-kill-failure' \
  'cgroup-removal-failure' \
  'nested-cgroup-name' \
  'concurrent-cgroups' \
  'wall-time-bound' \
  'ANDROID_EMULATOR_HELPER_TIMEOUT_SECONDS' \
  'CLEANUP_TEST_CASES'; do
  if ! grep -Fq "$cleanup_test_contract" "$INSTRUMENTATION_CLEANUP_TEST"; then
    printf '%s\n' "Instrumentation cleanup regression test is missing contract: $cleanup_test_contract" >&2
    exit 1
  fi
done

sh "$INSTRUMENTATION_CLEANUP_TEST"

for xxxhdpi_doc in "$ROOT_DIR/AGENTS.md" "$README" "$ROOT_DIR/CHANGES.md" "$ROOT_DIR/VISION.md"; do
  if ! tr '\n' ' ' < "$xxxhdpi_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "complete xxxhdpi icon family"; then
    printf '%s\n' "$xxxhdpi_doc must document the complete xxxhdpi icon family." >&2
    exit 1
  fi
done

for xxxhdpi_plan_contract in \
  "Status: Completed" \
  "Verification: Completed" \
  "make check" \
  "focused hostile mutations" \
  "zero Android lint findings"; do
  if ! grep -Fq "$xxxhdpi_plan_contract" "$XXXHDPI_ICON_PLAN"; then
    printf '%s\n' "Xxxhdpi icon plan must record completed verification: $xxxhdpi_plan_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc 'android:layout_gravity="center_vertical|end"' "$PORTRAIT_LAYOUT")" -ne 1 ] || \
   grep -Fq 'android:layout_gravity="center_vertical|right"' "$PORTRAIT_LAYOUT"; then
  printf '%s\n' "Portrait camera controls must use logical end-side gravity." >&2
  exit 1
fi

landscape_texture_block=$(sed -n '/<com.example.android.camera2basic.AutoFitTextureView/,/\/>/p' "$LANDSCAPE_LAYOUT")
landscape_controls_block=$(sed -n '/<FrameLayout/,/android:orientation="horizontal">/p' "$LANDSCAPE_LAYOUT")

for texture_contract in \
  'android:layout_width="match_parent"' \
  'android:layout_height="match_parent"' \
  'android:layout_alignParentStart="true"' \
  'android:layout_toStartOf="@+id/controls"'; do
  if ! printf '%s\n' "$landscape_texture_block" | grep -Fq "$texture_contract"; then
    printf '%s\n' "Landscape camera preview must reserve space before the control rail: $texture_contract" >&2
    exit 1
  fi
done

for controls_contract in \
  'android:id="@id/controls"' \
  'android:layout_width="wrap_content"' \
  'android:layout_height="match_parent"' \
  'android:layout_alignParentEnd="true"'; do
  if ! printf '%s\n' "$landscape_controls_block" | grep -Fq "$controls_contract"; then
    printf '%s\n' "Landscape control rail must keep independent end-side bounds: $controls_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '@+id/controls' "$LANDSCAPE_LAYOUT")" -ne 1 ] || \
   [ "$(grep -Fc 'android:id="@id/controls"' "$LANDSCAPE_LAYOUT")" -ne 1 ] || \
   grep -Fq 'android:layout_below="@id/texture"' "$LANDSCAPE_LAYOUT" || \
   grep -Fq 'android:layout_toEndOf="@id/texture"' "$LANDSCAPE_LAYOUT" || \
   grep -Fq 'android:layout_toRightOf="@id/texture"' "$LANDSCAPE_LAYOUT"; then
  printf '%s\n' "Landscape camera preview and controls must not retain overlapping or physical-direction constraints." >&2
  exit 1
fi

if [ "$(grep -Fc 'android:supportsRtl="true"' "$MANIFEST")" -ne 1 ]; then
  printf '%s\n' "Application manifest must explicitly enable RTL resource mirroring." >&2
  exit 1
fi

if ! grep -Fq "reserves a separate end-side control rail in landscape" "$README" || \
   ! grep -Fq "non-overlapping landscape preview and control regions" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "Removed the landscape preview/control overlap warning" "$ROOT_DIR/CHANGES.md" || \
   ! grep -Fq "2026-06-13-cameraapp-landscape-overlap.md" "$README"; then
  printf '%s\n' "Landscape preview separation documentation and plan link must remain checked in." >&2
  exit 1
fi

for overlap_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make check" \
  "10 issues" \
  "isolated hostile mutations were rejected" \
  "no emulator, physical-device camera, or rendered" \
  "screenshot coverage is claimed"; do
  if ! grep -Fq "$overlap_plan_contract" "$LANDSCAPE_OVERLAP_PLAN"; then
    printf '%s\n' "Landscape preview separation plan must record completed verification: $overlap_plan_contract" >&2
    exit 1
  fi
done

for pruned_resource in \
  "Application/src/main/res/layout/activity_main.xml" \
  "Application/src/main/res/values/template-dimens.xml" \
  "Application/src/main/res/values-sw600dp/template-dimens.xml" \
  "Application/src/main/res/values-sw600dp/template-styles.xml" \
  "Application/src/main/res/values/template-styles.xml" \
  "Application/src/main/res/values-v11/template-styles.xml" \
  "Application/src/main/res/values-v21/base-template-styles.xml" \
  "Application/src/main/res/drawable-hdpi/tile.9.png"; do
  if [ -e "$ROOT_DIR/$pruned_resource" ]; then
    printf '%s\n' "Inactive sample-template resource must remain pruned: $pruned_resource" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '<style name="MaterialTheme" parent="android:Theme.Material.Light.NoActionBar.Fullscreen">' "$ACTIVE_STYLES")" -ne 1 ] || \
  [ "$(grep -Fc '<item name="android:windowBackground">@android:color/black</item>' "$ACTIVE_STYLES")" -ne 1 ] || \
  [ "$(grep -Fc 'tools:ignore="MergeRootFrame"' "$ACTIVITY_LAYOUT")" -ne 1 ] || \
  [ "$(grep -Fc '.replace(R.id.container, Camera2BasicFragment.newInstance())' "$ROOT_DIR/Application/src/main/java/com/example/android/camera2basic/CameraActivity.java")" -ne 1 ] || \
  grep -Fq 'android:background=' "$ACTIVITY_LAYOUT" || \
  [ "$(grep -Fc 'android:theme="@style/MaterialTheme"' "$MANIFEST")" -ne 1 ]; then
  printf '%s\n' "CameraApp must keep one black window background and its required fragment container contract." >&2
  exit 1
fi

if grep -REn 'Widget\.SampleMessage|@drawable/tile|margin_(tiny|small|large)|horizontal_page_margin|vertical_page_margin' \
  "$ROOT_DIR/Application/src/main/res" >/dev/null 2>&1; then
  printf '%s\n' "Template-only widget, tile, and dimension references must remain pruned." >&2
  exit 1
fi

if ! grep -Fq "Unreachable Android sample-template resources are not packaged" "$README" || \
  ! grep -Fq "unreachable template resource surface" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "Pruned the unreachable sample-template layout" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq "R5. Android lint must report exactly two findings" "$INACTIVE_TEMPLATE_PLAN"; then
  printf '%s\n' "Inactive template resource documentation and plan contracts must remain checked in." >&2
  exit 1
fi

for inactive_template_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make verify" \
  "2 issues for both debug and release" \
  "isolated hostile source mutations were rejected" \
  "No emulator, physical-device camera, or rendered screenshot coverage"; do
  if ! grep -Fq "$inactive_template_plan_contract" "$INACTIVE_TEMPLATE_PLAN"; then
    printf '%s\n' "Inactive template resource plan must record completed verification: $inactive_template_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "single black window background" "$README" || \
  ! grep -Fq "single-owner camera window background" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "Moved the black camera launch surface" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq "R3. Android lint must report only the existing" "$WINDOW_BACKGROUND_PLAN"; then
  printf '%s\n' "Window-background ownership documentation and plan contracts must remain checked in." >&2
  exit 1
fi

for window_background_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make verify" \
  "exactly 1 issue for both debug and release" \
  "isolated hostile mutations were rejected" \
  "No emulator, physical-device camera, or rendered screenshot coverage"; do
  if ! grep -Fq "$window_background_plan_contract" "$WINDOW_BACKGROUND_PLAN"; then
    printf '%s\n' "Window-background plan must record completed verification: $window_background_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "logical end-side anchors" "$README" || \
   ! grep -Fq "right-to-left camera control placement" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "RTL lint findings" "$ROOT_DIR/CHANGES.md" || \
   ! grep -Fq "R5. The static baseline must reject restoration" "$RTL_LAYOUT_PLAN"; then
  printf '%s\n' "RTL layout documentation and plan contracts must remain checked in." >&2
  exit 1
fi

for ignored in \
  ".gradle/" \
  ".idea/" \
  "*.iml" \
  "local.properties" \
  "*/build/"; do
  if ! grep -Fq "$ignored" "$GITIGNORE"; then
    printf '%s\n' ".gitignore must ignore $ignored" >&2
    exit 1
  fi
done

for tracked in \
  "local.properties" \
  ".gradle" \
  ".idea" \
  "Application/Application.iml" \
  "Application/build"; do
  if git -C "$ROOT_DIR" ls-files "$tracked" | grep -q .; then
    printf '%s\n' "Generated or machine-local path must not be tracked: $tracked" >&2
    exit 1
  fi
done

if [ ! -x "$ROOT_DIR/gradlew" ]; then
  printf '%s\n' "gradlew must be executable for reproducible CLI builds." >&2
  exit 1
fi

if [ ! -x "$GRADLEW" ] || [ "$(cat "$WRAPPER_PROPERTIES")" != "$(expected_wrapper_properties)" ]; then
  printf '%s\n' "Generated wrapper must retain the reviewed Gradle 9.6.1 URL and checksum." >&2
  exit 1
fi

require_sha256 "$GRADLEW" "a5a5c199ba02189ae8c46a334223371a20599d9c298ef65e7540ede4a3f72d59" "Unix wrapper must match the reviewed generated script."
require_sha256 "$GRADLEW_BAT" "59328c7a17f673b1a63040bfb380a0c749e5d6df3406f7f18641060314cd9aa1" "Windows wrapper must match the reviewed generated script."
require_sha256 "$WRAPPER_JAR" "497c8c2a7e5031f6aa847f88104aa80a93532ec32ee17bdb8d1d2f67a194a9c7" "Wrapper JAR must match the reviewed generated artifact."
require_sha256 "$WRAPPER_PROPERTIES" "89f62533208a72b7a8cc2892b6b3540c445fa6175508297d932dae57d653591a" "Wrapper properties must match the reviewed checksum contract."

for contract in \
  "id 'com.android.application' version '9.2.0' apply false"; do
  if ! grep -Fq "$contract" "$ROOT_BUILD"; then
    printf '%s\n' "Root build must preserve Android Gradle Plugin contract: $contract" >&2
    exit 1
  fi
done

for repository_contract in "google()" "mavenCentral()" "gradlePluginPortal()"; do
  if ! grep -Fq "$repository_contract" "$SETTINGS"; then
    printf '%s\n' "Settings must preserve supported repository contract: $repository_contract" >&2
    exit 1
  fi
done

if grep -Eq 'jcenter\(\)|repo1\.maven\.org|dl\.google\.com/dl/android/maven2' \
    "$ROOT_BUILD" "$SETTINGS" "$APP_BUILD"; then
  printf '%s\n' "Build configuration must not restore legacy repository declarations." >&2
  exit 1
fi

for build_contract in \
  "namespace = 'com.example.android.camera2basic'" \
  "testNamespace = 'com.example.android.camera2basic.tests'" \
  "enableKotlin = false" \
  "compileSdk = 36" \
  "buildToolsVersion = '36.1.0'" \
  "applicationId = 'com.example.android.camera2basic'" \
  "minSdk = 21" \
  "targetSdk = 36" \
  "testInstrumentationRunner = 'androidx.test.runner.AndroidJUnitRunner'" \
  "sourceCompatibility = JavaVersion.VERSION_17" \
  "targetCompatibility = JavaVersion.VERSION_17" \
  "warningsAsErrors = true" \
  "disable += ['GradleDependency', 'OldTargetApi']" \
  "androidTestImplementation 'androidx.test:core:1.7.0'" \
  "androidTestImplementation 'androidx.test.ext:junit:1.3.0'" \
  "androidTestImplementation 'androidx.test:runner:1.7.0'" \
  "androidTestImplementation 'androidx.test.uiautomator:uiautomator:2.3.0'"; do
  if ! grep -Fq "$build_contract" "$APP_BUILD"; then
    printf '%s\n' "Application build must preserve modern contract: $build_contract" >&2
    exit 1
  fi
done

if grep -Eq '(^|[[:space:]])(compile|implementation|api)[[:space:]]+['"'"']' "$APP_BUILD" || \
   grep -Eq 'com\.android\.support|androidx\.(appcompat|fragment|cardview)' "$APP_BUILD"; then
  printf '%s\n' "Application runtime dependency graph must remain empty." >&2
  exit 1
fi

if ! grep -Fq 'android.useAndroidX=true' "$GRADLE_PROPERTIES"; then
  printf '%s\n' "AndroidX must be enabled for the instrumentation-only test graph." >&2
  exit 1
fi

if ! grep -Fq "android.permission.CAMERA" "$MANIFEST"; then
  printf '%s\n' "Camera permission must remain declared." >&2
  exit 1
fi

for manifest_contract in \
  'android:name="android.hardware.camera.any"' \
  'android:required="true"' \
  'android:exported="true"' \
  'android:dataExtractionRules="@xml/data_extraction_rules"' \
  'android:fullBackupContent="@xml/backup_rules"'; do
  if ! grep -Fq "$manifest_contract" "$MANIFEST"; then
    printf '%s\n' "Manifest must preserve Android 16 contract: $manifest_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'android:allowBackup="false"' "$MANIFEST"; then
  printf '%s\n' "CameraApp backup must stay disabled for captured camera state." >&2
  exit 1
fi

if grep -Fq 'package=' "$MANIFEST"; then
  printf '%s\n' "Application package identity must be owned by the Gradle namespace DSL." >&2
  exit 1
fi

if ! grep -Fq '<manifest />' "$TEST_MANIFEST" || \
   grep -Eq '<instrumentation|package=' "$TEST_MANIFEST"; then
  printf '%s\n' "Instrumentation manifest must remain namespace-owned without legacy runner metadata." >&2
  exit 1
fi

if grep -Eq 'android\.test|ActivityInstrumentationTestCase2' "$TEST_FIXTURE"; then
  printf '%s\n' "Instrumentation fixture must not restore removed platform test APIs." >&2
  exit 1
fi

for test_contract in \
  '@RunWith(AndroidJUnit4.class)' \
  'activitySurvivesCameraPermissionDenial()' \
  'assertEquals(PERMISSION_DENIED,' \
  '.checkSelfPermission(Manifest.permission.CAMERA)' \
  'ActivityScenario.launch(CameraActivity.class)' \
  'Until.findObject(By.res(DENY_BUTTON_RESOURCE))' \
  'PERMISSION_DIALOG_TIMEOUT_MS = 10_000' \
  'PERMISSION_DENY_CLICK_DURATION_MS = 100' \
  'PERMISSION_DENY_RETRY_WAIT_MS = 1_000' \
  'waitForPermissionRequestPending(scenario, true)' \
  'dismissPermissionDialog(device)' \
  'denyButton.click(PERMISSION_DENY_CLICK_DURATION_MS)' \
  'catch (StaleObjectException ignored)' \
  'Camera permission denial action did not dismiss the dialog' \
  'waitForPermissionDenied(scenario)' \
  'assertFalse("Camera permission request is still pending"' \
  'Until.gone(By.res(DENY_BUTTON_RESOURCE))' \
  'scenario.recreate()' \
  'assertTrue("Camera permission denial was not retained after recreation"' \
  'assertFalse("Camera permission request restarted after recreation"' \
  'assertNull("Camera permission dialog was shown after activity recreation"' \
  'getDeclaredField(' \
  'cameraPermissionDenied(scenario)' \
  'fragmentBooleanField(scenario, "mCameraPermissionDenied")' \
  'getFragmentManager().findFragmentById(R.id.container)' \
  'assertNotNull("Camera fragment is null", fragment)'; do
  if ! grep -Fq "$test_contract" "$TEST_FIXTURE"; then
    printf '%s\n' "Instrumentation fixture must preserve current smoke contract: $test_contract" >&2
    exit 1
  fi
done

denial_helper_line=$(grep -nF 'dismissPermissionDialog(device);' "$TEST_FIXTURE" | head -1 | cut -d: -f1)
denial_callback_line=$(grep -nF 'waitForPermissionDenied(scenario);' "$TEST_FIXTURE" | cut -d: -f1)
if [ -z "$denial_helper_line" ] || [ -z "$denial_callback_line" ] || \
   [ "$denial_helper_line" -ge "$denial_callback_line" ]; then
  printf '%s\n' "Instrumentation fixture must dismiss the permission dialog before polling the denial callback." >&2
  exit 1
fi

DENIAL_HELPER=$(sed -n \
  '/private static void dismissPermissionDialog(UiDevice device)/,/private static void waitForPermissionRequestPending/p' \
  "$TEST_FIXTURE")
for denial_retry_contract in \
  'do {' \
  'UiObject2 denyButton = device.wait(' \
  'Until.findObject(By.res(DENY_BUTTON_RESOURCE))' \
  'PERMISSION_DENY_RETRY_WAIT_MS);' \
  'if (denyButton == null)' \
  'denyButton.click(PERMISSION_DENY_CLICK_DURATION_MS);' \
  'catch (StaleObjectException ignored)' \
  'device.wait(Until.gone(By.res(DENY_BUTTON_RESOURCE))' \
  '} while (SystemClock.elapsedRealtime() < deadline);'; do
  if ! printf '%s\n' "$DENIAL_HELPER" | grep -Fq "$denial_retry_contract"; then
    printf '%s\n' "Instrumentation fixture must preserve bounded denial retry contract: $denial_retry_contract" >&2
    exit 1
  fi
done

denial_find_line=$(printf '%s\n' "$DENIAL_HELPER" | grep -nF 'UiObject2 denyButton = device.wait(' | cut -d: -f1)
denial_click_line=$(printf '%s\n' "$DENIAL_HELPER" | grep -nF 'denyButton.click(PERMISSION_DENY_CLICK_DURATION_MS);' | cut -d: -f1)
denial_gone_line=$(printf '%s\n' "$DENIAL_HELPER" | grep -nF 'device.wait(Until.gone(By.res(DENY_BUTTON_RESOURCE))' | cut -d: -f1)
denial_loop_line=$(printf '%s\n' "$DENIAL_HELPER" | grep -nF '} while (SystemClock.elapsedRealtime() < deadline);' | cut -d: -f1)
if [ -z "$denial_find_line" ] || [ -z "$denial_click_line" ] || \
   [ -z "$denial_gone_line" ] || [ -z "$denial_loop_line" ] || \
   [ "$denial_find_line" -ge "$denial_click_line" ] || \
   [ "$denial_click_line" -ge "$denial_gone_line" ] || \
   [ "$denial_gone_line" -ge "$denial_loop_line" ]; then
  printf '%s\n' "Instrumentation fixture must retry a fresh bounded permission-denial gesture until dismissal." >&2
  exit 1
fi

if [ "$(grep -Fc 'assertCameraFragmentExists(scenario);' "$TEST_FIXTURE")" -ne 3 ]; then
  printf '%s\n' "Instrumentation fixture must verify the camera fragment before denial, after denial, and after recreation." >&2
  exit 1
fi

TEST_FIXTURE_FLAT=$(tr '\n' ' ' < "$TEST_FIXTURE" | tr -s '[:space:]' ' ')
for recreation_test_contract in \
  'assertTrue("Camera permission denial was not retained after recreation", cameraPermissionDenied(scenario));' \
  'assertFalse("Camera permission request restarted after recreation", permissionRequestPending(scenario));' \
  'assertNull("Camera permission dialog was shown after activity recreation", device.wait(Until.findObject(By.res(DENY_BUTTON_RESOURCE)), PERMISSION_DIALOG_TIMEOUT_MS));'; do
  if ! printf '%s\n' "$TEST_FIXTURE_FLAT" | grep -Fq "$recreation_test_contract"; then
    printf '%s\n' "Instrumentation fixture must preserve post-recreation assertion: $recreation_test_contract" >&2
    exit 1
  fi
done

recreate_line=$(grep -nF 'scenario.recreate();' "$TEST_FIXTURE" | cut -d: -f1)
recreated_fragment_line=$(grep -nF 'assertCameraFragmentExists(scenario);' "$TEST_FIXTURE" | tail -1 | cut -d: -f1)
retained_denial_line=$(grep -nF 'assertTrue("Camera permission denial was not retained after recreation"' "$TEST_FIXTURE" | cut -d: -f1)
restarted_request_line=$(grep -nF 'assertFalse("Camera permission request restarted after recreation"' "$TEST_FIXTURE" | cut -d: -f1)
recreated_dialog_line=$(grep -nF 'assertNull("Camera permission dialog was shown after activity recreation"' "$TEST_FIXTURE" | cut -d: -f1)
if [ -z "$recreate_line" ] || [ -z "$recreated_fragment_line" ] || \
   [ -z "$retained_denial_line" ] || [ -z "$restarted_request_line" ] || \
   [ -z "$recreated_dialog_line" ] || \
   [ "$recreate_line" -ge "$recreated_fragment_line" ] || \
   [ "$recreated_fragment_line" -ge "$retained_denial_line" ] || \
   [ "$retained_denial_line" -ge "$restarted_request_line" ] || \
   [ "$restarted_request_line" -ge "$recreated_dialog_line" ]; then
  printf '%s\n' "Instrumentation fixture must verify retained denial state after activity recreation in order." >&2
  exit 1
fi

ensure_line=$(grep -n 'if (!ensureCameraPermission(activity))' "$FRAGMENT" | head -n 1 | cut -d: -f1)
setup_line=$(grep -n 'setUpCameraOutputs(width, height);' "$FRAGMENT" | head -n 1 | cut -d: -f1)
lock_line=$(grep -n 'mCameraOpenCloseLock.tryAcquire' "$FRAGMENT" | head -n 1 | cut -d: -f1)
recheck_line=$(grep -n 'activity.checkSelfPermission(Manifest.permission.CAMERA)' "$FRAGMENT" | head -n 1 | cut -d: -f1)
if [ -z "$ensure_line" ] || [ -z "$setup_line" ] || [ -z "$recheck_line" ] || [ -z "$lock_line" ] || \
   [ "$ensure_line" -ge "$setup_line" ] || [ "$recheck_line" -ge "$lock_line" ]; then
  printf '%s\n' "Camera permission must be checked before output setup and lock acquisition." >&2
  exit 1
fi

for permission_contract in \
  'mCameraPermissionRequestPending' \
  'mCameraPermissionDenied' \
  'requestPermissions(new String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA_PERMISSION)' \
  'public void onRequestPermissionsResult' \
  'mCameraPermissionRequestPending = false' \
  'if (mCameraPermissionDenied)' \
  'mCameraPermissionDenied = true' \
  'public void onDestroyView()' \
  'mTextureView = null' \
  'isResumed() && mTextureView != null && mTextureView.isAvailable()' \
  'R.string.camera_permission_denied'; do
  if ! grep -Fq "$permission_contract" "$FRAGMENT"; then
    printf '%s\n' "Camera permission flow must preserve contract: $permission_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Foc 'android:id="@+id/controls"' "$PORTRAIT_LAYOUT")" -ne 1 ] || \
   ! grep -Fq 'setOnApplyWindowInsetsListener' "$FRAGMENT" || \
   ! grep -Fq 'getSystemWindowInsetBottom()' "$FRAGMENT"; then
  printf '%s\n' "Camera controls must preserve target-36 system-inset protection." >&2
  exit 1
fi

for backup_file in "$BACKUP_RULES" "$DATA_EXTRACTION_RULES"; do
  if ! grep -Fq '<exclude domain="root" path="." />' "$backup_file"; then
    printf '%s\n' "Backup and device-transfer rules must exclude app camera state." >&2
    exit 1
  fi
done

for workflow_contract in \
  'actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654' \
  'java-version: "17"' \
  'run: |' \
  "/usr/bin/python3 -I -S -B -m unittest discover -s trusted-verifier/tests -p 'test_*.py' -v" \
  '"platforms;android-36"' \
  '"build-tools;36.1.0"' \
  '"system-images;android-36;google_apis;x86_64"' \
  'sudo chmod 666 /dev/kvm' \
  'timeout 22m /usr/bin/make check'; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "CI must preserve Android 16 toolchain contract: $workflow_contract" >&2
    exit 1
  fi
done

if grep -Fq 'android-actions/setup-android@' "$CI_WORKFLOW"; then
  printf '%s\n' "CI must not use actions outside this repository's allowed Actions policy." >&2
  exit 1
fi

if grep -Fq 'SKIP_ANDROID_INSTRUMENTATION' "$CI_WORKFLOW"; then
  printf '%s\n' "CI must execute instrumentation without the local runtime skip." >&2
  exit 1
fi

if ! grep -Fq "backgroundHandler == null || mFile == null" "$FRAGMENT"; then
  printf '%s\n' "ImageReader callback must guard missing handler/file state." >&2
  exit 1
fi

if ! grep -Fq "Image image = null;" "$FRAGMENT" ||
  ! grep -Fq "catch (IllegalStateException e)" "$FRAGMENT"; then
  printf '%s\n' "ImageReader callback must guard acquireNextImage backpressure failures." >&2
  exit 1
fi

if ! grep -Fq "Dropping image because ImageReader is full." "$FRAGMENT"; then
  printf '%s\n' "ImageReader backpressure guard must document dropped frames without logging image data." >&2
  exit 1
fi

if ! grep -Fq "activity == null ? null : activity.getExternalFilesDir(null)" "$FRAGMENT"; then
  printf '%s\n' "Output file setup must guard detached activity state." >&2
  exit 1
fi

if ! grep -Fq "jpegSizes == null || jpegSizes.length == 0" "$FRAGMENT"; then
  printf '%s\n' "Camera setup must guard missing JPEG output sizes." >&2
  exit 1
fi

if ! grep -Fq "mCameraId == null || mImageReader == null || mPreviewSize == null" "$FRAGMENT"; then
  printf '%s\n' "openCamera must guard unavailable camera setup." >&2
  exit 1
fi

if ! grep -Fq "boolean cameraLockAcquired = false;" "$FRAGMENT"; then
  printf '%s\n' "openCamera must track whether the caller still owns the camera semaphore." >&2
  exit 1
fi

if ! grep -Fq "cameraLockAcquired = mCameraOpenCloseLock.tryAcquire" "$FRAGMENT"; then
  printf '%s\n' "openCamera must record successful camera semaphore acquisition." >&2
  exit 1
fi

if ! grep -Fq "import java.util.concurrent.atomic.AtomicBoolean;" "$FRAGMENT" || \
   ! grep -Fq "private final AtomicBoolean mCameraOpenCallbackOwnsLock" "$FRAGMENT"; then
  printf '%s\n' "Camera open callbacks must track one atomic semaphore-release owner." >&2
  exit 1
fi

device_state_callback=$(awk '
  /private final CameraDevice.StateCallback mStateCallback/ { capture = 1 }
  capture && /An additional thread for running tasks/ { exit }
  capture { print }
' "$FRAGMENT")
opened_callback=$(awk '
  /public void onOpened\(CameraDevice cameraDevice\)/ { capture = 1 }
  capture { print }
  capture && /^        }$/ { exit }
' "$FRAGMENT")
opened_callback_compact=$(printf '%s\n' "$opened_callback" | tr '\n' ' ' | tr -s '[:space:]' ' ')
if ! printf '%s\n' "$opened_callback_compact" | grep -Fq \
    'mCameraDevice = cameraDevice; try { createCameraPreviewSession(); } finally { releaseCameraOpenLockFromCallback(); }' || \
   [ "$(printf '%s\n' "$opened_callback" | grep -Fc 'mCameraDevice = cameraDevice;')" -ne 1 ] || \
   [ "$(printf '%s\n' "$opened_callback" | grep -Fc 'createCameraPreviewSession();')" -ne 1 ] || \
   [ "$(printf '%s\n' "$opened_callback" | grep -Fc 'releaseCameraOpenLockFromCallback();')" -ne 1 ]; then
  printf '%s\n' "Opened camera publication and preview submission must precede callback lock release." >&2
  exit 1
fi
if [ "$(printf '%s\n' "$device_state_callback" | grep -Fc "releaseCameraOpenLockFromCallback();")" -ne 3 ] || \
   printf '%s\n' "$device_state_callback" | grep -Fq "mCameraOpenCloseLock.release();"; then
  printf '%s\n' "Opened, disconnected, and error callbacks must share the single-release helper." >&2
  exit 1
fi

open_callback_release=$(awk '
  /private void releaseCameraOpenLockFromCallback\(\)/ { capture = 1 }
  capture { print }
  capture && /^    }$/ { exit }
' "$FRAGMENT")
for callback_release_marker in \
  "mCameraOpenCallbackOwnsLock.compareAndSet(true, false)" \
  "mCameraOpenCloseLock.release();"; do
  if [ "$(printf '%s\n' "$open_callback_release" | grep -Fc "$callback_release_marker")" -ne 1 ]; then
    printf '%s\n' "Camera callback lock release must atomically consume ownership: $callback_release_marker" >&2
    exit 1
  fi
done

if ! grep -Fq "Status: Completed" "$CAMERA_OPEN_CALLBACK_PUBLICATION_PLAN" || \
   ! grep -Fq "Publish the callback-owned device before beginning preview setup" "$CAMERA_OPEN_CALLBACK_PUBLICATION_PLAN" || \
   ! grep -Fq "Release callback ownership from a \`finally\` block" "$CAMERA_OPEN_CALLBACK_PUBLICATION_PLAN" || \
   ! grep -Fq "pause-during-open runtime" "$CAMERA_OPEN_CALLBACK_PUBLICATION_PLAN" || \
   ! grep -Fq "Three isolated mutations were rejected" "$CAMERA_OPEN_CALLBACK_PUBLICATION_PLAN" || \
   ! grep -Fq "The opened callback must publish its device" "$ROOT_DIR/AGENTS.md" || \
   ! grep -Fq "The opened callback publishes its device" "$README" || \
   ! grep -Fq "opened camera device and synchronous preview-session submission" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "Keep opened-device publication and preview submission ahead" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "Pause during camera open" "$ROOT_DIR/DEVICE_VERIFICATION.md" || \
   ! grep -Fq 'Prevented `onPause` from acquiring the camera lifecycle semaphore' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Opened camera publication guidance and plan must remain checked in." >&2
  exit 1
fi

if ! grep -B1 -F "manager.openCamera(mCameraId, mStateCallback, mBackgroundHandler);" "$FRAGMENT" | \
     grep -Fq "mCameraOpenCallbackOwnsLock.set(true);" || \
   ! grep -A3 -F "if (cameraLockAcquired)" "$FRAGMENT" | \
     grep -Fq "mCameraOpenCallbackOwnsLock.set(false);"; then
  printf '%s\n' "Camera open must transfer callback ownership and revoke it before synchronous release." >&2
  exit 1
fi

if ! grep -Fq "manager.openCamera(mCameraId, mStateCallback, mBackgroundHandler);" "$FRAGMENT" || \
   ! grep -Fq "cameraLockAcquired = false;" "$FRAGMENT"; then
  printf '%s\n' "openCamera must transfer semaphore release ownership after asynchronous open starts." >&2
  exit 1
fi

if [ "$(grep -Fc "cameraLockAcquired = false;" "$FRAGMENT")" -ne 2 ]; then
  printf '%s\n' "openCamera must initialize and then transfer camera semaphore ownership exactly once." >&2
  exit 1
fi

if ! grep -Fq "if (cameraLockAcquired)" "$FRAGMENT" || \
   ! grep -A3 -F "if (cameraLockAcquired)" "$FRAGMENT" | grep -Fq "mCameraOpenCloseLock.release();"; then
  printf '%s\n' "openCamera must release the camera semaphore after synchronous failures." >&2
  exit 1
fi

if ! grep -Fq "boolean closeLockAcquired = false;" "$FRAGMENT" || \
   ! grep -Fq "closeLockAcquired = true;" "$FRAGMENT"; then
  printf '%s\n' "closeCamera must track successful camera semaphore acquisition." >&2
  exit 1
fi

if ! grep -Fq "if (closeLockAcquired)" "$FRAGMENT" || \
   ! grep -A3 -F "if (closeLockAcquired)" "$FRAGMENT" | grep -Fq "mCameraOpenCloseLock.release();"; then
  printf '%s\n' "closeCamera must release the semaphore only while it owns the permit." >&2
  exit 1
fi

if ! grep -Fq "Thread.currentThread().interrupt();" "$FRAGMENT"; then
  printf '%s\n' "closeCamera must restore interrupt status after interrupted lock acquisition." >&2
  exit 1
fi

if grep -Fq "private Handler mMessageHandler = new Handler()" "$FRAGMENT" || \
   ! grep -Fq "private static class MessageHandler extends Handler" "$FRAGMENT" || \
   ! grep -Fq "WeakReference<Camera2BasicFragment>" "$FRAGMENT" || \
   ! grep -Fq "super(Looper.getMainLooper());" "$FRAGMENT" || \
   ! grep -Fq "Camera2BasicFragment fragment = mFragmentReference.get();" "$FRAGMENT" || \
   ! grep -Fq "private final Handler mMessageHandler = new MessageHandler(this);" "$FRAGMENT"; then
  printf '%s\n' "Toast delivery must use a static main-looper handler with a weak fragment reference." >&2
  exit 1
fi

if ! grep -Fq "mBackgroundThread == null" "$FRAGMENT"; then
  printf '%s\n' "Background thread shutdown must be null-safe." >&2
  exit 1
fi

if ! grep -Fq "if (mBackgroundThread != null)" "$FRAGMENT"; then
  printf '%s\n' "Background thread startup must avoid duplicate handler threads." >&2
  exit 1
fi

stop_background_body=$(awk '
  /private void stopBackgroundThread\(\)/ { capture = 1 }
  capture && /private void createCameraPreviewSession\(\)/ { exit }
  capture { print }
' "$FRAGMENT")
for stop_background_contract in \
  "mBackgroundThread.quitSafely();" \
  "mBackgroundThread.join();" \
  "mBackgroundThread = null;" \
  "mBackgroundHandler = null;" \
  "catch (InterruptedException e)" \
  "Thread.currentThread().interrupt();"; do
  if ! printf '%s\n' "$stop_background_body" | grep -Fq "$stop_background_contract"; then
    printf '%s\n' "Camera background shutdown must preserve: $stop_background_contract" >&2
    exit 1
  fi
done
if printf '%s\n' "$stop_background_body" | grep -Eq 'printStackTrace\(|Log\.[ew]\([^;]*, *e\)'; then
  printf '%s\n' "Interrupted camera background shutdown must not emit throwable details." >&2
  exit 1
fi
if ! printf '%s\n' "$stop_background_body" | awk '
  /mBackgroundThread\.quitSafely\(\);/ { quit = NR }
  /mBackgroundThread\.join\(\);/ { joined = NR }
  /mBackgroundThread = null;/ && joined && !released_thread { released_thread = NR }
  /mBackgroundHandler = null;/ && joined && !released_handler { released_handler = NR }
  /catch \(InterruptedException e\)/ { caught = NR }
  /Thread\.currentThread\(\)\.interrupt\(\);/ { interrupted = NR }
  END {
    exit !(quit && joined && released_thread && released_handler && caught && interrupted &&
      quit < joined && joined < released_thread && joined < released_handler && caught < interrupted)
  }
'; then
  printf '%s\n' "Camera background shutdown must release ownership only after join and restore interruption in the catch." >&2
  exit 1
fi

background_interrupt_guidance='Interrupted camera-worker shutdown preserves the interrupt signal and unresolved worker ownership.'
for background_interrupt_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$background_interrupt_guidance" "$ROOT_DIR/$background_interrupt_doc"; then
    printf '%s\n' "$background_interrupt_doc must document interrupted worker shutdown ownership." >&2
    exit 1
  fi
done

for background_interrupt_plan_contract in \
  "status: completed" \
  "repository-root and external-directory make check passed" \
  "hostile mutations" \
  "No emulator or physical-camera lifecycle execution was performed"; do
  if ! grep -Fqi "$background_interrupt_plan_contract" "$BACKGROUND_INTERRUPT_PLAN"; then
    printf '%s\n' "Camera background interrupt plan must record completion evidence: $background_interrupt_plan_contract" >&2
    exit 1
  fi
done

if grep -Fq 'printStackTrace()' "$FRAGMENT"; then
  printf '%s\n' "Camera runtime paths must not print exception stack traces." >&2
  exit 1
fi

if [ "$(grep -Fc 'catch (CameraAccessException e)' "$FRAGMENT")" -ne 3 ] || \
   [ "$(grep -Fc 'catch (CameraAccessException | IllegalStateException e)' "$FRAGMENT")" -ne 4 ] || \
   [ "$(grep -Fc 'catch (CameraAccessException | IllegalStateException |' "$FRAGMENT")" -ne 1 ]; then
  printf '%s\n' "Camera error redaction must preserve three access-only, four closed-session, and one preview-start recovery boundary." >&2
  exit 1
fi

fragment_compact=$(tr '\n' ' ' < "$FRAGMENT" | tr -s '[:space:]' ' ')
if printf '%s\n' "$fragment_compact" | grep -Eq 'Log\.[vdiew]\([^;]*,[^;]*,[^;]*\)'; then
  printf '%s\n' "Camera runtime diagnostics must not serialize caught throwable details." >&2
  exit 1
fi

for camera_error_category in \
  'Log.w(TAG, "Dropping image because ImageReader is full.");' \
  'Log.e(TAG, "Unable to configure camera outputs.");' \
  'Log.e(TAG, "Unable to open camera.");' \
  'Log.e(TAG, "Unable to start camera preview.");' \
  'Log.e(TAG, "Unable to create camera preview session.");' \
  'Log.e(TAG, "Unable to lock camera focus.");' \
  'Log.e(TAG, "Unable to run camera precapture sequence.");' \
  'Log.e(TAG, "Unable to capture picture.");' \
  'Log.e(TAG, "Unable to resume camera preview.");'; do
  if [ "$(grep -Fc "$camera_error_category" "$FRAGMENT")" -ne 1 ]; then
    printf '%s\n' "Camera diagnostics must preserve one fixed category: $camera_error_category" >&2
    exit 1
  fi
done

camera_error_guidance='Camera runtime diagnostics retain fixed operation categories without exception stack traces or throwable details.'
for camera_error_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$camera_error_guidance" "$ROOT_DIR/$camera_error_doc"; then
    printf '%s\n' "$camera_error_doc must document camera error log redaction." >&2
    exit 1
  fi
done

for camera_error_plan_contract in \
  'status: completed' \
  'repository-root and external-directory `make check` passed' \
  'hostile mutations' \
  'No emulator, physical-camera, or live logcat verification was performed'; do
  if ! grep -Fqi "$camera_error_plan_contract" "$CAMERA_ERROR_LOG_PLAN"; then
    printf '%s\n' "Camera error log plan must record completion evidence: $camera_error_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "mCameraDevice == null || mCaptureSession == null" "$FRAGMENT"; then
  printf '%s\n' "takePicture must guard unavailable camera session state." >&2
  exit 1
fi

if ! grep -Fq "if (mTextureView == null)" "$FRAGMENT"; then
  printf '%s\n' "onResume must guard retained fragments before the texture view is recreated." >&2
  exit 1
fi

if ! grep -Fq "View pictureButton = view.findViewById(R.id.picture)" "$FRAGMENT" ||
  ! grep -Fq "if (pictureButton != null)" "$FRAGMENT"; then
  printf '%s\n' "onViewCreated must guard missing picture controls before listener binding." >&2
  exit 1
fi

if ! grep -Fq "View infoButton = view.findViewById(R.id.info)" "$FRAGMENT" ||
  ! grep -Fq "if (infoButton != null)" "$FRAGMENT"; then
  printf '%s\n' "onViewCreated must guard missing info controls before listener binding." >&2
  exit 1
fi

if ! grep -Fq "Integer afState = result.get(CaptureResult.CONTROL_AF_STATE)" "$FRAGMENT"; then
  printf '%s\n' "Autofocus callback state must not be unboxed when Camera2 reports null." >&2
  exit 1
fi

if ! grep -Fq "afState == null" "$FRAGMENT"; then
  printf '%s\n' "Autofocus callback state must guard null values." >&2
  exit 1
fi

if ! grep -Fq "mTextureView == null || cameraDevice == null" "$FRAGMENT" ||
  ! grep -Fq "if (texture == null)" "$FRAGMENT"; then
  printf '%s\n' "Preview session creation must guard missing texture and camera state." >&2
  exit 1
fi

preview_session_method=$(awk '
  /private void createCameraPreviewSession\(\)/ { capture = 1 }
  capture && /private void configureTransform\(/ { exit }
  capture { print }
' "$FRAGMENT")
configured_callback=$(printf '%s\n' "$preview_session_method" | awk '
  /public void onConfigured\(CameraCaptureSession cameraCaptureSession\)/ { capture = 1 }
  capture && /public void onConfigureFailed\(CameraCaptureSession cameraCaptureSession\)/ { exit }
  capture { print }
')
configure_failed_callback=$(printf '%s\n' "$preview_session_method" | awk '
  /public void onConfigureFailed\(CameraCaptureSession cameraCaptureSession\)/ { capture = 1 }
  capture && /^[[:space:]]*}, null$/ { exit }
  capture { print }
')

preview_start_recovery=$(printf '%s\n' "$configured_callback" | awk '
  /catch \(CameraAccessException \| IllegalStateException \|/ { capture = 1 }
  capture { print }
')
if [ "$(printf '%s\n' "$preview_start_recovery" | grep -Fc "IllegalArgumentException e)")" -ne 1 ]; then
  printf '%s\n' "Preview-start recovery must include invalid repeating-request failures." >&2
  exit 1
fi
for recovery_marker in \
  "if (mCaptureSession == cameraCaptureSession)" \
  "mCaptureSession = null;" \
  "mPreviewRequestBuilder = null;" \
  "mPreviewRequest = null;" \
  "cameraCaptureSession.close();"; do
  if [ "$(printf '%s\n' "$preview_start_recovery" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Preview-start failure recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
preview_recovery_guard_line=$(printf '%s\n' "$preview_start_recovery" | grep -nF "if (mCaptureSession == cameraCaptureSession)" | cut -d: -f1)
preview_session_clear_line=$(printf '%s\n' "$preview_start_recovery" | grep -nF "mCaptureSession = null;" | cut -d: -f1)
preview_builder_clear_line=$(printf '%s\n' "$preview_start_recovery" | grep -nF "mPreviewRequestBuilder = null;" | cut -d: -f1)
preview_request_clear_line=$(printf '%s\n' "$preview_start_recovery" | grep -nF "mPreviewRequest = null;" | cut -d: -f1)
preview_session_close_line=$(printf '%s\n' "$preview_start_recovery" | grep -nF "cameraCaptureSession.close();" | cut -d: -f1)
if [ "$preview_recovery_guard_line" -ge "$preview_session_clear_line" ] || \
  [ "$preview_session_clear_line" -ge "$preview_builder_clear_line" ] || \
  [ "$preview_builder_clear_line" -ge "$preview_request_clear_line" ] || \
  [ "$preview_request_clear_line" -ge "$preview_session_close_line" ]; then
  printf '%s\n' "Preview-start failure must clear owned preview state before closing the failed session." >&2
  exit 1
fi

if [ "$(grep -Fc "private volatile CameraDevice mCameraDevice;" "$FRAGMENT")" -ne 1 ]; then
  printf '%s\n' "Camera device ownership must remain visible across lifecycle and callback threads." >&2
  exit 1
fi

if [ "$(grep -Fc "private volatile CameraCaptureSession mCaptureSession;" "$FRAGMENT")" -ne 1 ]; then
  printf '%s\n' "Capture session ownership must remain visible across lifecycle and callback threads." >&2
  exit 1
fi

capture_result_callback=$(awk '
  /private CameraCaptureSession.CaptureCallback mCaptureCallback/ { capture = 1 }
  capture && /private static class MessageHandler/ { exit }
  capture { print }
' "$FRAGMENT")
capture_progressed_callback=$(printf '%s\n' "$capture_result_callback" | awk '
  /public void onCaptureProgressed\(CameraCaptureSession session/ { capture = 1 }
  capture && /public void onCaptureCompleted\(CameraCaptureSession session/ { exit }
  capture { print }
')
capture_completed_callback=$(printf '%s\n' "$capture_result_callback" | awk '
  /public void onCaptureCompleted\(CameraCaptureSession session/ { capture = 1 }
  capture { print }
')

for callback_name in progressed completed; do
  if [ "$callback_name" = progressed ]; then
    callback_body=$capture_progressed_callback
    process_marker="process(partialResult);"
  else
    callback_body=$capture_completed_callback
    process_marker="process(result);"
  fi
  for callback_marker in \
    "if (session != mCaptureSession)" \
    "return;" \
    "$process_marker"; do
    if [ "$(printf '%s\n' "$callback_body" | grep -Fc "$callback_marker")" -ne 1 ]; then
      printf '%s\n' "Capture $callback_name ownership marker must be unique: $callback_marker" >&2
      exit 1
    fi
  done

  callback_guard_line=$(printf '%s\n' "$callback_body" | grep -nF "if (session != mCaptureSession)" | cut -d: -f1)
  callback_return_line=$(printf '%s\n' "$callback_body" | grep -nF "return;" | cut -d: -f1)
  callback_process_line=$(printf '%s\n' "$callback_body" | grep -nF "$process_marker" | cut -d: -f1)
  if [ "$callback_guard_line" -ge "$callback_return_line" ] || \
    [ "$callback_return_line" -ge "$callback_process_line" ]; then
    printf '%s\n' "Capture $callback_name callbacks must reject stale session ownership before processing results." >&2
    exit 1
  fi
done

still_capture_method=$(awk '
  /private void captureStillPicture\(\)/ { capture = 1 }
  capture && /private void unlockFocus\(\)/ { exit }
  capture { print }
' "$FRAGMENT")

lock_focus_method=$(awk '
  /private void lockFocus\(\)/ { capture = 1 }
  capture && /private void runPrecaptureSequence\(\)/ { exit }
  capture { print }
' "$FRAGMENT")
lock_focus_dependency_guard=$(printf '%s\n' "$lock_focus_method" | awk '
  /if \(mPreviewRequestBuilder == null \|\| mCaptureSession == null\)/ { capture = 1 }
  capture && /try \{/ { exit }
  capture { print }
')
for recovery_marker in \
  "if (mPreviewRequestBuilder == null || mCaptureSession == null)" \
  "mState = STATE_PREVIEW;" \
  'showToast("Camera unavailable");' \
  "return;"; do
  if [ "$(printf '%s\n' "$lock_focus_dependency_guard" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Missing focus dependency recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
lock_focus_dependency_state_line=$(printf '%s\n' "$lock_focus_dependency_guard" | grep -nF "mState = STATE_PREVIEW;" | cut -d: -f1)
lock_focus_dependency_return_line=$(printf '%s\n' "$lock_focus_dependency_guard" | grep -nF "return;" | cut -d: -f1)
if [ "$lock_focus_dependency_state_line" -ge "$lock_focus_dependency_return_line" ]; then
  printf '%s\n' "Missing focus dependencies must restore preview state before returning." >&2
  exit 1
fi

lock_focus_recovery=$(printf '%s\n' "$lock_focus_method" | awk '
  /catch \(CameraAccessException \| IllegalStateException e\)/ { capture = 1 }
  capture { print }
')
for recovery_marker in \
  "catch (CameraAccessException | IllegalStateException e)" \
  "unlockFocus();" \
  'Log.e(TAG, "Unable to lock camera focus.");'; do
  if [ "$(printf '%s\n' "$lock_focus_recovery" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Focus-lock failure recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
lock_focus_state_line=$(printf '%s\n' "$lock_focus_recovery" | grep -nF "unlockFocus();" | cut -d: -f1)
lock_focus_log_line=$(printf '%s\n' "$lock_focus_recovery" | grep -nF 'Log.e(TAG, "Unable to lock camera focus.");' | cut -d: -f1)
if [ "$lock_focus_state_line" -ge "$lock_focus_log_line" ]; then
  printf '%s\n' "Synchronous focus-lock failures must restore preview state before reporting the failure." >&2
  exit 1
fi

precapture_method=$(awk '
  /private void runPrecaptureSequence\(\)/ { capture = 1 }
  capture && /private void captureStillPicture\(\)/ { exit }
  capture { print }
' "$FRAGMENT")
precapture_dependency_guard=$(printf '%s\n' "$precapture_method" | awk '
  /if \(mPreviewRequestBuilder == null \|\| mCaptureSession == null\)/ { capture = 1 }
  capture && /try \{/ { exit }
  capture { print }
')
for recovery_marker in \
  "if (mPreviewRequestBuilder == null || mCaptureSession == null)" \
  "mState = STATE_PREVIEW;" \
  'showToast("Camera unavailable");' \
  "return;"; do
  if [ "$(printf '%s\n' "$precapture_dependency_guard" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Missing precapture dependency recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
precapture_dependency_state_line=$(printf '%s\n' "$precapture_dependency_guard" | grep -nF "mState = STATE_PREVIEW;" | cut -d: -f1)
precapture_dependency_return_line=$(printf '%s\n' "$precapture_dependency_guard" | grep -nF "return;" | cut -d: -f1)
if [ "$precapture_dependency_state_line" -ge "$precapture_dependency_return_line" ]; then
  printf '%s\n' "Missing precapture dependencies must restore preview state before returning." >&2
  exit 1
fi

precapture_failure_recovery=$(printf '%s\n' "$precapture_method" | awk '
  /catch \(CameraAccessException \| IllegalStateException e\)/ { capture = 1 }
  capture { print }
')
for recovery_marker in \
  "catch (CameraAccessException | IllegalStateException e)" \
  "unlockFocus();" \
  'Log.e(TAG, "Unable to run camera precapture sequence.");'; do
  if [ "$(printf '%s\n' "$precapture_failure_recovery" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Precapture failure recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
precapture_failure_state_line=$(printf '%s\n' "$precapture_failure_recovery" | grep -nF "unlockFocus();" | cut -d: -f1)
precapture_failure_log_line=$(printf '%s\n' "$precapture_failure_recovery" | grep -nF 'Log.e(TAG, "Unable to run camera precapture sequence.");' | cut -d: -f1)
if [ "$precapture_failure_state_line" -ge "$precapture_failure_log_line" ]; then
  printf '%s\n' "Synchronous precapture failures must restore preview state before reporting the failure." >&2
  exit 1
fi

focus_state_guidance='Missing, failed, or closed-session focus and precapture operations restore preview state instead of leaving the capture state machine waiting.'
for focus_state_doc in AGENTS.md README.md SECURITY.md; do
  if ! grep -Fq "$focus_state_guidance" "$ROOT_DIR/$focus_state_doc"; then
    printf '%s\n' "$focus_state_doc must document focus and precapture state recovery." >&2
    exit 1
  fi
done
focus_request_guidance='Submitted focus or precapture failures clear AF/AE triggers and restart repeating preview when dependencies remain available.'
for focus_request_doc in AGENTS.md README.md SECURITY.md; do
  if ! grep -Fq "$focus_request_guidance" "$ROOT_DIR/$focus_request_doc"; then
    printf '%s\n' "$focus_request_doc must document submitted focus and precapture request recovery." >&2
    exit 1
  fi
done
if ! grep -Fq 'Keep missing, failed, or closed-session focus and precapture operations from leaving the capture state machine waiting.' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'Keep submitted focus and precapture failures from retaining stale AF/AE triggers or abandoning repeating preview.' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'Camera2 focus and precapture startup failures now restore preview state' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Vision and changelog must document focus and precapture state recovery." >&2
  exit 1
fi

missing_capture_dependency_guard=$(printf '%s\n' "$still_capture_method" | awk '
  /if \(null == activity \|\| null == mCameraDevice \|\|/ { capture = 1 }
  capture && /\/\/ This is the CaptureRequest.Builder/ { exit }
  capture { print }
')
for recovery_marker in \
  "if (null == activity || null == mCameraDevice ||" \
  "mImageReader == null || mCaptureSession == null)" \
  "mState = STATE_PREVIEW;" \
  "return;"; do
  if [ "$(printf '%s\n' "$missing_capture_dependency_guard" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Missing capture dependency recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
missing_dependency_guard_line=$(printf '%s\n' "$missing_capture_dependency_guard" | grep -nF "if (null == activity || null == mCameraDevice ||" | cut -d: -f1)
missing_dependency_state_line=$(printf '%s\n' "$missing_capture_dependency_guard" | grep -nF "mState = STATE_PREVIEW;" | cut -d: -f1)
missing_dependency_return_line=$(printf '%s\n' "$missing_capture_dependency_guard" | grep -nF "return;" | cut -d: -f1)
if [ "$missing_dependency_guard_line" -ge "$missing_dependency_state_line" ] || \
  [ "$missing_dependency_state_line" -ge "$missing_dependency_return_line" ]; then
  printf '%s\n' "Missing still-capture dependencies must restore preview state before returning." >&2
  exit 1
fi
still_capture_completed=$(printf '%s\n' "$still_capture_method" | awk '
  /public void onCaptureCompleted\(CameraCaptureSession session/ { capture = 1 }
  capture && /public void onCaptureFailed\(CameraCaptureSession session/ { exit }
  capture { print }
')
for callback_marker in \
  "if (session != mCaptureSession)" \
  "return;" \
  "unlockFocus();"; do
  if [ "$(printf '%s\n' "$still_capture_completed" | grep -Fc "$callback_marker")" -ne 1 ]; then
    printf '%s\n' "Still-capture completion ownership marker must be unique: $callback_marker" >&2
    exit 1
  fi
done
still_guard_line=$(printf '%s\n' "$still_capture_completed" | grep -nF "if (session != mCaptureSession)" | cut -d: -f1)
still_return_line=$(printf '%s\n' "$still_capture_completed" | grep -nF "return;" | cut -d: -f1)
still_unlock_line=$(printf '%s\n' "$still_capture_completed" | grep -nF "unlockFocus();" | cut -d: -f1)
if [ "$still_guard_line" -ge "$still_return_line" ] || \
  [ "$still_return_line" -ge "$still_unlock_line" ]; then
  printf '%s\n' "Still-capture completion must reject stale session ownership before unlocking focus." >&2
  exit 1
fi

still_capture_failed=$(printf '%s\n' "$still_capture_method" | awk '
  /public void onCaptureFailed\(CameraCaptureSession session/ { capture = 1 }
  capture && /^[[:space:]]*};$/ { exit }
  capture { print }
')
for callback_marker in \
  "CaptureFailure failure" \
  "if (session != mCaptureSession)" \
  "return;" \
  "unlockFocus();"; do
  if [ "$(printf '%s\n' "$still_capture_failed" | grep -Fc "$callback_marker")" -ne 1 ]; then
    printf '%s\n' "Still-capture failure recovery marker must be unique: $callback_marker" >&2
    exit 1
  fi
done
failure_guard_line=$(printf '%s\n' "$still_capture_failed" | grep -nF "if (session != mCaptureSession)" | cut -d: -f1)
failure_return_line=$(printf '%s\n' "$still_capture_failed" | grep -nF "return;" | cut -d: -f1)
failure_unlock_line=$(printf '%s\n' "$still_capture_failed" | grep -nF "unlockFocus();" | cut -d: -f1)
if [ "$failure_guard_line" -ge "$failure_return_line" ] || \
  [ "$failure_return_line" -ge "$failure_unlock_line" ]; then
  printf '%s\n' "Still-capture failure must reject stale session ownership before unlocking focus." >&2
  exit 1
fi

capture_exception=$(printf '%s\n' "$still_capture_method" | awk '
  /catch \(CameraAccessException \| IllegalStateException e\)/ { capture = 1 }
  capture && /^[[:space:]]*}$/ { exit }
  capture { print }
')
for recovery_marker in \
  "catch (CameraAccessException | IllegalStateException e)" \
  "unlockFocus();" \
  'Log.e(TAG, "Unable to capture picture.");'; do
  if [ "$(printf '%s\n' "$capture_exception" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Synchronous still-capture recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done

capture_exception_unlock_line=$(printf '%s\n' "$capture_exception" | grep -nF "unlockFocus();" | cut -d: -f1)
capture_exception_log_line=$(printf '%s\n' "$capture_exception" | grep -nF 'Log.e(TAG, "Unable to capture picture.");' | cut -d: -f1)
if [ "$capture_exception_unlock_line" -ge "$capture_exception_log_line" ]; then
  printf '%s\n' "Synchronous still-capture failures must recover focus before returning." >&2
  exit 1
fi

unlock_focus_method=$(awk '
  /private void unlockFocus\(\)/ { capture = 1 }
  capture && /@Override/ { exit }
  capture { print }
' "$FRAGMENT")
if [ "$(printf '%s\n' "$unlock_focus_method" | grep -Fc 'catch (CameraAccessException | IllegalStateException e)')" -ne 1 ]; then
  printf '%s\n' "Focus recovery must absorb closed-session failures after publishing preview state." >&2
  exit 1
fi
for recovery_marker in \
  "mState = STATE_PREVIEW;" \
  "if (mPreviewRequestBuilder == null || mCaptureSession == null || mPreviewRequest == null)" \
  "CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE" \
  "mCaptureSession.capture(mPreviewRequestBuilder.build(), mCaptureCallback," \
  "try {"; do
  if [ "$(printf '%s\n' "$unlock_focus_method" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Focus recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
preview_state_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "mState = STATE_PREVIEW;" | cut -d: -f1)
preview_guard_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "if (mPreviewRequestBuilder == null || mCaptureSession == null || mPreviewRequest == null)" | cut -d: -f1)
preview_try_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "try {" | cut -d: -f1)
precapture_idle_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE" | cut -d: -f1)
preview_capture_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "mCaptureSession.capture(mPreviewRequestBuilder.build(), mCaptureCallback," | cut -d: -f1)
if [ "$preview_state_line" -ge "$preview_guard_line" ] || \
   [ "$preview_state_line" -ge "$preview_try_line" ]; then
  printf '%s\n' "Focus recovery must publish preview state before nullable or throwing Camera2 work." >&2
  exit 1
fi
if [ "$precapture_idle_line" -ge "$preview_capture_line" ]; then
  printf '%s\n' "Focus recovery must clear the precapture trigger before submitting its recovery request." >&2
  exit 1
fi

capture_callback_guidance="Capture-result and still-capture completion callbacks reject stale session ownership before mutating capture state or unlocking focus."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$capture_callback_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Capture callback ownership guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

capture_failure_guidance="Current-session still-capture failures unlock focus and resume preview; stale session failures are ignored."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$capture_failure_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Capture failure recovery guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

synchronous_capture_guidance="Synchronous still-capture and preview-restart failures restore preview state before Camera2 recovery work can throw."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$synchronous_capture_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Synchronous capture recovery guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

missing_capture_dependency_guidance="Missing still-capture dependencies restore preview state before the capture path returns."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$missing_capture_dependency_guidance" "$ROOT_DIR/$guidance_file"; then
    printf '%s\n' "Missing capture dependency recovery guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done

closed_session_capture_guidance="Closed-session still-capture and preview-restart operations use the same recovery path instead of escaping with \`IllegalStateException\`."
for guidance_file in AGENTS.md README.md SECURITY.md VISION.md; do
  if ! tr '\n' ' ' < "$ROOT_DIR/$guidance_file" | tr -s '[:space:]' ' ' | \
      grep -Fq "$closed_session_capture_guidance"; then
    printf '%s\n' "Closed-session capture recovery guidance must remain checked in: $guidance_file" >&2
    exit 1
  fi
done
if ! grep -Fq 'Closed-session still-capture and preview-restart operations now recover' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must document closed-session capture recovery." >&2
  exit 1
fi

for closed_session_capture_plan_contract in \
  "Status: Completed" \
  "make check" \
  "isolated closed-session mutations were rejected" \
  "No emulator, physical camera, or live closed-session race"; do
  if ! grep -Fq "$closed_session_capture_plan_contract" "$CLOSED_SESSION_CAPTURE_RECOVERY_PLAN"; then
    printf '%s\n' "Closed-session capture recovery plan must record completed verification: $closed_session_capture_plan_contract" >&2
    exit 1
  fi
done

for capture_failure_plan_contract in \
  "Status: Completed" \
  "make check" \
  "isolated failure-recovery mutations were rejected" \
  "No emulator, physical camera, or live capture failure"; do
  if ! grep -Fq "$capture_failure_plan_contract" "$CAPTURE_FAILURE_RECOVERY_PLAN"; then
    printf '%s\n' "Capture failure recovery plan must record completed verification: $capture_failure_plan_contract" >&2
    exit 1
  fi
done

for synchronous_capture_plan_contract in \
  "Status: Completed" \
  "make check" \
  "isolated synchronous-recovery mutations were rejected" \
  "No emulator, physical camera, or live synchronous Camera2 failure"; do
  if ! grep -Fq "$synchronous_capture_plan_contract" "$SYNCHRONOUS_CAPTURE_RECOVERY_PLAN"; then
    printf '%s\n' "Synchronous capture recovery plan must record completed verification: $synchronous_capture_plan_contract" >&2
    exit 1
  fi
done

for missing_capture_dependency_plan_contract in \
  "Status: Completed" \
  "make check" \
  "isolated nullable-recovery mutations were rejected" \
  "No emulator, physical camera, or live missing-dependency race"; do
  if ! grep -Fq "$missing_capture_dependency_plan_contract" "$MISSING_CAPTURE_DEPENDENCY_PLAN"; then
    printf '%s\n' "Missing capture dependency plan must record completed verification: $missing_capture_dependency_plan_contract" >&2
    exit 1
  fi
done

for capture_callback_plan_contract in \
  "Status: Completed" \
  "make check" \
  "isolated ownership mutations were rejected" \
  "No emulator, physical camera, or live stale callback"; do
  if ! grep -Fq "$capture_callback_plan_contract" "$CAPTURE_CALLBACK_OWNERSHIP_PLAN"; then
    printf '%s\n' "Capture callback ownership plan must record completed verification: $capture_callback_plan_contract" >&2
    exit 1
  fi
done

device_state_callback=$(awk '
  /private final CameraDevice.StateCallback mStateCallback/ { capture = 1 }
  capture && /An additional thread for running tasks/ { exit }
  capture { print }
' "$FRAGMENT")
disconnected_callback=$(printf '%s\n' "$device_state_callback" | awk '
  /public void onDisconnected\(CameraDevice cameraDevice\)/ { capture = 1 }
  capture && /public void onError\(CameraDevice cameraDevice, int error\)/ { exit }
  capture { print }
')
device_error_callback=$(printf '%s\n' "$device_state_callback" | awk '
  /public void onError\(CameraDevice cameraDevice, int error\)/ { capture = 1 }
  capture { print }
')

for callback_name in disconnected error; do
  if [ "$callback_name" = disconnected ]; then
    callback_body=$disconnected_callback
  else
    callback_body=$device_error_callback
  fi
  for callback_marker in \
    "cameraDevice.close();" \
    "if (mCameraDevice != cameraDevice)" \
    "return;" \
    "mCameraDevice = null;"; do
    if [ "$(printf '%s\n' "$callback_body" | grep -Fc "$callback_marker")" -ne 1 ]; then
      printf '%s\n' "Camera $callback_name callback ownership marker must be unique: $callback_marker" >&2
      exit 1
    fi
  done

  callback_close_line=$(printf '%s\n' "$callback_body" | grep -nF "cameraDevice.close();" | cut -d: -f1)
  callback_guard_line=$(printf '%s\n' "$callback_body" | grep -nF "if (mCameraDevice != cameraDevice)" | cut -d: -f1)
  callback_return_line=$(printf '%s\n' "$callback_body" | grep -nF "return;" | cut -d: -f1)
  callback_clear_line=$(printf '%s\n' "$callback_body" | grep -nF "mCameraDevice = null;" | cut -d: -f1)
  if [ "$callback_close_line" -ge "$callback_guard_line" ] || \
    [ "$callback_guard_line" -ge "$callback_return_line" ] || \
    [ "$callback_return_line" -ge "$callback_clear_line" ]; then
    printf '%s\n' "Camera $callback_name callbacks must close their device and reject stale ownership before clearing shared state." >&2
    exit 1
  fi
done

error_clear_line=$(printf '%s\n' "$device_error_callback" | grep -nF "mCameraDevice = null;" | cut -d: -f1)
error_finish_line=$(printf '%s\n' "$device_error_callback" | grep -nF "activity.finish();" | cut -d: -f1)
if [ -z "$error_finish_line" ] || [ "$error_clear_line" -ge "$error_finish_line" ]; then
  printf '%s\n' "Camera errors must finish the activity only after current-device ownership is established." >&2
  exit 1
fi

if ! grep -Fq "Device disconnect and error callbacks close their callback-owned device before rejecting stale shared ownership." "$ROOT_DIR/AGENTS.md" || \
  ! grep -Fq "Camera-device disconnect and error callbacks close their callback device, but only the current device may clear shared state or finish the activity." "$README" || \
  ! grep -Fq "Stale camera-device callbacks cannot clear replacement state or finish its activity." "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Keep camera-device disconnect and error callbacks bound to the device that initiated them" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "Bound camera-device disconnect and error side effects to current-device ownership." "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Camera device callback ownership guidance must remain checked in." >&2
  exit 1
fi

for device_callback_plan_contract in \
  "Status: Completed" \
  "make check" \
  "ownership mutations were rejected" \
  "No emulator, physical camera, or live disconnect/error callback"; do
  if ! grep -Fq "$device_callback_plan_contract" "$DEVICE_CALLBACK_OWNERSHIP_PLAN"; then
    printf '%s\n' "Camera device callback ownership plan must record completed verification: $device_callback_plan_contract" >&2
    exit 1
  fi
done

for preview_marker in \
  "final CameraDevice cameraDevice = mCameraDevice;" \
  "final CaptureRequest.Builder previewRequestBuilder" \
  "cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);" \
  "previewRequestBuilder.addTarget(surface);" \
  "cameraDevice.createCaptureSession(Arrays.asList(surface, mImageReader.getSurface()),"; do
  if [ "$(printf '%s\n' "$preview_session_method" | grep -Fc "$preview_marker")" -ne 1 ]; then
    printf '%s\n' "Preview session ownership marker must be unique: $preview_marker" >&2
    exit 1
  fi
done

for configured_marker in \
  "if (mCameraDevice != cameraDevice)" \
  "return;" \
  "mPreviewRequestBuilder = previewRequestBuilder;" \
  "mCaptureSession = cameraCaptureSession;" \
  "mPreviewRequest = previewRequestBuilder.build();" \
  "cameraCaptureSession.setRepeatingRequest(mPreviewRequest,"; do
  if [ "$(printf '%s\n' "$configured_callback" | grep -Fc "$configured_marker")" -ne 1 ]; then
    printf '%s\n' "Configured preview ownership marker must be unique: $configured_marker" >&2
    exit 1
  fi
done
if [ "$(printf '%s\n' "$configured_callback" | grep -Fc "cameraCaptureSession.close();")" -ne 2 ]; then
  printf '%s\n' "Configured preview callbacks must close stale and failed sessions exactly once each." >&2
  exit 1
fi

stale_guard_line=$(printf '%s\n' "$configured_callback" | grep -nF "if (mCameraDevice != cameraDevice)" | cut -d: -f1)
stale_close_line=$(printf '%s\n' "$configured_callback" | grep -nF "cameraCaptureSession.close();" | head -n 1 | cut -d: -f1)
stale_return_line=$(printf '%s\n' "$configured_callback" | grep -nF "return;" | cut -d: -f1)
builder_publish_line=$(printf '%s\n' "$configured_callback" | grep -nF "mPreviewRequestBuilder = previewRequestBuilder;" | cut -d: -f1)
session_publish_line=$(printf '%s\n' "$configured_callback" | grep -nF "mCaptureSession = cameraCaptureSession;" | cut -d: -f1)
request_build_line=$(printf '%s\n' "$configured_callback" | grep -nF "mPreviewRequest = previewRequestBuilder.build();" | cut -d: -f1)
repeat_line=$(printf '%s\n' "$configured_callback" | grep -nF "cameraCaptureSession.setRepeatingRequest(mPreviewRequest," | cut -d: -f1)
if [ "$stale_guard_line" -ge "$stale_close_line" ] || \
  [ "$stale_close_line" -ge "$stale_return_line" ] || \
  [ "$stale_return_line" -ge "$builder_publish_line" ] || \
  [ "$builder_publish_line" -ge "$session_publish_line" ] || \
  [ "$session_publish_line" -ge "$request_build_line" ] || \
  [ "$request_build_line" -ge "$repeat_line" ]; then
  printf '%s\n' "Stale preview sessions must close and return before current preview state is published." >&2
  exit 1
fi

for failure_marker in \
  "if (mCameraDevice != cameraDevice)" \
  "return;" \
  'showToast("Failed");'; do
  if [ "$(printf '%s\n' "$configure_failed_callback" | grep -Fc "$failure_marker")" -ne 1 ]; then
    printf '%s\n' "Failed preview ownership marker must be unique: $failure_marker" >&2
    exit 1
  fi
done

if printf '%s\n' "$configure_failed_callback" | grep -Fq "cameraCaptureSession.close();"; then
  printf '%s\n' "Camera2 already closes failed preview sessions; failure callbacks must not invoke session methods." >&2
  exit 1
fi

failure_guard_line=$(printf '%s\n' "$configure_failed_callback" | grep -nF "if (mCameraDevice != cameraDevice)" | cut -d: -f1)
failure_return_line=$(printf '%s\n' "$configure_failed_callback" | grep -nF "return;" | cut -d: -f1)
failure_toast_line=$(printf '%s\n' "$configure_failed_callback" | grep -nF 'showToast("Failed");' | cut -d: -f1)
if [ "$failure_guard_line" -ge "$failure_return_line" ] || \
  [ "$failure_return_line" -ge "$failure_toast_line" ]; then
  printf '%s\n' "Failed preview callbacks must reject stale camera ownership before reporting UI." >&2
  exit 1
fi

if ! grep -Fq "exact initiating camera device before publishing preview state" "$README" || \
  ! grep -Fq "Keep asynchronous preview callbacks bound to their initiating camera device" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "Stale camera-session callbacks close before publishing preview state" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Bound configured preview sessions to their exact initiating camera device" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Preview session ownership guidance must remain checked in." >&2
  exit 1
fi

if ! grep -Fq "Failed preview callbacks rely on Camera2 session closure and suppress stale UI" "$README" || \
  ! grep -Fq "Report preview configuration failures only for the initiating camera lifetime" "$ROOT_DIR/VISION.md" || \
  ! grep -Fq "Failed preview callbacks suppress stale failure UI without invoking the already-closed session" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Suppressed stale camera-lifetime preview failure UI without invoking failed sessions" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Preview configuration failure ownership guidance must remain checked in." >&2
  exit 1
fi

for preview_plan_contract in \
  "status: completed" \
  "make check" \
  "hostile ownership mutations were rejected" \
  "No emulator, physical camera, or live preview"; do
  if ! grep -Fq "$preview_plan_contract" "$PREVIEW_SESSION_OWNERSHIP_PLAN"; then
    printf '%s\n' "Preview session ownership plan must record completed verification: $preview_plan_contract" >&2
    exit 1
  fi
done

for preview_failure_plan_contract in \
  "status: completed" \
  "make check" \
  "hostile failure-ownership mutations were rejected" \
  "No emulator, physical camera, or live close/reopen"; do
  if ! grep -Fq "$preview_failure_plan_contract" "$PREVIEW_FAILURE_OWNERSHIP_PLAN"; then
    printf '%s\n' "Preview failure ownership plan must record completed verification: $preview_failure_plan_contract" >&2
    exit 1
  fi
done

if grep -Fq 'new ErrorDialog().show(getFragmentManager(), "dialog");' "$FRAGMENT"; then
  printf '%s\n' "Unsupported-camera error dialog must not use getFragmentManager() without a null guard." >&2
  exit 1
fi

if ! grep -Fq "import android.app.FragmentManager;" "$FRAGMENT" ||
  ! grep -Fq "FragmentManager fragmentManager = getFragmentManager();" "$FRAGMENT"; then
  printf '%s\n' "Unsupported-camera error dialog must guard detached fragment manager state." >&2
  exit 1
fi

if ! grep -Fq "activity != null && fragmentManager != null" "$FRAGMENT"; then
  printf '%s\n' "Unsupported-camera error dialog must require an attached activity before display." >&2
  exit 1
fi

if ! grep -Fq "mPreviewRequestBuilder == null || mCaptureSession == null" "$FRAGMENT"; then
  printf '%s\n' "Focus and precapture calls must guard closed session state." >&2
  exit 1
fi

if ! grep -Fq "mImageReader == null || mCaptureSession == null" "$FRAGMENT"; then
  printf '%s\n' "Still capture must guard closed image reader and capture session state." >&2
  exit 1
fi

if grep -Fq 'showToast("Saved: " + mFile)' "$FRAGMENT"; then
  printf '%s\n' "Capture completion toast must not expose the app-private output file path." >&2
  exit 1
fi

if grep -Fq 'showToast("Picture saved")' "$FRAGMENT"; then
  printf '%s\n' "Camera capture completion must not report file-save success prematurely." >&2
  exit 1
fi

if ! grep -Fq "mPreviewRequestBuilder == null || mCaptureSession == null || mPreviewRequest == null" "$FRAGMENT"; then
  printf '%s\n' "Focus unlock must guard closed preview state." >&2
  exit 1
fi

if ! grep -Fq "mImage == null || mFile == null" "$FRAGMENT"; then
  printf '%s\n' "ImageSaver must guard missing image/file state." >&2
  exit 1
fi

image_callback=$(sed -n '/public void onImageAvailable(ImageReader reader)/,/^        }$/p' "$FRAGMENT")
image_callback_compact=$(printf '%s\n' "$image_callback" | tr '\n' ' ' | tr -s '[:space:]' ' ')
for image_handoff_contract in \
  'Handler backgroundHandler = mBackgroundHandler;' \
  'if (backgroundHandler == null || mFile == null)' \
  'if (!backgroundHandler.post(new ImageSaver(image, mFile, mMessageHandler)) &&' \
  'image.close();'; do
  if ! printf '%s\n' "$image_callback" | grep -Fq "$image_handoff_contract"; then
    printf '%s\n' "Image callback handoff ownership changed: $image_handoff_contract" >&2
    exit 1
  fi
done
if ! printf '%s\n' "$image_callback_compact" | grep -Fq \
    'if (!backgroundHandler.post(new ImageSaver(image, mFile, mMessageHandler)) && image != null) { image.close(); }' || \
   [ "$(printf '%s\n' "$image_callback" | grep -Fc 'backgroundHandler.post(new ImageSaver(image, mFile, mMessageHandler))')" -ne 1 ] || \
   printf '%s\n' "$image_callback" | grep -Fq 'mBackgroundHandler.post(new ImageSaver(image, mFile, mMessageHandler))'; then
  printf '%s\n' "Rejected image-save posts must close the callback-owned image exactly once." >&2
  exit 1
fi

image_saver_scope=$(sed -n '/private static class ImageSaver implements Runnable/,/^    }/p' "$FRAGMENT")
for save_success_contract in \
  'private final Handler mResultHandler;' \
  'public ImageSaver(Image image, File file, Handler resultHandler)' \
  'mResultHandler = resultHandler;' \
  'boolean saved = false;' \
  'try (FileOutputStream output = new FileOutputStream(mFile))' \
  'output.write(bytes);' \
  'saved = true;' \
  'catch (IOException e)' \
  'saved = false;' \
  'if (saved && mResultHandler != null)' \
  'message.obj = "Picture saved";' \
  'mResultHandler.sendMessage(message);'; do
  if ! printf '%s\n' "$image_saver_scope" | grep -Fq "$save_success_contract"; then
    printf '%s\n' "ImageSaver success ordering changed: $save_success_contract" >&2
    exit 1
  fi
done
save_failure_scope=$(sed -n '/catch (IOException e)/,/^            } finally/p' "$FRAGMENT")
save_failure_compact=$(printf '%s\n' "$save_failure_scope" | tr '\n' ' ' | tr -s '[:space:]' ' ')
if ! printf '%s\n' "$save_failure_scope" | grep -Fq 'saved = false;' || \
   [ "$(printf '%s\n' "$image_saver_scope" | grep -Fc 'saved = false;')" -ne 2 ]; then
  printf '%s\n' "ImageSaver must clear save success when file output fails or cannot close." >&2
  exit 1
fi
if ! printf '%s\n' "$save_failure_scope" | grep -Fq 'Log.e(TAG, "Unable to save picture.");' || \
   printf '%s\n' "$save_failure_scope" | grep -Fq 'printStackTrace()' || \
   printf '%s\n' "$save_failure_scope" | grep -Eq 'Log\.[a-z]+\([^;]*, *e\)' || \
   [ "$(printf '%s\n' "$image_saver_scope" | grep -Fc 'Log.e(TAG, "Unable to save picture.");')" -ne 1 ]; then
  printf '%s\n' "ImageSaver failures must use one generic log without throwable details." >&2
  exit 1
fi
if ! printf '%s\n' "$save_failure_compact" | grep -Fq \
    'saved = false; Log.e(TAG, "Unable to save picture.");' ; then
  printf '%s\n' "ImageSaver must clear save success before generic failure logging." >&2
  exit 1
fi
write_line=$(printf '%s\n' "$image_saver_scope" | grep -nF 'output.write(bytes);' | cut -d: -f1)
catch_line=$(printf '%s\n' "$image_saver_scope" | grep -nF 'catch (IOException e)' | cut -d: -f1)
close_line=$(printf '%s\n' "$image_saver_scope" | grep -nF 'mImage.close();' | tail -1 | cut -d: -f1)
success_line=$(printf '%s\n' "$image_saver_scope" | grep -nF 'if (saved && mResultHandler != null)' | cut -d: -f1)
message_line=$(printf '%s\n' "$image_saver_scope" | grep -nF 'message.obj = "Picture saved";' | cut -d: -f1)
if [ -z "$write_line" ] || [ -z "$catch_line" ] || [ -z "$close_line" ] || \
   [ -z "$success_line" ] || [ -z "$message_line" ] || \
   [ "$write_line" -ge "$catch_line" ] || [ "$catch_line" -ge "$close_line" ] || \
   [ "$close_line" -ge "$success_line" ] || [ "$success_line" -ge "$message_line" ] || \
   [ "$(grep -Fc '"Picture saved"' "$FRAGMENT")" -ne 1 ]; then
  printf '%s\n' "ImageSaver must report success only after completed output cleanup." >&2
  exit 1
fi
for save_success_doc in "$README" "$ROOT_DIR/SECURITY.md" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$save_success_doc" | tr -s '[:space:]' ' ' | \
      grep -Fq 'reports picture-save success only after file output closes successfully'; then
    printf '%s\n' "${save_success_doc#"$ROOT_DIR/"} must document success-only save notification ordering." >&2
    exit 1
  fi
done
for save_success_plan_contract in 'Status: Completed' 'make check' 'mutations'; do
  if ! grep -Fq "$save_success_plan_contract" "$SAVE_SUCCESS_PLAN"; then
    printf '%s\n' "Camera save-success plan must record completed verification: $save_success_plan_contract" >&2
    exit 1
  fi
done

for save_failure_log_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq 'Image-save failures log a generic category without exception details or private output paths.' "$ROOT_DIR/$save_failure_log_doc"; then
    printf '%s\n' "$save_failure_log_doc must document generic image-save failure logging." >&2
    exit 1
  fi
done
for save_failure_log_plan_contract in 'Status: Completed' 'make check' 'mutations'; do
  if ! grep -Fq "$save_failure_log_plan_contract" "$SAVE_FAILURE_LOG_PLAN"; then
    printf '%s\n' "Camera save-failure log plan must record completed verification: $save_failure_log_plan_contract" >&2
    exit 1
  fi
done
if [ ! -f "$IMAGE_HANDOFF_PLAN" ] || \
   ! grep -Fq 'Status: Completed' "$IMAGE_HANDOFF_PLAN" || \
   ! grep -Fq 'make check' "$IMAGE_HANDOFF_PLAN" || \
   ! grep -Fq 'hostile mutations' "$IMAGE_HANDOFF_PLAN"; then
  printf '%s\n' "Camera image handoff plan must record completed verification." >&2
  exit 1
fi
if ! tr '\n' ' ' < "$ROOT_DIR/AGENTS.md" | tr -s '[:space:]' ' ' | grep -Fq 'rejected image-save handoffs close the callback-owned image' || \
   ! tr '\n' ' ' < "$README" | tr -s '[:space:]' ' ' | grep -Fq 'rejected background-handler handoffs close the acquired image' || \
   ! grep -Fq 'Closed callback-owned images when the background handler rejects' "$ROOT_DIR/CHANGES.md" || \
   ! grep -Fq 'Keep rejected image-save handoffs from leaking reader capacity' "$ROOT_DIR/VISION.md"; then
  printf '%s\n' "Camera image handoff ownership documentation is incomplete." >&2
  exit 1
fi

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required CameraApp device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic scene' \
  'Camera permission denied' \
  'Camera permission granted' \
  'Preview startup' \
  'Unsupported camera' \
  'Still capture' \
  'Rejected save handoff' \
  'Orientation change' \
  'Background and resume' \
  'System bar insets' \
  'Sustained capture' \
  'Process relaunch' \
  'Do not convert `not run` into passing evidence.' \
  'device identifiers, captured images, room imagery' \
  'every emulator, camera, permission, preview, capture, and lifecycle row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "CameraApp device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fq 'CameraApp device verification matrix' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' 'Repository guidance must document the unexecuted CameraApp device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No Android emulator, physical camera, permission interaction, live preview, capture, orientation, or lifecycle scenario was executed'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "CameraApp device plan must keep completion evidence: $device_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "planes == null || planes.length == 0 || planes[0] == null" "$FRAGMENT"; then
  printf '%s\n' "ImageSaver must guard missing image planes." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$README"; then
  printf '%s\n' "README must document the baseline guard." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$README"; then
  printf '%s\n' "README must document the GitHub Actions check." >&2
  exit 1
fi

README_FLAT=$(tr '\n' ' ' < "$README" | tr -s '[:space:]' ' ')
for instrumentation_doc_contract in \
  "connectedDebugAndroidTest" \
  "pre-permission activity/fragment startup" \
  "real camera-permission denial action" \
  "denial remains settled across activity recreation" \
  "does not prove permission grant, camera preview, or capture behavior"; do
  if ! printf '%s\n' "$README_FLAT" | grep -Fq "$instrumentation_doc_contract"; then
    printf '%s\n' "README must document hosted instrumentation scope: $instrumentation_doc_contract" >&2
    exit 1
  fi
done

if ! tr '\n' ' ' < "$ROOT_DIR/CHANGES.md" | tr -s '[:space:]' ' ' | \
    grep -Fq 'retained fragment neither loses denial state nor restarts the permission request'; then
  printf '%s\n' "CHANGES.md must document post-recreation camera denial coverage." >&2
  exit 1
fi

PERMISSION_DENIAL_PLAN_FLAT=$(tr '\n' ' ' < "$PERMISSION_DENIAL_INSTRUMENTATION_PLAN" | tr -s '[:space:]' ' ')
for permission_denial_plan_contract in \
  "status: completed" \
  "camera permission is denied on the fresh hosted install" \
  "real API 36 permission-controller denial action" \
  "does not immediately re-request camera permission after denial" \
  "activity and camera fragment remain alive after denial" \
  "push and pull-request hosted instrumentation success" \
  "27656010921" \
  "27656012503" \
  "0af9dcf0be82dec5ad4844f922e83a4f3d218eb0"; do
  if ! printf '%s\n' "$PERMISSION_DENIAL_PLAN_FLAT" | grep -Fq "$permission_denial_plan_contract"; then
    printf '%s\n' "Permission-denial instrumentation plan must preserve contract: $permission_denial_plan_contract" >&2
    exit 1
  fi
done

PERMISSION_DENIAL_RECREATION_PLAN_FLAT=$(tr '\n' ' ' < "$PERMISSION_DENIAL_RECREATION_PLAN" | tr -s '[:space:]' ' ')
for permission_denial_recreation_plan_contract in \
  'status: completed' \
  'Recreate `CameraActivity` after the denial callback has settled' \
  'retained fragment still records denial' \
  'permission dialog does not reappear after recreation' \
  'Require exact-head push and pull-request hosted instrumentation success' \
  'Seven isolated mutations were rejected' \
  'Exact implementation head `dbbca280f4a42759f88a19dda26016bedb62cd44`' \
  '27679897578' \
  '27679909628'; do
  if ! printf '%s\n' "$PERMISSION_DENIAL_RECREATION_PLAN_FLAT" | grep -Fq "$permission_denial_recreation_plan_contract"; then
    printf '%s\n' "Permission-denial recreation plan must preserve contract: $permission_denial_recreation_plan_contract" >&2
    exit 1
  fi
done

for instrumentation_plan_contract in \
  "status: completed" \
  "repository-owned API 36 Google APIs emulator" \
  "Bound emulator discovery and boot completion to three minutes" \
  ":Application:connectedDebugAndroidTest" \
  "SKIP_ANDROID_INSTRUMENTATION=1" \
  "75cbcb75a217599c6ec42446a48461c26ed971b9" \
  "27640848165" \
  "27640853374"; do
  if ! grep -Fq "$instrumentation_plan_contract" "$INSTRUMENTATION_EXECUTION_PLAN"; then
    printf '%s\n' "Instrumentation execution plan must preserve contract: $instrumentation_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "/usr/bin/make check" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must check out the repository and run the system Make gate." >&2
  exit 1
fi

if [ "$(grep -Fc 'uses: actions/checkout@' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Fc 'persist-credentials: false' "$CI_WORKFLOW")" -ne 1 ] || \
   grep -E '^[[:space:]]*(-[[:space:]]+)?uses:' "$CI_WORKFLOW" | grep -Ev '@[0-9a-f]{40}([[:space:]]+#.*)?$' >/dev/null; then
  printf '%s\n' "The only checkout step must be immutable and must not persist credentials." >&2
  exit 1
fi

if ! grep -Fq "permissions:" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "contents: read" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must keep repository access read-only." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "timeout-minutes: 25" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must support bounded manual verification." >&2
  exit 1
fi

if [ "$(grep -Ec '^[[:space:]]*permissions:' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Ec '^[[:space:]]+contents:[[:space:]]*read[[:space:]]*$' "$CI_WORKFLOW")" -ne 1 ] || \
   grep -Eq 'write-all|:[[:space:]]*write|continue-on-error:[[:space:]]*true|if:[[:space:]]*false' "$CI_WORKFLOW" || \
   [ "$(grep -Ec '^[[:space:]]*(-[[:space:]]+)?run:' "$CI_WORKFLOW")" -ne 2 ]; then
  printf '%s\n' "Check workflow must keep exact read-only permissions and two required commands." >&2
  exit 1
fi

for trusted_workflow_contract in \
  'pull_request_target:' \
  'permissions:' \
  'contents: read' \
  'environment:' \
  'name: cameraapp-trusted-verifier-v1' \
  'ref: ${{ github.workflow_sha }}' \
  'HEAD_REPO: ${{ github.event.pull_request.head.repo.full_name }}' \
  'HEAD_SHA: ${{ github.event.pull_request.head.sha }}' \
  '/usr/bin/git -C candidate fetch --no-tags --filter=blob:none --depth=2 pr "$HEAD_SHA"' \
  '/usr/bin/git -C candidate checkout --detach "$HEAD_SHA"' \
  'persist-credentials: false' \
  'set-safe-directory: false' \
  'submodules: false' \
  'lfs: false' \
  '/usr/bin/python3 -I -S -B trusted-base/trusted-verifier/verify_environment.py' \
  '/bin/sh -p trusted-base/trusted-verifier/run-hermetic.sh'; do
  if ! grep -Fq "$trusted_workflow_contract" "$TRUSTED_GATE_WORKFLOW"; then
    printf '%s\n' "Trusted CameraApp workflow must preserve contract: $trusted_workflow_contract" >&2
    exit 1
  fi
done

if grep -Eq 'write-all|:[[:space:]]*write|secrets\.|actions/cache|candidate/(Makefile|scripts)|make check|./gradlew' "$TRUSTED_GATE_WORKFLOW"; then
  printf '%s\n' "Trusted CameraApp workflow must not execute candidate code or request writable/secrets authority." >&2
  exit 1
fi

for trusted_policy_contract in \
  '"bootstrap_exact_default": "50abf2951082f2cc6f7b4d41e4c300cd42957b0a"' \
  '"environment": "cameraapp-trusted-verifier-v1"' \
  '"diagnostic_check_context_is_authoritative": false' \
  '"kind": "required_protected_environment_deployment"' \
  '"required_environment_branch": "master"' \
  '"15c0885755c41aa18aeb92a85193facdb61fb55c"' \
  '"67b2352a032ff956c4034e9215c53709d5e340bf"' \
  '"Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java"' \
  '"DEVICE_VERIFICATION.md"' \
  '"scripts/check-baseline.sh"' \
  '"trusted-verifier/verify_environment.py"' \
  '"docs/plans/2026-06-26-cameraapp-ready-capture-state.md"' \
  '"trusted-verifier/expected/ready-capture-state/scripts/check-baseline.sh"'; do
  if ! grep -Fq "$trusted_policy_contract" "$TRUSTED_GATE_POLICY"; then
    printf '%s\n' "Trusted CameraApp policy must preserve contract: $trusted_policy_contract" >&2
    exit 1
  fi
done

for trusted_test_contract in \
  'test_pull_request_candidate_cannot_noop_or_symlink_direct_gate' \
  'test_candidate_workflow_spoofing_extra_commits_files_and_modes_are_rejected' \
  'test_environment_preflight_rejects_environment_or_app_mismatch' \
  'test_shallow_candidate_history_is_rejected' \
  'test_fake_tools_and_python_startup_are_ignored' \
  'test_archive_path_and_size_limits_reject_hostile_candidates'; do
  if ! grep -Fq "$trusted_test_contract" "$TRUSTED_GATE_TEST"; then
    printf '%s\n' "Trusted CameraApp regression suite must preserve: $trusted_test_contract" >&2
    exit 1
  fi
done

for trusted_plan_contract in \
  "Phase 1" \
  "Phase 2" \
  "cameraapp-trusted-verifier-v1" \
  "required protected environment deployment" \
  "No GitHub writes" \
  "15c0885755c41aa18aeb92a85193facdb61fb55c and 67b2352a032ff956c4034e9215c53709d5e340bf remain rejected sibling non-ancestors"; do
  if ! grep -Fq "$trusted_plan_contract" "$TRUSTED_GATE_PLAN"; then
    printf '%s\n' "Trusted CameraApp rollout plan must preserve: $trusted_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "distributionSha256Sum" "$README" || \
   ! grep -Fq "does not persist checkout credentials" "$README" || \
   ! grep -Fq "Gradle 9.6.1 wrapper authenticates" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "checksum-verified direct wrapper" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "authenticated Gradle wrapper" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Documentation must describe authenticated wrapper and checkout boundaries." >&2
  exit 1
fi

for gradle_96_contract in \
  "## Status: Completed" \
  "Gradle 9.6.0" \
  "bbaeb2fef8710818cf0e261201dab964c572f92b942812df0c3620d62a529a01" \
  "make check"; do
  if ! grep -Fq "$gradle_96_contract" "$GRADLE_96_REFRESH_PLAN"; then
    printf '%s\n' "Gradle 9.6 refresh plan must preserve completion evidence: $gradle_96_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "local.properties" "$README"; then
  printf '%s\n' "README must document local SDK configuration." >&2
  exit 1
fi

for plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "## Verification Results" \
  "make -f /absolute/path/to/Makefile check" \
  "Thirteen isolated hostile mutations were rejected" \
  "No camera-capable emulator or physical device was available"; do
  if ! grep -Fq "$plan_contract" "$ANDROID_16_PLAN"; then
    printf '%s\n' "Android 16 migration plan must preserve completion evidence: $plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "Android Build Tools 36.1.0" "$README"; then
  printf '%s\n' "README must document the build-tools baseline." >&2
  exit 1
fi

if ! grep -Fq "only preview-SDK availability advisories are disabled" "$README"; then
  printf '%s\n' "README must document the scoped preview-SDK lint suppression." >&2
  exit 1
fi

for lint_doc_contract in \
  "./gradlew :Application:lintDebug --no-daemon" \
  "./gradlew :Application:lintRelease --no-daemon"; do
  if ! grep -Fq "$lint_doc_contract" "$README"; then
    printf '%s\n' "README must document sequential lint command: $lint_doc_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "./gradlew :Application:assembleDebug --no-daemon" "$README"; then
  printf '%s\n' "README must document the debug assemble gate." >&2
  exit 1
fi

if ! grep -Fq "hosted API 36 gate is configured to execute" "$README"; then
  printf '%s\n' "README must document instrumentation test runtime requirements." >&2
  exit 1
fi

if ! grep -Fq "CHANGES.md" "$README"; then
  printf '%s\n' "README must point to CHANGES.md." >&2
  exit 1
fi

if ! grep -Fq "Camera background thread startup is idempotent" "$README"; then
  printf '%s\n' "README must document background thread lifecycle guard." >&2
  exit 1
fi

if ! grep -Fq "Camera close releases the semaphore only after successful acquisition" "$README"; then
  printf '%s\n' "README must document camera close semaphore ownership." >&2
  exit 1
fi

if ! grep -Fq "Opened, disconnected, and error callbacks share one atomic release token" "$ROOT_DIR/AGENTS.md" || \
   ! grep -Fq "Opened, disconnected, and error callbacks atomically consume one transferred" "$README" || \
   ! grep -Fq "Camera open callbacks atomically consume one release token" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "Keep all camera-open callbacks bound to one atomic semaphore-release token" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'Prevented a disconnect or error delivered after `onOpened`' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Camera open callback lock ownership guidance must remain checked in." >&2
  exit 1
fi

for callback_lock_plan_contract in \
  "Status: Completed" \
  "RED: the source baseline rejected the missing atomic callback ownership" \
  "Four isolated ownership mutations were rejected" \
  "one direct child" \
  "No emulator, physical camera, or live post-open disconnect/error callback"; do
  if ! grep -Fq "$callback_lock_plan_contract" "$CAMERA_OPEN_CALLBACK_LOCK_PLAN"; then
    printf '%s\n' "Camera callback lock ownership plan must record completed verification: $callback_lock_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "Toast messages use a static main-looper handler with a weak fragment reference" "$README"; then
  printf '%s\n' "README must document lifecycle-safe toast delivery." >&2
  exit 1
fi

if ! grep -Fq "ImageReader backpressure" "$README"; then
  printf '%s\n' "README must document ImageReader backpressure handling." >&2
  exit 1
fi

if ! grep -Fq "Android backup is disabled" "$README"; then
  printf '%s\n' "README must document the disabled-backup privacy baseline." >&2
  exit 1
fi

if ! grep -Fq "Resume skips camera open until the texture view is recreated" "$README"; then
  printf '%s\n' "README must document the retained-fragment texture resume guard." >&2
  exit 1
fi

if ! grep -Fq "Capture completion UI does not expose the app-private output file path" "$README"; then
  printf '%s\n' "README must document the capture saved-toast privacy guard." >&2
  exit 1
fi

if ! grep -Fq "Picture and info controls are listener-bound only when present" "$README"; then
  printf '%s\n' "README must document the control binding guard." >&2
  exit 1
fi

if ! grep -Fq "Unsupported-camera error dialogs require an attached fragment manager" "$README"; then
  printf '%s\n' "README must document the unsupported-camera dialog fragment manager guard." >&2
  exit 1
fi

if ! grep -Fq "Unsupported-camera dialogs also require an attached activity before display" "$README"; then
  printf '%s\n' "README must document the unsupported-camera dialog activity guard." >&2
  exit 1
fi

if ! grep -Fq "Synchronous camera-open failures release the open/close semaphore" "$README"; then
  printf '%s\n' "README must document camera open semaphore recovery." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile must remain available as the root verification entry point." >&2
  exit 1
fi

if ! grep -Fq '.DEFAULT_GOAL := check' "$ROOT_DIR/Makefile" || \
   ! grep -Fq 'override ROOT := $(shell' "$ROOT_DIR/Makefile" || \
   ! grep -Fq 'MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone' "$ROOT_DIR/Makefile" || \
   ! grep -Fq 'non-executing or error-ignoring MAKEFLAGS are not supported for repository verification' "$ROOT_DIR/Makefile" || \
   ! grep -Fq "'\$(REPOSITORY_GRADLE_LITERAL)' -p '\$(REPOSITORY_ROOT_LITERAL)'" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must preserve repository-root, system-Make, startup-file, and execution-mode authority." >&2
  exit 1
fi

if [ "$(grep -Fc "'\$(REPOSITORY_GRADLE_LITERAL)' -p '\$(REPOSITORY_ROOT_LITERAL)'" "$ROOT_DIR/Makefile")" -ne 4 ]; then
  printf '%s\n' "Makefile must root both lint variants, test, and build Gradle tasks." >&2
  exit 1
fi

if [ ! -x "$ROOT_DIR/scripts/test-makefile-root.sh" ] || \
   ! sh -n "$ROOT_DIR/scripts/test-makefile-root.sh"; then
  printf '%s\n' "Make authority regression harness must remain executable and syntactically valid." >&2
  exit 1
fi

if ! grep -Fq "runs-on: ubuntu-24.04" "$ROOT_DIR/.github/workflows/check.yml" || \
   ! grep -Fq "cancel-in-progress: true" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions must use a stable runner and cancel superseded checks." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-09-cameraapp-image-reader-backpressure.md"; then
  printf '%s\n' "ImageReader backpressure plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-cameraapp-image-reader-backpressure.md"; then
  printf '%s\n' "ImageReader backpressure plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-09-cameraapp-disable-backup.md"; then
  printf '%s\n' "CameraApp disable-backup plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-cameraapp-disable-backup.md"; then
  printf '%s\n' "CameraApp disable-backup plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$TEXTURE_RESUME_PLAN"; then
  printf '%s\n' "CameraApp texture resume guard plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$TEXTURE_RESUME_PLAN"; then
  printf '%s\n' "CameraApp texture resume guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$SAVE_TOAST_PLAN"; then
  printf '%s\n' "CameraApp save toast privacy plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$SAVE_TOAST_PLAN"; then
  printf '%s\n' "CameraApp save toast privacy plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CONTROL_BINDING_PLAN"; then
  printf '%s\n' "CameraApp control binding guard plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$CONTROL_BINDING_PLAN"; then
  printf '%s\n' "CameraApp control binding guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ERROR_DIALOG_PLAN"; then
  printf '%s\n' "CameraApp error dialog fragment manager plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ERROR_DIALOG_PLAN"; then
  printf '%s\n' "CameraApp error dialog fragment manager plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ERROR_DIALOG_ACTIVITY_PLAN"; then
  printf '%s\n' "CameraApp error dialog activity guard plan must record completed status." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ERROR_DIALOG_ACTIVITY_PLAN"; then
  printf '%s\n' "CameraApp error dialog activity guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed once the baseline is implemented." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "CameraApp CI baseline plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CAMERA_OPEN_LOCK_PLAN" || ! grep -Fq "make check" "$CAMERA_OPEN_LOCK_PLAN"; then
  printf '%s\n' "CameraApp camera open lock plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CAMERA_CLOSE_LOCK_PLAN" || ! grep -Fq "make check" "$CAMERA_CLOSE_LOCK_PLAN"; then
  printf '%s\n' "CameraApp camera close lock plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$FOCUS_STATE_RECOVERY_PLAN" || \
   ! grep -Fq "scripts/check-baseline.sh" "$FOCUS_STATE_RECOVERY_PLAN" || \
   ! grep -Fq "The local environment has no Android SDK, emulator, or physical camera" "$FOCUS_STATE_RECOVERY_PLAN"; then
  printf '%s\n' "CameraApp focus state recovery plan must record status, verification, and device limits." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$PREVIEW_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "one direct child" "$PREVIEW_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "exact eight-file synthetic semantic child" "$PREVIEW_TRUSTED_POLICY_PLAN"; then
  printf '%s\n' "CameraApp preview trusted policy plan must record status, topology, and exact-child evidence." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CALLBACK_LOCK_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "one direct child" "$CALLBACK_LOCK_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "exact eight-file synthetic semantic child" "$CALLBACK_LOCK_TRUSTED_POLICY_PLAN"; then
  printf '%s\n' "CameraApp callback-lock trusted policy plan must record status, topology, and exact-child evidence." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$OPEN_PUBLICATION_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "one direct child" "$OPEN_PUBLICATION_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "exact nine-file synthetic semantic child" "$OPEN_PUBLICATION_TRUSTED_POLICY_PLAN"; then
  printf '%s\n' "CameraApp opened-publication trusted policy plan must record status, topology, and exact-child evidence." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$GRADLE_961_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "one direct child" "$GRADLE_961_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "exact eleven-file synthetic semantic child" "$GRADLE_961_TRUSTED_POLICY_PLAN"; then
  printf '%s\n' "CameraApp Gradle 9.6.1 trusted policy plan must record status, topology, and exact-child evidence." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$READY_CAPTURE_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "one direct child" "$READY_CAPTURE_TRUSTED_POLICY_PLAN" || \
   ! grep -Fq "exact nine-file synthetic semantic child" "$READY_CAPTURE_TRUSTED_POLICY_PLAN"; then
  printf '%s\n' "CameraApp ready-capture trusted policy plan must record status, topology, and exact-child evidence." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$READY_CAPTURE_POLICY_CORRECTION_PLAN" || \
   ! grep -Fq "one direct child" "$READY_CAPTURE_POLICY_CORRECTION_PLAN" || \
   ! grep -Fq "exact nine-file synthetic semantic child" "$READY_CAPTURE_POLICY_CORRECTION_PLAN"; then
  printf '%s\n' "CameraApp ready-capture policy correction plan must record status, topology, and exact-child evidence." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$PREVIEW_SESSION_RECOVERY_PLAN" || \
   ! grep -Fq "RED: the source baseline rejected the missing preview ownership guard" "$PREVIEW_SESSION_RECOVERY_PLAN" || \
   ! grep -Fq "exact-head Codex review" "$PREVIEW_SESSION_RECOVERY_PLAN"; then
  printf '%s\n' "CameraApp preview session recovery plan must record status, red evidence, and merge gates." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$TOAST_HANDLER_PLAN" || ! grep -Fq "make check" "$TOAST_HANDLER_PLAN"; then
  printf '%s\n' "CameraApp toast handler plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "CameraApp build hygiene baseline checks passed."
