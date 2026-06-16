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
INSTRUMENTATION_EXECUTION_PLAN="$ROOT_DIR/docs/plans/2026-06-16-cameraapp-instrumentation-execution.md"
INSTRUMENTATION_RUNNER="$ROOT_DIR/scripts/run-instrumentation.sh"
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
distributionSha256Sum=bafc141b619ad6350fd975fc903156dd5c151998cc8b058e8c1044ab5f7b031f
distributionUrl=https\://services.gradle.org/distributions/gradle-9.5.1-bin.zip
networkTimeout=10000
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
  "scripts/run-instrumentation.sh" \
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
   ! grep -Fq 'SKIP_ANDROID_INSTRUMENTATION ?= 0' "$ROOT_DIR/Makefile" || \
   ! grep -Fq 'GRADLE="$(GRADLE_COMMAND)" "$(ROOT)scripts/run-instrumentation.sh"' "$ROOT_DIR/Makefile"; then
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
  'kill -0 "$emulator_pid"' \
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

if grep -Fq 'wait-for-device' "$INSTRUMENTATION_RUNNER"; then
  printf '%s\n' "Instrumentation runner must not block outside the bounded boot loop." >&2
  exit 1
fi

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
  printf '%s\n' "Generated wrapper must retain the reviewed Gradle 9.5.1 URL and checksum." >&2
  exit 1
fi

require_sha256 "$GRADLEW" "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" "Unix wrapper must match the reviewed generated script."
require_sha256 "$GRADLEW_BAT" "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" "Windows wrapper must match the reviewed generated script."
require_sha256 "$WRAPPER_JAR" "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" "Wrapper JAR must match the reviewed generated artifact."
require_sha256 "$WRAPPER_PROPERTIES" "dc61433ab2b0a18b8fd92d5f0f0b72ba2401b0393fd9d24a3d4fc3b63a314cd6" "Wrapper properties must match the reviewed checksum contract."

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
  "androidTestImplementation 'androidx.test:core:1.7.0'" \
  "androidTestImplementation 'androidx.test.ext:junit:1.3.0'" \
  "androidTestImplementation 'androidx.test:runner:1.7.0'"; do
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
  'ActivityScenario.launch(CameraActivity.class)' \
  'getFragmentManager().findFragmentById(R.id.container)' \
  'assertNotNull("Camera fragment is null", fragment)'; do
  if ! grep -Fq "$test_contract" "$TEST_FIXTURE"; then
    printf '%s\n' "Instrumentation fixture must preserve current smoke contract: $test_contract" >&2
    exit 1
  fi
done

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
  'requestPermissions(new String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA_PERMISSION)' \
  'public void onRequestPermissionsResult' \
  'mCameraPermissionRequestPending = false' \
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
  '"platforms;android-36"' \
  '"build-tools;36.1.0"' \
  '"system-images;android-36;google_apis;x86_64"' \
  'sudo chmod 666 /dev/kvm' \
  'timeout 22m make check'; do
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

if [ "$(grep -Fc 'catch (CameraAccessException e)' "$FRAGMENT")" -ne 6 ] || \
   [ "$(grep -Fc 'catch (CameraAccessException | IllegalStateException e)' "$FRAGMENT")" -ne 2 ]; then
  printf '%s\n' "Camera error redaction must preserve six access-only and two closed-session recovery boundaries." >&2
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
  "try {"; do
  if [ "$(printf '%s\n' "$unlock_focus_method" | grep -Fc "$recovery_marker")" -ne 1 ]; then
    printf '%s\n' "Focus recovery marker must be unique: $recovery_marker" >&2
    exit 1
  fi
done
preview_state_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "mState = STATE_PREVIEW;" | cut -d: -f1)
preview_guard_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "if (mPreviewRequestBuilder == null || mCaptureSession == null || mPreviewRequest == null)" | cut -d: -f1)
preview_try_line=$(printf '%s\n' "$unlock_focus_method" | grep -nF "try {" | cut -d: -f1)
if [ "$preview_state_line" -ge "$preview_guard_line" ] || \
  [ "$preview_state_line" -ge "$preview_try_line" ]; then
  printf '%s\n' "Focus recovery must publish preview state before nullable or throwing Camera2 work." >&2
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
  "cameraCaptureSession.close();" \
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

stale_guard_line=$(printf '%s\n' "$configured_callback" | grep -nF "if (mCameraDevice != cameraDevice)" | cut -d: -f1)
stale_close_line=$(printf '%s\n' "$configured_callback" | grep -nF "cameraCaptureSession.close();" | cut -d: -f1)
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
  "does not prove camera preview or capture behavior"; do
  if ! printf '%s\n' "$README_FLAT" | grep -Fq "$instrumentation_doc_contract"; then
    printf '%s\n' "README must document hosted instrumentation scope: $instrumentation_doc_contract" >&2
    exit 1
  fi
done

for instrumentation_plan_contract in \
  "status: completed" \
  "repository-owned API 36 Google APIs emulator" \
  "Bound emulator discovery and boot completion to three minutes" \
  ":Application:connectedDebugAndroidTest" \
  "SKIP_ANDROID_INSTRUMENTATION=1" \
  "Exact-head hosted push and pull-request instrumentation execution before"; do
  if ! grep -Fq "$instrumentation_plan_contract" "$INSTRUMENTATION_EXECUTION_PLAN"; then
    printf '%s\n' "Instrumentation execution plan must preserve contract: $instrumentation_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "make check" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must check out the repository and run make check." >&2
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

if ! grep -Fq "distributionSha256Sum" "$README" || \
   ! grep -Fq "does not persist checkout credentials" "$README" || \
   ! grep -Fq "Gradle 9.5.1 wrapper authenticates" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "checksum-verified direct wrapper" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "authenticated Gradle wrapper" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Documentation must describe authenticated wrapper and checkout boundaries." >&2
  exit 1
fi

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

if ! grep -Fq "hosted API 36 emulator executes" "$README"; then
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

if ! grep -Fq 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$ROOT_DIR/Makefile" || \
   ! grep -Fq 'GRADLE_COMMAND :=' "$ROOT_DIR/Makefile" || \
   ! grep -Fq '$(GRADLE_COMMAND) -p "$(ROOT)"' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run Gradle relative to its own repository root." >&2
  exit 1
fi

if [ "$(grep -Fc '$(GRADLE_COMMAND) -p "$(ROOT)"' "$ROOT_DIR/Makefile")" -ne 4 ]; then
  printf '%s\n' "Makefile must root both lint variants, test, and build Gradle tasks." >&2
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

if ! grep -Fq "Status: Completed" "$TOAST_HANDLER_PLAN" || ! grep -Fq "make check" "$TOAST_HANDLER_PLAN"; then
  printf '%s\n' "CameraApp toast handler plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "CameraApp build hygiene baseline checks passed."
