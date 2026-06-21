#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
MAKEFILE=$ROOT/Makefile
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cameraapp-make-authority.XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM

CONTROL_DIR="$TEMP_ROOT/control dir"
SDK="$TEMP_ROOT/sdk dir"
JDK="$TEMP_ROOT/jdk dir"
LOG="$TEMP_ROOT/commands.log"
FAKE_GRADLE="$TEMP_ROOT/gradle tool"
mkdir -p "$CONTROL_DIR" "$SDK/platforms/android-36" "$SDK/build-tools/36.1.0" "$JDK/bin"
: > "$SDK/platforms/android-36/android.jar"
printf '%s\n' '#!/bin/sh' 'exit 0' > "$SDK/build-tools/36.1.0/aapt2"
printf '%s\n' '#!/bin/sh' 'printf "%s\n" "    java.specification.version = 17" >&2' > "$JDK/bin/java"
printf '%s\n' '#!/bin/sh' 'printf "gradle:%s\n" "$*" >> "$CAMERAAPP_COMMAND_LOG"' > "$FAKE_GRADLE"
chmod +x "$SDK/build-tools/36.1.0/aapt2" "$JDK/bin/java" "$FAKE_GRADLE"
: > "$LOG"

(cd "$CONTROL_DIR" && CAMERAAPP_COMMAND_LOG="$LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/build.out"
grep -Fq "gradle:-p $ROOT :Application:assembleDebug --no-daemon" "$LOG"

(cd "$CONTROL_DIR" && CAMERAAPP_COMMAND_LOG="$LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" \
  SKIP_ANDROID_INSTRUMENTATION=1 test) > "$TEMP_ROOT/test.out"
grep -Fq "gradle:-p $ROOT :Application:assembleDebugAndroidTest --no-daemon" "$LOG"
grep -Fq 'instrumentation APK assembled but runtime execution skipped' "$TEMP_ROOT/test.out"

for variable in ANDROID_HOME GRADLE JAVA_HOME SKIP_ANDROID_INSTRUMENTATION; do
  if (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory -f "$MAKEFILE" \
    "$variable=\$(shell false)" build) > "$TEMP_ROOT/syntax.out" 2>&1; then
    exit 1
  fi
  grep -Fq "$variable must be a literal value, not Make syntax" "$TEMP_ROOT/syntax.out"
done

if (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" \
  SKIP_ANDROID_INSTRUMENTATION=yes build) > "$TEMP_ROOT/skip.out" 2>&1; then
  exit 1
fi
grep -Fq 'SKIP_ANDROID_INSTRUMENTATION must be 0 or 1' "$TEMP_ROOT/skip.out"

STARTUP="$TEMP_ROOT/startup.mk"
printf '%s\n' '$(error startup file executed)' > "$STARTUP"
if (cd "$CONTROL_DIR" && MAKEFILES="$STARTUP" /usr/bin/make --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/startup.out" 2>&1; then
  exit 1
fi
grep -Eq 'startup file executed|MAKEFILES must be empty' "$TEMP_ROOT/startup.out"

LATER="$TEMP_ROOT/later.mk"
printf 'build::\n\t@printf appended\n' > "$LATER"
if (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory -f "$MAKEFILE" -f "$LATER" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/later.out" 2>&1; then
  exit 1
fi
grep -Fq 'repository Makefile must be loaded alone' "$TEMP_ROOT/later.out"

if (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory -f "$MAKEFILE" MAKEFLAGS=-n \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/flags.out" 2>&1; then
  exit 1
fi
grep -Fq 'MAKEFLAGS must not be overridden' "$TEMP_ROOT/flags.out"

for flag in -n --just-print --dry-run --recon -t --touch -q --question -i --ignore-errors; do
  if (cd "$CONTROL_DIR" && /usr/bin/make "$flag" --no-print-directory -f "$MAKEFILE" \
    "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/mode.out" 2>&1; then
    exit 1
  fi
  grep -Fq 'non-executing or error-ignoring MAKEFLAGS are not supported' "$TEMP_ROOT/mode.out"
done

(cd "$CONTROL_DIR" && CAMERAAPP_COMMAND_LOG="$LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" \
  SHELL=/bin/false "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/shell.out"

printf '%s\n' 'Make authority tests passed: external root, literal toolchain selection, instrumentation skip validation, 4 raw Make-syntax controls, fixed shell, startup-file rejection, later Makefile rejection, caller MAKEFLAGS rejection, and 10 unsafe mode rejections'
