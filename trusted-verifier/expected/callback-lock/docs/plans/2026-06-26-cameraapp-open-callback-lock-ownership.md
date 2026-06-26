# CameraApp Open Callback Lock Ownership

Status: Completed
Date: 2026-06-26

## Problem

`openCamera` transfers one semaphore permit to the asynchronous
`CameraDevice.StateCallback`, but every opened, disconnected, and error callback
currently releases it. A device can open successfully and later disconnect or
error, so the later callback adds an extra permit and weakens camera open/close
serialization.

## Decision

- Represent pending callback release ownership with one `AtomicBoolean`.
- Transfer that ownership immediately before `CameraManager.openCamera`.
- Let only the first opened, disconnected, or error callback consume and
  release the permit.
- Clear callback ownership before the synchronous-failure path releases its
  still-owned permit.
- Preserve callback-owned device closure and stale shared-device guards.

## Verification

- Add RED SDK-free contracts for the ownership token, callback helper, callback
  ordering, and synchronous-failure cleanup.
- Reject isolated mutations that restore direct callback releases, omit a
  callback helper call, weaken atomic consumption, or retain callback ownership
  during synchronous failure.
- Run `scripts/check-baseline.sh`, root and external-directory `make check`,
  `git diff --check`, hosted API 36 checks, CodeQL, and exact-head review.
- No emulator, physical camera, or live post-open disconnect/error callback is
  available locally; runtime lifecycle confirmation remains in the device
  verification matrix.

## Trusted Rollout

1. Prepare the reviewed eight-file semantic repair.
2. Merge a base-owned trusted-policy bootstrap authorizing those exact bytes.
3. Rebase the semantic repair as one direct child of the new default branch.
4. Merge only the exact green semantic head accepted by the protected trusted
   environment.

## Results

- RED: the source baseline rejected the missing atomic callback ownership
  token before implementation.
- `scripts/check-baseline.sh` passes with exact ordering and one-shot ownership
  contracts.
- Four isolated ownership mutations were rejected.
- Root/external Make, hosted API 36, CodeQL, protected trusted-verifier, and
  exact-head Codex review evidence remain required before merge.
