#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
RUNNER="$ROOT_DIR/scripts/run-instrumentation.sh"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/cameraapp-cleanup-test.XXXXXX")
RUNNER_PID=""
WATCHDOG_PID=""
KNOWN_PID_FILES=""

cleanup_test() {
    if [ -n "$WATCHDOG_PID" ]; then
        kill -KILL "$WATCHDOG_PID" >/dev/null 2>&1 || true
        wait "$WATCHDOG_PID" >/dev/null 2>&1 || true
    fi
    if [ -n "$RUNNER_PID" ]; then
        kill -KILL "$RUNNER_PID" >/dev/null 2>&1 || true
        wait "$RUNNER_PID" >/dev/null 2>&1 || true
    fi
    for pid_file in $KNOWN_PID_FILES; do
        kill_pid_file "$pid_file"
    done
    if [ -d "$TEST_ROOT" ]; then
        find "$TEST_ROOT" -name '*.pid' -type f 2>/dev/null | while IFS= read -r pid_file; do
            kill_pid_file "$pid_file"
        done
    fi
    rm -rf -- "$TEST_ROOT"
}
trap cleanup_test 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

kill_pid_file() {
    pid_file=$1
    if [ ! -f "$pid_file" ]; then
        return
    fi
    while IFS= read -r pid; do
        case "$pid" in
            ''|*[!0-9]*)
                continue
                ;;
        esac
        kill -KILL "$pid" >/dev/null 2>&1 || true
    done < "$pid_file"
}

require_compiler() {
    if command -v cc >/dev/null 2>&1; then
        printf '%s\n' cc
        return
    fi
    if command -v clang >/dev/null 2>&1; then
        printf '%s\n' clang
        return
    fi
    if command -v gcc >/dev/null 2>&1; then
        printf '%s\n' gcc
        return
    fi
    printf '%s\n' "A C compiler is required for the emulator cleanup regression test." >&2
    exit 1
}

compile_fake_emulator() {
    compiler=$(require_compiler)
    source_file="$TEST_ROOT/fake-emulator.c"
    binary_file="$TEST_ROOT/fake-emulator"
    cat > "$source_file" <<'EOF'
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile sig_atomic_t term_seen = 0;

static void remember_term(int signo) {
    (void)signo;
    term_seen = 1;
}

static void ignore_signal(int signo) {
    (void)signo;
}

static void write_pid_line(const char *path, pid_t pid, const char *mode) {
    FILE *file;

    if (path == NULL || path[0] == '\0') {
        return;
    }

    file = fopen(path, mode);
    if (file == NULL) {
        perror(path);
        _exit(97);
    }
    fprintf(file, "%ld\n", (long)pid);
    fclose(file);
}

static void daemon_loop(const char *daemon_pid_file) {
    signal(SIGHUP, ignore_signal);
    signal(SIGINT, ignore_signal);
    signal(SIGTERM, ignore_signal);
    write_pid_line(daemon_pid_file, getpid(), "a");

    for (;;) {
        sleep(1);
    }
}

static void spawn_session_daemon(const char *daemon_pid_file) {
    pid_t child = fork();
    if (child < 0) {
        perror("fork");
        _exit(98);
    }
    if (child == 0) {
        pid_t grandchild;

        if (setsid() < 0) {
            perror("setsid");
            _exit(99);
        }

        grandchild = fork();
        if (grandchild < 0) {
            perror("fork");
            _exit(98);
        }
        if (grandchild > 0) {
            _exit(0);
        }

        daemon_loop(daemon_pid_file);
    }
}

static void spawn_session_daemons(const char *daemon_pid_file, int count) {
    int i;

    for (i = 0; i < count; i++) {
        spawn_session_daemon(daemon_pid_file);
    }
}

static int mode_is(const char *mode, const char *expected) {
    return strcmp(mode, expected) == 0;
}

int main(void) {
    const char *mode = getenv("FAKE_EMULATOR_MODE");
    const char *root_pid_file = getenv("FAKE_EMULATOR_PID_FILE");
    const char *daemon_pid_file = getenv("FAKE_DAEMON_PID_FILE");
    int spawned_on_term = 0;

    if (mode == NULL || mode[0] == '\0') {
        mode = "resistant";
    }

    write_pid_line(root_pid_file, getpid(), "w");

    if (mode_is(mode, "already-dead")) {
        return 0;
    }

    if (mode_is(mode, "double-fork-daemon") ||
        mode_is(mode, "fork-race") ||
        mode_is(mode, "resistant-tree")) {
        spawn_session_daemon(daemon_pid_file);
    }
    if (mode_is(mode, "fork-storm")) {
        spawn_session_daemons(daemon_pid_file, 24);
    }

    if (mode_is(mode, "resistant") ||
        mode_is(mode, "resistant-tree") ||
        mode_is(mode, "fork-storm")) {
        signal(SIGHUP, ignore_signal);
        signal(SIGINT, ignore_signal);
        signal(SIGTERM, ignore_signal);
    } else {
        signal(SIGTERM, remember_term);
    }

    for (;;) {
        if (term_seen) {
            if (mode_is(mode, "fork-race") && !spawned_on_term) {
                spawned_on_term = 1;
                spawn_session_daemon(daemon_pid_file);
                term_seen = 0;
                continue;
            }
            return 0;
        }
        while (waitpid(-1, NULL, WNOHANG) > 0) {
        }
        sleep(1);
    }
}
EOF
    "$compiler" -Wall -Wextra -O2 -o "$binary_file" "$source_file"
    printf '%s\n' "$binary_file"
}

