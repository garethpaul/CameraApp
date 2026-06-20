#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
ANDROID_HOME=${ANDROID_HOME:?ANDROID_HOME must point to the Android SDK.}
GRADLE=${GRADLE:-"$ROOT_DIR/gradlew"}
ADB="$ANDROID_HOME/platform-tools/adb"
AVDMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
EMULATOR="$ANDROID_HOME/emulator/emulator"
SYSTEM_IMAGE=${ANDROID_SYSTEM_IMAGE:-system-images;android-36;google_apis;x86_64}
AVD_NAME=cameraapp-ci
EMULATOR_SERIAL=emulator-5554
BOOT_TIMEOUT_SECONDS=${ANDROID_BOOT_TIMEOUT_SECONDS:-180}
SHUTDOWN_TIMEOUT_SECONDS=${ANDROID_EMULATOR_SHUTDOWN_TIMEOUT_SECONDS:-10}
HELPER_TIMEOUT_SECONDS=${ANDROID_EMULATOR_HELPER_TIMEOUT_SECONDS:-1}
SETUP_HELPER_TIMEOUT_SECONDS=${ANDROID_EMULATOR_SETUP_HELPER_TIMEOUT_SECONDS:-5}
CGROUP_ROOT=${ANDROID_EMULATOR_CGROUP_ROOT:-/sys/fs/cgroup}
SUDO=${SUDO:-sudo}

find_standard_tool() {
    tool_name=$1
    shift
    for candidate in "$@"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    printf '%s\n' "Required host tool is missing: $tool_name" >&2
    exit 1
}

SLEEP=$(find_standard_tool sleep /bin/sleep /usr/bin/sleep)
RM=$(find_standard_tool rm /bin/rm /usr/bin/rm)

normalize_non_negative_seconds() {
    value_name=$1
    value=$2
    case "$value" in
        ''|*[!0-9]*)
            printf '%s\n' "$value_name must be a non-negative integer." >&2
            exit 1
            ;;
    esac
    while [ "$value" != "0" ] && [ "${value#0}" != "$value" ]; do
        value=${value#0}
    done
    printf '%s\n' "$value"
}

SHUTDOWN_TIMEOUT_SECONDS=$(normalize_non_negative_seconds \
    ANDROID_EMULATOR_SHUTDOWN_TIMEOUT_SECONDS "$SHUTDOWN_TIMEOUT_SECONDS")
HELPER_TIMEOUT_SECONDS=$(normalize_non_negative_seconds \
    ANDROID_EMULATOR_HELPER_TIMEOUT_SECONDS "$HELPER_TIMEOUT_SECONDS")
SETUP_HELPER_TIMEOUT_SECONDS=$(normalize_non_negative_seconds \
    ANDROID_EMULATOR_SETUP_HELPER_TIMEOUT_SECONDS "$SETUP_HELPER_TIMEOUT_SECONDS")

for executable in "$ADB" "$AVDMANAGER" "$EMULATOR"; do
    if [ ! -x "$executable" ]; then
        printf '%s\n' "Required Android runtime tool is missing: $executable" >&2
        exit 1
    fi
done

run_root=$(mktemp -d "${TMPDIR:-/tmp}/cameraapp-instrumentation.XXXXXX")
export ANDROID_AVD_HOME="$run_root/avd"
mkdir -p "$ANDROID_AVD_HOME"
CONTAINMENT_CREATED=0
CONTAINMENT_FAILED=0
BOUND_HELPER_SEQ=0
CGROUP_ADMIN="$run_root/cgroup-admin.sh"
CGROUP_NAME=$(basename "$run_root" | tr -cd 'A-Za-z0-9._-')
CGROUP_NAME="cameraapp-${CGROUP_NAME}-$$"
CGROUP_PATH="$CGROUP_ROOT/$CGROUP_NAME"

cat > "$CGROUP_ADMIN" <<'EOF'
#!/usr/bin/env sh
set -eu

command=$1
shift

is_numeric_pid() {
    case "$1" in
        ''|*[!0-9]*)
            return 1
            ;;
    esac
    [ "$1" -gt 0 ]
}

numeric_pids_from_file() {
    file=$1
    if [ ! -f "$file" ]; then
        return
    fi
    while IFS= read -r pid; do
        if is_numeric_pid "$pid"; then
            printf '%s\n' "$pid"
        fi
    done < "$file"
}

