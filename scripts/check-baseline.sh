#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_BUILD="$ROOT_DIR/Application/build.gradle"
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
PORTRAIT_LAYOUT="$ROOT_DIR/Application/src/main/res/layout/fragment_camera2_basic.xml"
LANDSCAPE_LAYOUT="$ROOT_DIR/Application/src/main/res/layout-land/fragment_camera2_basic.xml"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"

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
distributionSha256Sum=1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab
distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip
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
  "gradlew" \
  "gradlew.bat" \
  "gradle/wrapper/gradle-wrapper.properties" \
  "gradle/wrapper/gradle-wrapper.jar" \
  "settings.gradle" \
  "Application/build.gradle" \
  "Application/src/main/AndroidManifest.xml" \
  "Application/src/main/res/layout/fragment_camera2_basic.xml" \
  "Application/src/main/res/layout-land/fragment_camera2_basic.xml" \
  "Application/tests/AndroidManifest.xml" \
  "Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java" \
  "Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java"; do
  require_file "$path"
done

if [ "$(grep -Fc 'android:layout_gravity="center_vertical|end"' "$PORTRAIT_LAYOUT")" -ne 1 ] || \
   grep -Fq 'android:layout_gravity="center_vertical|right"' "$PORTRAIT_LAYOUT"; then
  printf '%s\n' "Portrait camera controls must use logical end-side gravity." >&2
  exit 1
fi

if [ "$(grep -Fc 'android:layout_toEndOf="@id/texture"' "$LANDSCAPE_LAYOUT")" -ne 1 ] || \
   grep -Fq 'android:layout_toRightOf="@id/texture"' "$LANDSCAPE_LAYOUT"; then
  printf '%s\n' "Landscape camera controls must use logical end-side positioning." >&2
  exit 1
fi

if [ "$(grep -Fc 'android:supportsRtl="true"' "$MANIFEST")" -ne 1 ]; then
  printf '%s\n' "Application manifest must explicitly enable RTL resource mirroring." >&2
  exit 1
fi

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
  printf '%s\n' "Generated wrapper must retain the reviewed Gradle 2.2.1 URL and checksum." >&2
  exit 1
fi

require_sha256 "$GRADLEW" "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" "Unix wrapper must match the reviewed generated script."
require_sha256 "$GRADLEW_BAT" "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" "Windows wrapper must match the reviewed generated script."
require_sha256 "$WRAPPER_JAR" "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" "Wrapper JAR must match Gradle's published 8.14.5 checksum."
require_sha256 "$WRAPPER_PROPERTIES" "42874592f15508aa0a9135568ad3f9705b5f35bf987591bc73dd428f2250de5d" "Wrapper properties must match the reviewed checksum contract."

if [ ! -f "$WRAPPER_PLAN" ] || ! grep -Fq "status: completed" "$WRAPPER_PLAN" || \
   ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || \
   ! grep -Fq "incorrect checksum was rejected" "$WRAPPER_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq "external working directory" "$WRAPPER_PLAN" || \
   ! grep -Fq "hostile mutations rejected" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq "classpath 'com.android.tools.build:gradle:1.0.0'" "$APP_BUILD"; then
  printf '%s\n' "Android Gradle plugin 1.0.0 pin must remain explicit." >&2
  exit 1
fi

for repo in "https://repo1.maven.org/maven2" "https://dl.google.com/dl/android/maven2"; do
  if ! grep -Fq "$repo" "$APP_BUILD"; then
    printf '%s\n' "Application build must include repository: $repo" >&2
    exit 1
  fi
done

if grep -Fq "jcenter()" "$APP_BUILD"; then
  printf '%s\n' "Application build must not use JCenter." >&2
  exit 1
fi

if grep -Fq "com.google.android:support-v4" "$APP_BUILD"; then
  printf '%s\n' "Obsolete com.google.android support-v4 artifact must not be declared with Android support-v4." >&2
  exit 1
fi

if ! grep -Fq 'compile "com.android.support:support-v4:21.0.2"' "$APP_BUILD"; then
  printf '%s\n' "Android support-v4 21.0.2 dependency must remain explicit." >&2
  exit 1
fi

for dep in \
  'compile "com.android.support:support-v13:21.0.2"' \
  'compile "com.android.support:cardview-v7:21.0.2"'; do
  if ! grep -Fq "$dep" "$APP_BUILD"; then
    printf '%s\n' "Missing support dependency: $dep" >&2
    exit 1
  fi
