#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
MAKEFILE=$ROOT/Makefile
MAKE_BIN=${MAKE_BIN:-/usr/bin/make}
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

(cd "$CONTROL_DIR" && CAMERAAPP_COMMAND_LOG="$LOG" "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/build.out"
grep -Fq "gradle:-p $ROOT :Application:assembleDebug --no-daemon" "$LOG"

(cd "$CONTROL_DIR" && CAMERAAPP_COMMAND_LOG="$LOG" "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" \
  SKIP_ANDROID_INSTRUMENTATION=1 test) > "$TEMP_ROOT/test.out"
grep -Fq "gradle:-p $ROOT :Application:assembleDebugAndroidTest --no-daemon" "$LOG"
grep -Fq 'instrumentation APK assembled but runtime execution skipped' "$TEMP_ROOT/test.out"

for variable in ANDROID_HOME GRADLE JAVA_HOME SKIP_ANDROID_INSTRUMENTATION; do
  if (cd "$CONTROL_DIR" && "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
    "$variable=\$(shell false)" build) > "$TEMP_ROOT/syntax.out" 2>&1; then
    exit 1
  fi
  grep -Fq "$variable must be a literal value, not Make syntax" "$TEMP_ROOT/syntax.out"
done

if (cd "$CONTROL_DIR" && "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" \
  SKIP_ANDROID_INSTRUMENTATION=yes build) > "$TEMP_ROOT/skip.out" 2>&1; then
  exit 1
fi
grep -Fq 'SKIP_ANDROID_INSTRUMENTATION must be 0 or 1' "$TEMP_ROOT/skip.out"

STARTUP_MARKER="$TEMP_ROOT/startup.marker"
STARTUP="$TEMP_ROOT/startup.mk"
printf '%s\n' \
  '$(shell /usr/bin/touch "$$CAMERAAPP_STARTUP_MARKER")' \
  '$(error startup file executed)' > "$STARTUP"
if (cd "$CONTROL_DIR" && CAMERAAPP_STARTUP_MARKER="$STARTUP_MARKER" MAKEFILES="$STARTUP" \
  "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/startup.out" 2>&1; then
  exit 1
fi
grep -Eq 'startup file executed|MAKEFILES must be empty' "$TEMP_ROOT/startup.out"
test -f "$STARTUP_MARKER"

RESTORE_MARKER="$TEMP_ROOT/restore.marker"
RESTORE_LATER="$TEMP_ROOT/later-restore.mk"
printf '%s\n' \
  "build check lint root-test test toolchain verify: MAKEFILE_LIST := $MAKEFILE" \
  'toolchain::' \
  '	@/usr/bin/touch "$$CAMERAAPP_RESTORE_MARKER"' > "$RESTORE_LATER"
(cd "$CONTROL_DIR" && CAMERAAPP_RESTORE_MARKER="$RESTORE_MARKER" "$MAKE_BIN" --no-print-directory \
  -f "$MAKEFILE" -f "$RESTORE_LATER" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" toolchain) > "$TEMP_ROOT/restore.out"
test -f "$RESTORE_MARKER"

BAD_SDK="$TEMP_ROOT/bad sdk"
BAD_JDK="$TEMP_ROOT/bad jdk"
if (cd "$CONTROL_DIR" && "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
  "ANDROID_HOME=$BAD_SDK" "JAVA_HOME=$BAD_JDK" "GRADLE=$FAKE_GRADLE" toolchain) > "$TEMP_ROOT/bad-toolchain.out" 2>&1; then
  exit 1
fi
grep -Fq 'JAVA_HOME must point to JDK 17.' "$TEMP_ROOT/bad-toolchain.out"

SHELL_MARKER="$TEMP_ROOT/shell.marker"
FAKE_SHELL="$TEMP_ROOT/fake-shell"
FAKE_SHELL_LOG="$TEMP_ROOT/fake-shell.log"
SHELL_LATER="$TEMP_ROOT/later-shell.mk"
printf '%s\n' \
  '#!/bin/sh' \
  'printf "%s\n" "$*" >> "$CAMERAAPP_FAKE_SHELL_LOG"' \
  '/usr/bin/touch "$CAMERAAPP_SHELL_MARKER"' \
  "printf '%s\n' ok" \
  'exit 0' > "$FAKE_SHELL"
chmod +x "$FAKE_SHELL"
printf '%s\n' \
  "build check lint root-test test toolchain verify: MAKEFILE_LIST := $MAKEFILE" \
  "build check lint root-test test toolchain verify: override SHELL := $FAKE_SHELL" \
  'build check lint root-test test toolchain verify: override .SHELLFLAGS := -c' > "$SHELL_LATER"
(cd "$CONTROL_DIR" && CAMERAAPP_SHELL_MARKER="$SHELL_MARKER" CAMERAAPP_FAKE_SHELL_LOG="$FAKE_SHELL_LOG" "$MAKE_BIN" --no-print-directory \
  -f "$MAKEFILE" -f "$SHELL_LATER" \
  "ANDROID_HOME=$BAD_SDK" "JAVA_HOME=$BAD_JDK" "GRADLE=$FAKE_GRADLE" check) > "$TEMP_ROOT/shell-override.out"
test -f "$SHELL_MARKER"
grep -Fq 'scripts/test-makefile-root.sh' "$FAKE_SHELL_LOG"
grep -Fq 'scripts/check-baseline.sh' "$FAKE_SHELL_LOG"
grep -Fq 'scripts/run-instrumentation.sh' "$FAKE_SHELL_LOG"
grep -Fq 'ok' "$TEMP_ROOT/shell-override.out"

APPEND_MARKER="$TEMP_ROOT/append.marker"
APPEND_LATER="$TEMP_ROOT/later-append.mk"
printf '%s\n' \
  "build check lint root-test test toolchain verify: MAKEFILE_LIST := $MAKEFILE" \
  'toolchain::' \
  '	@/usr/bin/touch "$$CAMERAAPP_APPEND_MARKER"' > "$APPEND_LATER"
(cd "$CONTROL_DIR" && CAMERAAPP_APPEND_MARKER="$APPEND_MARKER" "$MAKE_BIN" --no-print-directory \
  -f "$MAKEFILE" -f "$APPEND_LATER" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" toolchain) > "$TEMP_ROOT/append.out"
test -f "$APPEND_MARKER"

REJECT_MARKER="$TEMP_ROOT/reject.marker"
REJECT_LATER="$TEMP_ROOT/later-reject.mk"
printf '%s\n' \
  'toolchain::' \
  '	@/usr/bin/touch "$$CAMERAAPP_REJECT_MARKER"' > "$REJECT_LATER"
if (cd "$CONTROL_DIR" && CAMERAAPP_REJECT_MARKER="$REJECT_MARKER" "$MAKE_BIN" --no-print-directory \
  -f "$MAKEFILE" -f "$REJECT_LATER" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" toolchain) > "$TEMP_ROOT/reject-later.out" 2>&1; then
  exit 1
fi
grep -Fq 'repository Makefile must be loaded alone' "$TEMP_ROOT/reject-later.out"
test ! -f "$REJECT_MARKER"

LATER="$TEMP_ROOT/later.mk"
printf 'build::\n\t@printf appended\n' > "$LATER"
if (cd "$CONTROL_DIR" && "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" -f "$LATER" \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/later.out" 2>&1; then
  exit 1
fi
grep -Fq 'repository Makefile must be loaded alone' "$TEMP_ROOT/later.out"

if (cd "$CONTROL_DIR" && "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" MAKEFLAGS=-n \
  "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/flags.out" 2>&1; then
  exit 1
fi
grep -Fq 'MAKEFLAGS must not be overridden' "$TEMP_ROOT/flags.out"

for flag in -n --just-print --dry-run --recon -t --touch -q --question -i --ignore-errors; do
  if (cd "$CONTROL_DIR" && "$MAKE_BIN" "$flag" --no-print-directory -f "$MAKEFILE" \
    "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" build) > "$TEMP_ROOT/mode.out" 2>&1; then
    exit 1
  fi
  grep -Fq 'non-executing or error-ignoring MAKEFLAGS are not supported' "$TEMP_ROOT/mode.out"
done

(cd "$CONTROL_DIR" && CAMERAAPP_COMMAND_LOG="$LOG" "$MAKE_BIN" --no-print-directory -f "$MAKEFILE" \
  SHELL=/bin/false "ANDROID_HOME=$SDK" "JAVA_HOME=$JDK" "GRADLE=$FAKE_GRADLE" toolchain) > "$TEMP_ROOT/shell.out"

printf '%s\n' 'Make authority tests passed: external root, literal toolchain selection, instrumentation skip validation, 4 raw Make-syntax controls, fixed shell, startup parse-time caller boundary, target-specific MAKEFILE_LIST restoration caller boundary, target-specific override shell false-success boundary, later double-colon append caller boundary, marker-backed later Makefile rejection, caller MAKEFLAGS rejection, and 10 unsafe mode rejections'