case "$command" in
    create)
        cgroup_path=$1
        mkdir "$cgroup_path"
        if [ ! -f "$cgroup_path/cgroup.procs" ] || \
           [ ! -f "$cgroup_path/cgroup.events" ] || \
           [ ! -f "$cgroup_path/cgroup.kill" ]; then
            rmdir "$cgroup_path" 2>/dev/null || true
            exit 1
        fi
        ;;
    attach)
        cgroup_path=$1
        pid=$2
        is_numeric_pid "$pid"
        printf '%s\n' "$pid" > "$cgroup_path/cgroup.procs"
        ;;
    contains)
        cgroup_path=$1
        pid=$2
        is_numeric_pid "$pid"
        numeric_pids_from_file "$cgroup_path/cgroup.procs" | grep -Fxq "$pid"
        ;;
    term)
        cgroup_path=$1
        numeric_pids_from_file "$cgroup_path/cgroup.procs" | while IFS= read -r pid; do
            kill -TERM "$pid" >/dev/null 2>&1 || true
        done
        ;;
    kill)
        cgroup_path=$1
        printf '%s\n' 1 > "$cgroup_path/cgroup.kill"
        ;;
    populated)
        cgroup_path=$1
        grep -Eq '^populated 1$' "$cgroup_path/cgroup.events"
        ;;
    remove)
        cgroup_path=$1
        rmdir "$cgroup_path"
        ;;
    *)
        exit 2
        ;;
esac
EOF
chmod +x "$CGROUP_ADMIN"

run_bounded_command() {
    timeout_seconds=$1
    shift
    BOUND_HELPER_SEQ=$((BOUND_HELPER_SEQ + 1))
    helper_pid_file="$run_root/helper-${BOUND_HELPER_SEQ}.pid"

    "$@" &
    helper_pid=$!
    printf '%s\n' "$helper_pid" > "$helper_pid_file"

    (
        remaining=$timeout_seconds
        while [ "$remaining" -gt 0 ]; do
            if ! kill -0 "$helper_pid" 2>/dev/null; then
                exit 0
            fi
            "$SLEEP" 1
            remaining=$((remaining - 1))
        done
        if kill -0 "$helper_pid" 2>/dev/null; then
            kill -TERM "$helper_pid" >/dev/null 2>&1 || true
            "$SLEEP" 1
            kill -KILL "$helper_pid" >/dev/null 2>&1 || true
            exit 124
        fi
        exit 0
    ) &
    watchdog_pid=$!

    if wait "$helper_pid"; then
        helper_status=0
    else
        helper_status=$?
    fi
    kill -KILL "$watchdog_pid" >/dev/null 2>&1 || true
    wait "$watchdog_pid" >/dev/null 2>&1 || true
    "$RM" -f -- "$helper_pid_file"
    return "$helper_status"
}

finish_async_bounded_helper() {
    helper_wrapper_pid=$1
    if [ -z "$helper_wrapper_pid" ]; then
        return
    fi

    (
        "$SLEEP" $((HELPER_TIMEOUT_SECONDS + 2))
        kill -KILL "$helper_wrapper_pid" >/dev/null 2>&1 || true
    ) &
    wrapper_watchdog_pid=$!
    wait "$helper_wrapper_pid" >/dev/null 2>&1 || true
    kill -KILL "$wrapper_watchdog_pid" >/dev/null 2>&1 || true
    wait "$wrapper_watchdog_pid" >/dev/null 2>&1 || true
}

run_cgroup_admin_with_timeout() {
    cgroup_helper_timeout=$1
    shift
    if [ -n "$SUDO" ]; then
        run_bounded_command "$cgroup_helper_timeout" "$SUDO" -n "$CGROUP_ADMIN" "$@"
    else
        run_bounded_command "$cgroup_helper_timeout" "$CGROUP_ADMIN" "$@"
    fi
}

run_cgroup_admin() {
    run_cgroup_admin_with_timeout "$HELPER_TIMEOUT_SECONDS" "$@"
}

run_cgroup_admin_setup() {
    run_cgroup_admin_with_timeout "$SETUP_HELPER_TIMEOUT_SECONDS" "$@"
}

fail_missing_containment() {
    printf '%s\n' \
        "Required emulator containment capability is unavailable: writable cgroup v2 with cgroup.kill." >&2
    exit 1
}

prepare_emulator_containment() {
    if [ ! -d "$CGROUP_ROOT" ] || [ ! -f "$CGROUP_ROOT/cgroup.controllers" ]; then
        fail_missing_containment
    fi
    if ! run_cgroup_admin_setup create "$CGROUP_PATH"; then
        fail_missing_containment
    fi
    CONTAINMENT_CREATED=1
}

attach_emulator_to_containment() {
    pid=$1
    if ! run_cgroup_admin_setup attach "$CGROUP_PATH" "$pid" || \
       ! run_cgroup_admin_setup contains "$CGROUP_PATH" "$pid"; then
        CONTAINMENT_FAILED=1
        kill -KILL "$pid" >/dev/null 2>&1 || true
        wait "$pid" >/dev/null 2>&1 || true
        printf '%s\n' "Failed to attach emulator launcher to its containment cgroup." >&2
        exit 1
    fi
}

