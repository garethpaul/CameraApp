#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
RUNNER="$ROOT_DIR/scripts/run-instrumentation.sh"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cameraapp-cleanup-test.XXXXXX")
RUNNER_PID=""
EMULATOR_PID_FILE=""

cleanup_test() {
    if [ -n "$RUNNER_PID" ]; then
        kill -KILL "$RUNNER_PID" >/dev/null 2>&1 || true
        wait "$RUNNER_PID" >/dev/null 2>&1 || true
    fi
    if [ -n "$EMULATOR_PID_FILE" ] && [ -f "$EMULATOR_PID_FILE" ]; then
        emulator_pid=$(cat "$EMULATOR_PID_FILE")
        kill -KILL "$emulator_pid" >/dev/null 2>&1 || true
    fi
    rm -rf -- "$TEST_ROOT"
}
trap cleanup_test 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

create_fake_runtime() {
    case_root=$1
    android_home="$case_root/android-sdk"
    mkdir -p \
        "$android_home/platform-tools" \
        "$android_home/cmdline-tools/latest/bin" \
        "$android_home/emulator"

    cat > "$android_home/platform-tools/adb" <<'EOF'
#!/usr/bin/env sh
case "$*" in
    *" get-state")
        printf '%s\n' device
        ;;
    *" shell getprop sys.boot_completed")
        printf '%s\n' 1
        ;;
esac
EOF

    cat > "$android_home/cmdline-tools/latest/bin/avdmanager" <<'EOF'
#!/usr/bin/env sh
cat >/dev/null
EOF

    cat > "$android_home/emulator/emulator" <<'EOF'
#!/usr/bin/env sh
trap '' TERM
printf '%s\n' "$$" > "$FAKE_EMULATOR_PID_FILE"
while :; do
    sleep 1
done
EOF

    cat > "$case_root/gradle" <<'EOF'
#!/usr/bin/env sh
if [ "$FAKE_GRADLE_STOPS_EMULATOR" = "1" ]; then
    emulator_pid=$(cat "$FAKE_EMULATOR_PID_FILE")
    kill -KILL "$emulator_pid"
    while kill -0 "$emulator_pid" 2>/dev/null; do
        sleep 1
    done
fi
if [ "$FAKE_GRADLE_SIGNALS_RUNNER" = "1" ]; then
    kill -TERM "$PPID"
fi
exit "$FAKE_GRADLE_STATUS"
EOF

    chmod +x \
        "$android_home/platform-tools/adb" \
        "$android_home/cmdline-tools/latest/bin/avdmanager" \
        "$android_home/emulator/emulator" \
        "$case_root/gradle"
}

run_case() {
    case_name=$1
    gradle_status=$2
    expected_status=$3
    gradle_stops_emulator=$4
    gradle_signals_runner=$5
    shutdown_timeout=$6
    case_deadline=$7
    case_root="$TEST_ROOT/$case_name"
    mkdir -p "$case_root"
    create_fake_runtime "$case_root"
    EMULATOR_PID_FILE="$case_root/emulator.pid"

    FAKE_EMULATOR_PID_FILE="$EMULATOR_PID_FILE" \
    FAKE_GRADLE_STATUS="$gradle_status" \
    FAKE_GRADLE_STOPS_EMULATOR="$gradle_stops_emulator" \
    FAKE_GRADLE_SIGNALS_RUNNER="$gradle_signals_runner" \
    ANDROID_HOME="$case_root/android-sdk" \
    GRADLE="$case_root/gradle" \
    ANDROID_EMULATOR_SHUTDOWN_TIMEOUT_SECONDS="$shutdown_timeout" \
        "$RUNNER" >"$case_root/runner.out" 2>"$case_root/runner.err" &
    RUNNER_PID=$!

    elapsed=0
    while kill -0 "$RUNNER_PID" 2>/dev/null && [ "$elapsed" -lt "$case_deadline" ]; do
        sleep 1
        elapsed=$((elapsed + 1))
    done

    if kill -0 "$RUNNER_PID" 2>/dev/null; then
        printf '%s\n' \
            "$case_name: instrumentation runner cleanup exceeded ${case_deadline} seconds." >&2
        exit 1
    fi

    if wait "$RUNNER_PID"; then
        runner_status=0
    else
        runner_status=$?
    fi
    RUNNER_PID=""

    if [ "$runner_status" -ne "$expected_status" ]; then
        printf '%s\n' \
            "$case_name: expected status $expected_status, got $runner_status." >&2
        cat "$case_root/runner.err" >&2
        exit 1
    fi

    emulator_pid=$(cat "$EMULATOR_PID_FILE")
    if kill -0 "$emulator_pid" 2>/dev/null; then
        printf '%s\n' "$case_name: emulator process was not reaped." >&2
        exit 1
    fi
}

run_case successful-test 0 0 0 0 1 4
run_case failed-test 37 37 0 0 1 4
run_case already-dead-emulator 0 0 1 0 1 4
run_case term-signal 0 143 0 1 1 4
run_case leading-zero-timeout 0 0 0 0 08 12

printf '%s\n' "Instrumentation runner cleanup regression tests passed."
