---
description: Accept the current Step and implement the next Step.
agent: orchestrator
subtask: false
---

This invocation is both explicit acceptance of the current Step and explicit authorization to start the next planned implementation Step in the same PR. Own the whole composite workflow in the primary control plane.

Run `taskctl step context` exactly once, require the selected Step to be `ready_for_review`, and run `taskctl step complete <step-id>`. Then run `taskctl context` exactly once and use its returned Task/PR state; do not add `taskctl step get` or any other refresh when these commands succeed.

If accepting the Step completed the PR, do not select more work. For a final planned implementation Step, run the same one `remediation-enabled` review and conditional one-Step remediation workflow as `/accept-step`. For a corrective Step, run the same one-time `verification` workflow. If no next planned Step exists, report the updated state and stop.

Otherwise, run `taskctl step context` exactly once for the newly selected Step and retain its complete raw output, exact IDs, and artifact paths; do not also run `taskctl step get` or read all of `plan.md` by default. If it is the PR-review corrective Step, stop and require `/address-review`.

Treat `$ARGUMENTS` as optional feedback or implementation guidance for the new Step; it may clarify but cannot widen scope. Require `pending`, run `taskctl step start`, then dispatch one fresh normal `@builder` with the complete raw projection, exact IDs, artifact paths, requirements, `$ARGUMENTS`, validation expectations, and relevant working-tree context.

Only if the builder returns `status: ready_to_submit`, run `taskctl step submit` and trust successful output without refreshing. On `blocked`, report the exact blocker. Never complete the new Step without explicit acceptance. Report the accepted Step, new PR/Step, files, validation, self-review, status, and next action.