done

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$APP_BUILD"; then
  printf '%s\n' "Application build must use the installed build-tools 24.0.3 baseline." >&2
  exit 1
fi

if ! grep -Fq "disable 'LintError'" "$APP_BUILD"; then
  printf '%s\n' "Legacy lint must suppress only the missing API database infrastructure issue." >&2
  exit 1
fi

if ! grep -Fq "compileSdkVersion 21" "$APP_BUILD"; then
  printf '%s\n' "compileSdkVersion 21 must remain explicit." >&2
  exit 1
fi

if ! grep -Fq "minSdkVersion 21" "$APP_BUILD"; then
  printf '%s\n' "minSdkVersion 21 must remain explicit." >&2
  exit 1
fi

if ! grep -Fq "targetSdkVersion 21" "$APP_BUILD"; then
  printf '%s\n' "targetSdkVersion 21 must remain explicit." >&2
  exit 1
fi

if ! grep -Fq "android.permission.CAMERA" "$MANIFEST"; then
  printf '%s\n' "Camera permission must remain declared." >&2
  exit 1
fi

if ! grep -Fq 'android:allowBackup="false"' "$MANIFEST"; then
  printf '%s\n' "CameraApp backup must stay disabled for captured camera state." >&2
  exit 1
fi

if ! grep -Fq 'package="com.example.android.camera2basic"' "$MANIFEST"; then
  printf '%s\n' "Manifest package must remain com.example.android.camera2basic." >&2
  exit 1
fi

if [ "$(grep -c '^<?xml' "$TEST_MANIFEST")" -ne 1 ]; then
  printf '%s\n' "Instrumentation manifest must contain exactly one XML declaration." >&2
  exit 1
fi

if grep -Fq "getSupportFragmentManager()" "$TEST_FIXTURE"; then
  printf '%s\n' "Instrumentation fixture must use platform fragments." >&2
  exit 1
fi

if ! grep -Fq "getFragmentManager().findFragmentById(R.id.container)" "$TEST_FIXTURE"; then
  printf '%s\n' "Instrumentation fixture must locate the platform fragment by container ID." >&2
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

if ! grep -Fq 'ANDROID_HOME: ""' "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq 'ANDROID_SDK_ROOT: ""' "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions must clear hosted Android SDK variables for the legacy SDK-free baseline." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$ROOT_DIR/.github/workflows/check.yml" ||
  ! grep -Fq "timeout-minutes: 5" "$ROOT_DIR/.github/workflows/check.yml"; then
  printf '%s\n' "GitHub Actions check workflow must support bounded manual verification." >&2
  exit 1
fi

if [ "$(grep -Ec '^[[:space:]]*permissions:' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Ec '^[[:space:]]+contents:[[:space:]]*read[[:space:]]*$' "$CI_WORKFLOW")" -ne 1 ] || \
   grep -Eq 'write-all|:[[:space:]]*write|continue-on-error:[[:space:]]*true|if:[[:space:]]*false' "$CI_WORKFLOW" || \
   [ "$(grep -Ec '^[[:space:]]*(-[[:space:]]+)?run:' "$CI_WORKFLOW")" -ne 1 ]; then
  printf '%s\n' "Check workflow must keep exact read-only permissions and one required command." >&2
  exit 1
fi

if ! grep -Fq "distributionSha256Sum" "$README" || \
   ! grep -Fq "does not persist checkout credentials" "$README" || \
   ! grep -Fq "generated Gradle 8.14.5 bootstrap" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "checksum-verified direct wrapper" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "authenticated Gradle wrapper" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Documentation must describe authenticated wrapper and checkout boundaries." >&2
  exit 1
fi

if ! grep -Fq "local.properties" "$README"; then
  printf '%s\n' "README must document local SDK configuration." >&2
  exit 1
fi

if ! grep -Fq "Android Build Tools v24.0.3" "$README"; then
  printf '%s\n' "README must document the build-tools baseline." >&2
  exit 1
fi

if ! grep -Fq "LintError" "$README"; then
  printf '%s\n' "README must document the scoped legacy lint suppression." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint --no-daemon" "$README"; then
  printf '%s\n' "README must document the lint gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew assembleDebug --no-daemon" "$README"; then
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

if [ "$(grep -Fc '$(GRADLE_COMMAND) -p "$(ROOT)"' "$ROOT_DIR/Makefile")" -ne 2 ]; then
  printf '%s\n' "Makefile must root both lint and build Gradle tasks." >&2
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