FAKE_EMULATOR_BINARY=$(compile_fake_emulator)

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
    *" emu kill")
        if [ -n "${FAKE_ADB_PID_FILE:-}" ]; then
            printf '%s\n' "$$" >> "$FAKE_ADB_PID_FILE"
        fi
        if [ "${FAKE_ADB_SIGNALS_RUNNER:-0}" = "1" ]; then
            kill -TERM "$PPID"
        fi
        case "${FAKE_ADB_EMU_KILL_MODE:-ok}" in
            fail)
                exit 41
                ;;
            hang-ignore-term)
                trap '' TERM INT HUP
                while :; do
                    /bin/sleep 1
                done
                ;;
        esac
        ;;
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
if [ -n "${FAKE_AVDMANAGER_INVOKED_FILE:-}" ]; then
    : > "$FAKE_AVDMANAGER_INVOKED_FILE"
fi
cat >/dev/null
EOF

    cat > "$android_home/emulator/emulator" <<EOF
#!/usr/bin/env sh
if [ -n "\${FAKE_EMULATOR_INVOKED_FILE:-}" ]; then
    : > "\$FAKE_EMULATOR_INVOKED_FILE"
fi
exec "$FAKE_EMULATOR_BINARY"
EOF

    cat > "$case_root/gradle" <<'EOF'
#!/usr/bin/env sh
if [ "${FAKE_GRADLE_STOPS_EMULATOR:-0}" = "1" ]; then
    emulator_pid=$(cat "$FAKE_EMULATOR_PID_FILE")
    kill -KILL "$emulator_pid" >/dev/null 2>&1 || true
    while kill -0 "$emulator_pid" 2>/dev/null; do
        /bin/sleep 1
    done
fi
if [ "${FAKE_GRADLE_SIGNALS_RUNNER:-0}" = "1" ]; then
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

create_fake_sudo() {
    case_root=$1
    cat > "$case_root/sudo" <<'EOF'
#!/usr/bin/env sh
if [ "$1" = "-n" ]; then
    shift
fi
admin=$1
shift
command=$1
shift

if [ "${FAKE_CONTAINMENT_UNAVAILABLE:-0}" = "1" ]; then
    exit 1
fi

numeric_pids_from_file() {
    file=$1
    if [ ! -f "$file" ]; then
        return
    fi
    while IFS= read -r pid; do
        case "$pid" in
            ''|*[!0-9]*)
                continue
                ;;
        esac
        printf '%s\n' "$pid"
    done < "$file"
}

known_pids() {
    cgroup_path=$1
    numeric_pids_from_file "$cgroup_path/cgroup.procs"
    numeric_pids_from_file "${FAKE_DAEMON_PID_FILE:-/nonexistent}"
    numeric_pids_from_file "${FAKE_DECOY_PID_FILE:-/nonexistent}" | sed 's/^/decoy:/'
}

