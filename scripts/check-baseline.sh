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

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".gitignore" \
  "README.md" \
  "docs/plans/2026-06-08-cameraapp-build-hygiene-baseline.md" \
  "gradlew" \
  "gradle/wrapper/gradle-wrapper.properties" \
  "settings.gradle" \
  "Application/build.gradle" \
  "Application/src/main/AndroidManifest.xml" \
  "Application/tests/AndroidManifest.xml" \
  "Application/tests/src/com/example/android/camera2basic/tests/SampleTests.java" \
  "Application/src/main/java/com/example/android/camera2basic/Camera2BasicFragment.java"; do
  require_file "$path"
done

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

if ! grep -Fq "distributionUrl=https\\://services.gradle.org/distributions/gradle-2.2.1-all.zip" "$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"; then
  printf '%s\n' "Gradle wrapper must keep the legacy 2.2.1 distribution pin." >&2
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

if ! grep -Fq "mBackgroundThread == null" "$FRAGMENT"; then
  printf '%s\n' "Background thread shutdown must be null-safe." >&2
  exit 1
fi

if ! grep -Fq "mCameraDevice == null || mCaptureSession == null" "$FRAGMENT"; then
  printf '%s\n' "takePicture must guard unavailable camera session state." >&2
  exit 1
fi

if ! grep -Fq "mImage == null || mFile == null" "$FRAGMENT"; then
  printf '%s\n' "ImageSaver must guard missing image/file state." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$README"; then
  printf '%s\n' "README must document the baseline guard." >&2
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

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed once the baseline is implemented." >&2
  exit 1
fi

printf '%s\n' "CameraApp build hygiene baseline checks passed."
