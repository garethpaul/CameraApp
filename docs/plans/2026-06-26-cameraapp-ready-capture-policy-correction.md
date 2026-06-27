# CameraApp Ready Capture Policy Correction

Status: Completed
Date: 2026-06-26

## Context

The first ready-capture bootstrap correctly authorized nine exact files, but
its `CHANGES.md` and baseline-checker templates were built from the
pre-bootstrap tree. Applying them would have reverted the newly merged policy
evidence and expected-template inventory, causing normal verification to fail.
The semantic child was not pushed.

## Correction

- Rebuild the two overlapping templates from the merged trusted base.
- Retain both bootstrap records and all current trusted-inventory checks in the
  candidate `CHANGES.md` and baseline checker.
- Add only the ready-capture implementation entry and state-machine contract on
  top of those base-owned bytes.
- Update only their policy digests; keep the other seven reviewed templates
  unchanged.

## Rollout

1. Merge this correction after ordinary hosted checks and exact-head review.
2. Apply the corrected exact nine-file synthetic semantic child as one direct child
   of the corrected default branch.
3. Require the base-owned protected environment, API 36 checks, CodeQL, and
   exact-head review before implementation merge.

## Verification

- All 8 trusted verifier tests accept the corrected synthetic child and retain
  exact-byte mutation rejection for the stale templates.
- Hostile topology, path, mode, size, archive, workflow, and tool-injection
  regressions remain unchanged.
- The SDK-free baseline, policy JSON, shell syntax, and diff hygiene pass.
- `make check` passes Make-authority coverage before the repository's JDK 17
  guard rejects this host's JDK 21 installation.
- The semantic candidate remains unpushed until the correction is merged.