case "$command" in
    create)
        cgroup_path=$1
        mkdir -p "$cgroup_path"
        if [ -n "${FAKE_CGROUP_CREATED_FILE:-}" ]; then
            printf '%s\n' "$cgroup_path" > "$FAKE_CGROUP_CREATED_FILE"
        fi
        : > "$cgroup_path/cgroup.procs"
        : > "$cgroup_path/cgroup.kill"
        printf '%s\n' "populated 0" > "$cgroup_path/cgroup.events"
        if [ "${FAKE_MALFORMED_CGROUP_PIDS:-0}" = "1" ]; then
            {
                printf '%s\n' "not-a-pid"
                printf '%s\n' "-7"
                printf '%s\n' "12x"
            } >> "$cgroup_path/cgroup.procs"
        fi
        ;;
    attach)
        cgroup_path=$1
        pid=$2
        printf '%s\n' "$pid" >> "$cgroup_path/cgroup.procs"
        printf '%s\n' "populated 1" > "$cgroup_path/cgroup.events"
        ;;
    contains)
        cgroup_path=$1
        pid=$2
        grep -Fxq "$pid" "$cgroup_path/cgroup.procs"
        ;;
    term)
        cgroup_path=$1
        known_pids "$cgroup_path" | while IFS= read -r pid; do
            case "$pid" in
                decoy:*)
                    continue
                    ;;
            esac
            kill -TERM "$pid" >/dev/null 2>&1 || true
        done
        ;;
    kill)
        cgroup_path=$1
        if [ "${FAKE_CGROUP_KILL_FAIL:-0}" = "1" ]; then
            exit 1
        fi
        printf '%s\n' 1 > "$cgroup_path/cgroup.kill"
        known_pids "$cgroup_path" | while IFS= read -r pid; do
            case "$pid" in
                decoy:*)
                    continue
                    ;;
            esac
            kill -KILL "$pid" >/dev/null 2>&1 || true
        done
        ;;
    populated)
        cgroup_path=$1
        populated=0
        for pid in $(known_pids "$cgroup_path"); do
            case "$pid" in
                decoy:*)
                    continue
                    ;;
            esac
            if kill -0 "$pid" >/dev/null 2>&1; then
                populated=1
                break
            fi
        done
        [ "$populated" -eq 1 ]
        ;;
    remove)
        cgroup_path=$1
        if [ "${FAKE_CGROUP_REMOVE_FAIL:-0}" = "1" ]; then
            exit 1
        fi
        rm -f "$cgroup_path/cgroup.procs" "$cgroup_path/cgroup.kill" "$cgroup_path/cgroup.events"
        rmdir "$cgroup_path" 2>/dev/null || true
        ;;
    *)
        exec "$admin" "$command" "$@"
        ;;
esac
EOF
    chmod +x "$case_root/sudo"
}

wait_for_pid_file() {
    pid_file=$1
    remaining=10
    while [ ! -s "$pid_file" ] && [ "$remaining" -gt 0 ]; do
        /bin/sleep 1
        remaining=$((remaining - 1))
    done
    [ -s "$pid_file" ]
}

assert_pid_file_dead() {
    case_name=$1
    pid_file=$2
    label=$3

    if [ ! -f "$pid_file" ]; then
        return
    fi

    while IFS= read -r pid; do
        case "$pid" in
            ''|*[!0-9]*)
                continue
                ;;
        esac
        if kill -0 "$pid" 2>/dev/null; then
            printf '%s\n' "$case_name: $label process was left running: $pid." >&2
            return 1
        fi
    done < "$pid_file"
}

assert_recorded_cgroups_removed() {
    case_name=$1
    cgroup_path_file=$2

    if [ ! -f "$cgroup_path_file" ]; then
        return
    fi

    while IFS= read -r cgroup_path; do
        if [ -d "$cgroup_path" ]; then
            printf '%s\n' "$case_name: containment cgroup was not removed: $cgroup_path." >&2
            return 1
        fi
    done < "$cgroup_path_file"
}

