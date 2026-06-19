#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ANDROID_HOME=${ANDROID_HOME:?ANDROID_HOME must point to the Android SDK.}
GRADLE=${GRADLE:-"$ROOT_DIR/gradlew"}
ADB="$ANDROID_HOME/platform-tools/adb"
AVDMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
EMULATOR="$ANDROID_HOME/emulator/emulator"
SYSTEM_IMAGE=${ANDROID_SYSTEM_IMAGE:-system-images;android-36;google_apis;x86_64}
AVD_NAME=cameraapp-ci
EMULATOR_SERIAL=emulator-5554
BOOT_TIMEOUT_SECONDS=${ANDROID_BOOT_TIMEOUT_SECONDS:-180}

for executable in "$ADB" "$AVDMANAGER" "$EMULATOR"; do
    if [ ! -x "$executable" ]; then
        printf '%s\n' "Required Android runtime tool is missing: $executable" >&2
        exit 1
    fi
done

run_root=$(mktemp -d "${TMPDIR:-/tmp}/cameraapp-instrumentation.XXXXXX")
export ANDROID_AVD_HOME="$run_root/avd"
mkdir -p "$ANDROID_AVD_HOME"

cleanup() {
    "$ADB" -s "$EMULATOR_SERIAL" emu kill >/dev/null 2>&1 || true
    if [ -n "${emulator_pid:-}" ]; then
        kill "$emulator_pid" >/dev/null 2>&1 || true
        wait "$emulator_pid" >/dev/null 2>&1 || true
    fi
    rm -rf -- "$run_root"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

printf 'no\n' | "$AVDMANAGER" create avd \
    --force \
    --name "$AVD_NAME" \
    --package "$SYSTEM_IMAGE"

"$EMULATOR" \
    -avd "$AVD_NAME" \
    -port 5554 \
    -no-window \
    -no-audio \
    -no-boot-anim \
    -no-snapshot \
    -gpu swiftshader_indirect >"$run_root/emulator.log" 2>&1 &
emulator_pid=$!

started_at=$(date +%s)
while :; do
    if ! kill -0 "$emulator_pid" 2>/dev/null; then
        printf '%s\n' "Android emulator exited before boot completed." >&2
        cat "$run_root/emulator.log" >&2
        exit 1
    fi

    device_state=$("$ADB" -s "$EMULATOR_SERIAL" get-state 2>/dev/null || true)
    boot_completed=""
    if [ "$device_state" = "device" ]; then
        boot_completed=$("$ADB" -s "$EMULATOR_SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    fi
    if [ "$boot_completed" = "1" ]; then
        break
    fi

    now=$(date +%s)
    if [ $((now - started_at)) -ge "$BOOT_TIMEOUT_SECONDS" ]; then
        printf '%s\n' "Android emulator did not boot within ${BOOT_TIMEOUT_SECONDS} seconds." >&2
        cat "$run_root/emulator.log" >&2
        exit 1
    fi
    sleep 2
done

"$ADB" -s "$EMULATOR_SERIAL" shell settings put global window_animation_scale 0
"$ADB" -s "$EMULATOR_SERIAL" shell settings put global transition_animation_scale 0
"$ADB" -s "$EMULATOR_SERIAL" shell settings put global animator_duration_scale 0
"$ADB" -s "$EMULATOR_SERIAL" shell input keyevent 82

ANDROID_SERIAL="$EMULATOR_SERIAL" "$GRADLE" -p "$ROOT_DIR" \
    :Application:connectedDebugAndroidTest --no-daemon
