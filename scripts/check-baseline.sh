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
   ! grep -Fq ":Application:assembleDebugAndroidTest" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Make lint must reject every Android lint finding without suppression." >&2
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
  'sdkmanager "platforms;android-36" "build-tools;36.1.0"' \
  'timeout 12m make check'; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "CI must preserve Android 16 toolchain contract: $workflow_contract" >&2
    exit 1
  fi
done

if grep -Fq 'android-actions/setup-android@' "$CI_WORKFLOW"; then
  printf '%s\n' "CI must not use actions outside this repository's allowed Actions policy." >&2
  exit 1
fi

if ! grep -Fq "mBackgroundHandler == null || mFile == null" "$FRAGMENT"; then
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

if ! grep -Fq "mTextureView == null || mCameraDevice == null" "$FRAGMENT" ||
  ! grep -Fq "if (texture == null)" "$FRAGMENT"; then
  printf '%s\n' "Preview session creation must guard missing texture and camera state." >&2
  exit 1
fi

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

if ! grep -Fq 'showToast("Picture saved")' "$FRAGMENT"; then
  printf '%s\n' "Capture completion toast must use generic saved-copy." >&2
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
  ! grep -Fq "timeout-minutes: 15" "$ROOT_DIR/.github/workflows/check.yml"; then
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

if ! grep -Fq "./gradlew :Application:lintDebug :Application:lintRelease --no-daemon" "$README"; then
  printf '%s\n' "README must document the lint gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew :Application:assembleDebug --no-daemon" "$README"; then
  printf '%s\n' "README must document the debug assemble gate." >&2
  exit 1
fi

if ! grep -Fq "Instrumentation tests require an Android device or emulator" "$README"; then
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

if [ "$(grep -Fc '$(GRADLE_COMMAND) -p "$(ROOT)"' "$ROOT_DIR/Makefile")" -ne 3 ]; then
  printf '%s\n' "Makefile must root lint, test, and build Gradle tasks." >&2
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