run_case() {
    case_name=$1
    fake_mode=$2
    gradle_status=$3
    expected_status=$4
    shutdown_timeout=$5
    case_deadline=$6
    case_root="$TEST_ROOT/$case_name"
    emulator_pid_file="$case_root/emulator.pid"
    daemon_pid_file="$case_root/daemon.pid"
    decoy_pid_file="$case_root/decoy.pid"
    adb_pid_file="$case_root/adb.pid"
    cgroup_path_file="$case_root/cgroup-paths"
    avdmanager_invoked_file="$case_root/avdmanager.invoked"
    emulator_invoked_file="$case_root/emulator.invoked"
    timeout_file="$case_root/timed-out"

    mkdir -p "$case_root"
    create_fake_runtime "$case_root"
    create_fake_sudo "$case_root"

    if [ "${FAKE_REMOVE_ADB:-0}" = "1" ]; then
        rm -f "$case_root/android-sdk/platform-tools/adb"
    fi

    if [ -n "${FAKE_SHARED_CGROUP_ROOT:-}" ]; then
        cgroup_root=$FAKE_SHARED_CGROUP_ROOT
    elif [ "${FAKE_NESTED_CGROUP_ROOT:-0}" = "1" ]; then
        cgroup_root="$case_root/nested/cgroup/root"
    else
        cgroup_root="$case_root/cgroup"
    fi
    mkdir -p "$cgroup_root"
    : > "$cgroup_root/cgroup.controllers"
    : > "$cgroup_root/cgroup.kill"
    KNOWN_PID_FILES="$KNOWN_PID_FILES $emulator_pid_file $daemon_pid_file $decoy_pid_file $adb_pid_file"

    if [ "${FAKE_START_DECOY:-0}" = "1" ]; then
        (trap '' TERM HUP INT; while :; do /bin/sleep 1; done) &
        decoy_pid=$!
        printf '%s\n' "$decoy_pid" > "$decoy_pid_file"
    fi

    FAKE_EMULATOR_MODE="$fake_mode" \
    FAKE_AVDMANAGER_INVOKED_FILE="$avdmanager_invoked_file" \
    FAKE_EMULATOR_PID_FILE="$emulator_pid_file" \
    FAKE_EMULATOR_INVOKED_FILE="$emulator_invoked_file" \
    FAKE_DAEMON_PID_FILE="$daemon_pid_file" \
    FAKE_DECOY_PID_FILE="$decoy_pid_file" \
    FAKE_ADB_PID_FILE="$adb_pid_file" \
    FAKE_CGROUP_CREATED_FILE="$cgroup_path_file" \
    FAKE_GRADLE_STATUS="$gradle_status" \
    FAKE_GRADLE_STOPS_EMULATOR="${FAKE_GRADLE_STOPS_EMULATOR:-0}" \
    FAKE_GRADLE_SIGNALS_RUNNER="${FAKE_GRADLE_SIGNALS_RUNNER:-0}" \
    FAKE_ADB_SIGNALS_RUNNER="${FAKE_ADB_SIGNALS_RUNNER:-0}" \
    FAKE_ADB_EMU_KILL_MODE="${FAKE_ADB_EMU_KILL_MODE:-ok}" \
    FAKE_CONTAINMENT_UNAVAILABLE="${FAKE_CONTAINMENT_UNAVAILABLE:-0}" \
    FAKE_MALFORMED_CGROUP_PIDS="${FAKE_MALFORMED_CGROUP_PIDS:-0}" \
    FAKE_CGROUP_KILL_FAIL="${FAKE_CGROUP_KILL_FAIL:-0}" \
    FAKE_CGROUP_REMOVE_FAIL="${FAKE_CGROUP_REMOVE_FAIL:-0}" \
    SUDO="$case_root/sudo" \
    ANDROID_EMULATOR_CGROUP_ROOT="$cgroup_root" \
    ANDROID_HOME="$case_root/android-sdk" \
    GRADLE="$case_root/gradle" \
    ANDROID_EMULATOR_SHUTDOWN_TIMEOUT_SECONDS="$shutdown_timeout" \
    ANDROID_EMULATOR_HELPER_TIMEOUT_SECONDS=1 \
    ANDROID_EMULATOR_SETUP_HELPER_TIMEOUT_SECONDS=10 \
        "$RUNNER" >"$case_root/runner.out" 2>"$case_root/runner.err" &
    RUNNER_PID=$!

    (
        /bin/sleep "$case_deadline"
        printf '%s\n' timeout > "$timeout_file"
        kill -KILL "$RUNNER_PID" >/dev/null 2>&1 || true
    ) &
    WATCHDOG_PID=$!

    if wait "$RUNNER_PID"; then
        runner_status=0
    else
        runner_status=$?
    fi
    RUNNER_PID=""
    kill -KILL "$WATCHDOG_PID" >/dev/null 2>&1 || true
    wait "$WATCHDOG_PID" >/dev/null 2>&1 || true
    WATCHDOG_PID=""

    if [ -f "$timeout_file" ]; then
        printf '%s\n' \
            "$case_name: instrumentation runner cleanup exceeded ${case_deadline} seconds." >&2
        cat "$case_root/runner.err" >&2
        exit 1
    fi

    if [ "$runner_status" -ne "$expected_status" ]; then
        printf '%s\n' \
            "$case_name: expected status $expected_status, got $runner_status." >&2
        cat "$case_root/runner.err" >&2
        exit 1
    fi

    if [ "${EXPECT_NO_EMULATOR_START:-0}" = "1" ]; then
        if [ -e "$avdmanager_invoked_file" ] || \
           [ -e "$emulator_invoked_file" ] || \
           [ -s "$emulator_pid_file" ]; then
            printf '%s\n' "$case_name: runtime provisioning started despite missing prerequisites." >&2
            exit 1
        fi
        return
    fi

    if [ "$fake_mode" != "already-dead" ]; then
        wait_for_pid_file "$emulator_pid_file" || {
            printf '%s\n' "$case_name: fake emulator did not record its root pid." >&2
            cat "$case_root/runner.err" >&2
            exit 1
        }
    fi

    if [ "${EXPECT_CGROUP_REMAINING:-0}" = "1" ]; then
        return
    fi

    assert_pid_file_dead "$case_name" "$emulator_pid_file" "emulator root" || exit 1
    assert_pid_file_dead "$case_name" "$daemon_pid_file" "emulator daemon" || exit 1
    assert_pid_file_dead "$case_name" "$adb_pid_file" "adb cleanup helper" || exit 1

    assert_recorded_cgroups_removed "$case_name" "$cgroup_path_file" || exit 1

    if [ -f "$decoy_pid_file" ]; then
        decoy_pid=$(cat "$decoy_pid_file")
        if ! kill -0 "$decoy_pid" 2>/dev/null; then
            printf '%s\n' "$case_name: unrelated decoy process was killed." >&2
            exit 1
        fi
        kill -KILL "$decoy_pid" >/dev/null 2>&1 || true
        wait "$decoy_pid" >/dev/null 2>&1 || true
    fi
}

