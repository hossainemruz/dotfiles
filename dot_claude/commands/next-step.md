---
description: Select the next PR and implement its next Step
---

Run `taskctl context`:

- Active `in_progress` PR: use it.
- No current PR: select the first pending PR from `taskctl pr list --json` and
  run `taskctl pr start <pr-id>` on the current named, non-default branch; if no
  PR is pending, report no planned work.
- Completed current PR: identify the first pending PR, ask the user to switch to
  its branch, and stop. If none remains, report no planned work.

Never manage Git branches. Run `taskctl step get`; Step IDs are Task-wide. If
the selected Step is the `/review-pr` corrective Step referencing `review.md`,
stop and require the user to invoke `/address-review`.

For `pending`, run `taskctl step start`; for `in_progress`, continue. For
`ready_for_review`, apply explicit feedback via `taskctl step revise`, or
otherwise stop for `/accept-step`. Read the relevant artifacts, implement only
this Step, validate, self-review the diff, fix issues, and rerun affected checks.
Do not use a separate reviewer or `review.md`.

Run `taskctl step submit` when ready; never complete without explicit
acceptance. Report PR/Step, files, validation, self-review, status, and next
action.
