# CameraApp Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so permission, preview, capture, and lifecycle evidence cannot
be transferred to a different camera implementation.

## Evidence Rules

- Use a synthetic scene that contains no people, addresses, account data,
  customer material, location clues, or business-sensitive information.
- Record the Android SDK, API level, device or emulator class, camera facing,
  permission state, result, and evidence identifier.
- Do not include device identifiers, captured images, room imagery, account
  names, unrelated notifications, raw diagnostic output, or signing material.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Android SDK / API | `not run` |
| Device or emulator | `not run` |
| Camera facing / capability | `not run` |
| Permission state | `not run` |
| Synthetic scene | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Install and first launch | The exact-head APK installs and opens without stale state or a startup crash. | `not run` | `not run` |
| Camera permission denied | Denial shows bounded guidance and leaves camera resources unopened. | `not run` | `not run` |
| Camera permission granted | Grant resumes camera startup only while the fragment view and texture are active. | `not run` | `not run` |
| Preview startup | A supported camera produces a correctly scaled full-bleed preview with responsive controls. | `not run` | `not run` |
| Unsupported camera | Missing or unsupported Camera2 capability produces bounded recovery without a crash. | `not run` | `not run` |
| Still capture | One capture produces one saved result and generic confirmation without exposing a private path. | `not run` | `not run` |
| Immediately-ready AF/AE capture | AF-unavailable or already-converged AE results submit exactly one still before preview recovery. | `not run` | `not run` |
| Rejected save handoff | A forced background-handler rejection closes the acquired image and later captures remain possible. | `not run` | `not run` |
| Rapid repeated capture | Repeated capture does not exhaust the two-slot ImageReader or duplicate ownership. | `not run` | `not run` |
| Orientation change | Portrait and landscape preserve preview geometry and non-overlapping controls. | `not run` | `not run` |
| Background and resume | Leaving and returning closes and reopens camera ownership without deadlock or stale view access. | `not run` | `not run` |
| Pause during camera open | Pausing while open completion is pending closes the callback-published device and prevents preview work after teardown. | `not run` | `not run` |
| Permission result after view teardown | A delayed result cannot open camera work against a destroyed fragment view. | `not run` | `not run` |
| System bar insets | Target-36 edge-to-edge preview remains full bleed while controls stay inside tappable insets. | `not run` | `not run` |
| Sustained capture | Repeated preview and capture remain responsive without leaked images, threads, or semaphore permits. | `not run` | `not run` |
| Process relaunch | Relaunch starts without stale permission, camera, capture, handler, or output state. | `not run` | `not run` |

## Current Status

No Android emulator, physical camera, permission interaction, live preview,
capture, orientation, or lifecycle scenario was executed for this checklist.
Treat every emulator, camera, permission, preview, capture, and lifecycle row as unexecuted
until evidence is attached to the exact commit.