run_concurrent_cgroups() {
    shared_cgroup_root="$TEST_ROOT/concurrent-cgroup-root"
    mkdir -p "$shared_cgroup_root"
    : > "$shared_cgroup_root/cgroup.controllers"
    : > "$shared_cgroup_root/cgroup.kill"

    (
        reset_case_env
        FAKE_SHARED_CGROUP_ROOT="$shared_cgroup_root"
        run_case concurrent-cgroups-a resistant 0 0 1 30
    ) &
    first_pid=$!
    (
        reset_case_env
        FAKE_SHARED_CGROUP_ROOT="$shared_cgroup_root"
        run_case concurrent-cgroups-b double-fork-daemon 0 0 1 30
    ) &
    second_pid=$!

    first_status=0
    second_status=0
    wait "$first_pid" || first_status=$?
    wait "$second_pid" || second_status=$?
    if [ "$first_status" -ne 0 ] || [ "$second_status" -ne 0 ]; then
        printf '%s\n' "concurrent-cgroups: concurrent cleanup failed." >&2
        exit 1
    fi
}

case_selected() {
    case_name=$1
    selected_cases=${CLEANUP_TEST_CASES:-all}
    if [ "$selected_cases" = "all" ]; then
        return 0
    fi
    for selected in $selected_cases; do
        if [ "$selected" = "$case_name" ]; then
            return 0
        fi
    done
    return 1
}

reset_case_env() {
    FAKE_GRADLE_STOPS_EMULATOR=0
    FAKE_GRADLE_SIGNALS_RUNNER=0
    FAKE_ADB_SIGNALS_RUNNER=0
    FAKE_ADB_EMU_KILL_MODE=ok
    FAKE_CONTAINMENT_UNAVAILABLE=0
    FAKE_MALFORMED_CGROUP_PIDS=0
    FAKE_CGROUP_KILL_FAIL=0
    FAKE_CGROUP_REMOVE_FAIL=0
    FAKE_START_DECOY=0
    FAKE_REMOVE_ADB=0
    FAKE_NESTED_CGROUP_ROOT=0
    FAKE_SHARED_CGROUP_ROOT=
    EXPECT_NO_EMULATOR_START=0
    EXPECT_CGROUP_REMAINING=0
}