pid_is_zombie() {
    pid=$1
    state=$(ps -o stat= -p "$pid" 2>/dev/null | awk 'NR == 1 { print $1 }')
    case "$state" in
        Z*)
            return 0
            ;;
    esac
    return 1
}

pid_is_live() {
    pid=$1
    kill -0 "$pid" 2>/dev/null || return 1
    ! pid_is_zombie "$pid"
}

reap_emulator_if_dead() {
    if [ -n "${emulator_pid:-}" ] && ! pid_is_live "$emulator_pid"; then
        wait "$emulator_pid" >/dev/null 2>&1 || true
        emulator_pid=""
    fi
}

containment_populated() {
    [ "$CONTAINMENT_CREATED" -eq 1 ] || return 1
    if run_cgroup_admin populated "$CGROUP_PATH"; then
        return 0
    fi
    status=$?
    if [ "$status" -gt 1 ]; then
        CONTAINMENT_FAILED=1
    fi
    return 1
}

wait_for_containment_empty() {
    remaining=$SHUTDOWN_TIMEOUT_SECONDS
    while :; do
        if ! containment_populated; then
            return 0
        fi
        reap_emulator_if_dead
        if [ "$remaining" -le 0 ]; then
            return 1
        fi
        "$SLEEP" 1
        remaining=$((remaining - 1))
    done
}

signal_containment_term() {
    [ "$CONTAINMENT_CREATED" -eq 1 ] && run_cgroup_admin term "$CGROUP_PATH"
}

kill_containment_unit() {
    [ "$CONTAINMENT_CREATED" -eq 1 ] && run_cgroup_admin kill "$CGROUP_PATH"
}

remove_containment_unit() {
    [ "$CONTAINMENT_CREATED" -eq 1 ] && run_cgroup_admin remove "$CGROUP_PATH"
}

cleanup() {
    cleanup_status=$?
    trap - 0
    trap '' 1 2 15
    adb_cleanup_pid=""
    if [ -x "$ADB" ]; then
        run_bounded_command "$HELPER_TIMEOUT_SECONDS" \
            "$ADB" -s "$EMULATOR_SERIAL" emu kill >/dev/null 2>&1 &
        adb_cleanup_pid=$!
    fi
    if [ "$CONTAINMENT_CREATED" -eq 1 ]; then
        signal_containment_term || CONTAINMENT_FAILED=1
        if ! wait_for_containment_empty; then
            kill_containment_unit || CONTAINMENT_FAILED=1
            wait_for_containment_empty || CONTAINMENT_FAILED=1
        fi
        reap_emulator_if_dead
        remove_containment_unit || CONTAINMENT_FAILED=1
    elif [ -n "${emulator_pid:-}" ]; then
        CONTAINMENT_FAILED=1
        kill -KILL "$emulator_pid" >/dev/null 2>&1 || true
        wait "$emulator_pid" >/dev/null 2>&1 || true
    fi
    finish_async_bounded_helper "$adb_cleanup_pid"
    run_bounded_command "$HELPER_TIMEOUT_SECONDS" "$RM" -rf -- "$run_root" >/dev/null 2>&1 || true
    if [ "$CONTAINMENT_FAILED" -ne 0 ]; then
        printf '%s\n' "Emulator containment cleanup failed." >&2
        exit 1
    fi
    exit "$cleanup_status"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

prepare_emulator_containment

printf 'no\n' | "$AVDMANAGER" create avd \
    --force \
    --name "$AVD_NAME" \
    --package "$SYSTEM_IMAGE"

launcher_fifo="$run_root/emulator.launch"
mkfifo "$launcher_fifo"
(
    IFS= read -r _ < "$launcher_fifo"
    exec "$EMULATOR" \
        -avd "$AVD_NAME" \
        -port 5554 \
        -no-window \
        -no-audio \
        -no-boot-anim \
        -no-snapshot \
        -gpu swiftshader_indirect
) >"$run_root/emulator.log" 2>&1 &
emulator_pid=$!
attach_emulator_to_containment "$emulator_pid"
printf '\n' > "$launcher_fifo"

started_at=$(date +%s)
while :; do
    if ! pid_is_live "$emulator_pid"; then
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
    "$SLEEP" 2
done

"$ADB" -s "$EMULATOR_SERIAL" shell settings put global window_animation_scale 0
"$ADB" -s "$EMULATOR_SERIAL" shell settings put global transition_animation_scale 0
"$ADB" -s "$EMULATOR_SERIAL" shell settings put global animator_duration_scale 0
"$ADB" -s "$EMULATOR_SERIAL" shell input keyevent 82

ANDROID_SERIAL="$EMULATOR_SERIAL" "$GRADLE" -p "$ROOT_DIR" \
    :Application:connectedDebugAndroidTest --no-daemon