if case_selected hung-adb-kill; then
    reset_case_env
    FAKE_ADB_EMU_KILL_MODE=hang-ignore-term
    run_case hung-adb-kill resistant 0 0 1 15
fi
if case_selected wall-time-bound; then
    reset_case_env
    FAKE_ADB_EMU_KILL_MODE=hang-ignore-term
    run_case wall-time-bound resistant 0 0 1 15
fi
if case_selected successful-test; then
    reset_case_env
    run_case successful-test resistant 0 0 1 30
fi
if case_selected failed-test; then
    reset_case_env
    run_case failed-test resistant 37 37 1 30
fi
if case_selected already-dead-emulator; then
    reset_case_env
    run_case already-dead-emulator already-dead 0 0 1 30
fi
if case_selected term-signal; then
    reset_case_env
    FAKE_GRADLE_SIGNALS_RUNNER=1
    run_case term-signal resistant 0 143 1 30
fi
if case_selected leading-zero-timeout; then
    reset_case_env
    run_case leading-zero-timeout resistant 0 0 08 34
fi
if case_selected double-fork-setsid; then
    reset_case_env
    run_case double-fork-setsid double-fork-daemon 0 0 1 30
fi
if case_selected resistant-tree; then
    reset_case_env
    run_case resistant-tree resistant-tree 0 0 1 30
fi
if case_selected fork-race; then
    reset_case_env
    run_case fork-race fork-race 0 0 1 30
fi
if case_selected fork-storm; then
    reset_case_env
    run_case fork-storm fork-storm 0 0 1 30
fi
if case_selected unrelated-decoy; then
    reset_case_env
    FAKE_START_DECOY=1
    run_case unrelated-decoy double-fork-daemon 0 0 1 30
fi
if case_selected malformed-cgroup-pids; then
    reset_case_env
    FAKE_MALFORMED_CGROUP_PIDS=1
    run_case malformed-cgroup-pids double-fork-daemon 0 0 1 30
fi
if case_selected missing-containment; then
    reset_case_env
    FAKE_CONTAINMENT_UNAVAILABLE=1
    EXPECT_NO_EMULATOR_START=1
    run_case missing-containment resistant 0 1 1 12
fi
if case_selected failing-adb-kill; then
    reset_case_env
    FAKE_ADB_EMU_KILL_MODE=fail
    run_case failing-adb-kill resistant 0 0 1 30
fi
if case_selected missing-adb; then
    reset_case_env
    FAKE_REMOVE_ADB=1
    EXPECT_NO_EMULATOR_START=1
    run_case missing-adb resistant 0 1 1 12
fi
if case_selected helper-term-resistance; then
    reset_case_env
    FAKE_ADB_EMU_KILL_MODE=hang-ignore-term
    run_case helper-term-resistance resistant 0 0 1 15
fi
if case_selected simultaneous-signals; then
    reset_case_env
    FAKE_GRADLE_SIGNALS_RUNNER=1
    FAKE_ADB_SIGNALS_RUNNER=1
    FAKE_ADB_EMU_KILL_MODE=hang-ignore-term
    run_case simultaneous-signals resistant 0 143 1 15
fi
if case_selected cgroup-kill-failure; then
    reset_case_env
    FAKE_CGROUP_KILL_FAIL=1
    EXPECT_CGROUP_REMAINING=1
    run_case cgroup-kill-failure resistant 0 1 1 30
fi
if case_selected cgroup-removal-failure; then
    reset_case_env
    FAKE_CGROUP_REMOVE_FAIL=1
    EXPECT_CGROUP_REMAINING=1
    run_case cgroup-removal-failure double-fork-daemon 0 1 1 30
fi
if case_selected nested-cgroup-name; then
    reset_case_env
    FAKE_NESTED_CGROUP_ROOT=1
    run_case nested-cgroup-name double-fork-daemon 0 0 1 30
fi
if case_selected concurrent-cgroups; then
    reset_case_env
    run_concurrent_cgroups
fi
printf '%s\n' "Instrumentation runner cleanup regression tests passed."
