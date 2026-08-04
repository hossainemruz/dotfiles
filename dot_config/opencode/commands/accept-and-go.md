---
description: Accept the current Step and continue when the lifecycle allows it.
agent: orchestrator
subtask: false
---

This invocation is explicit acceptance of the current Step and, only for a non-final planned implementation Step, explicit authorization to start the next planned Step in the same PR. Own the whole composite workflow in the primary control plane.

Run `taskctl pr context` exactly once, require exactly one `ready_for_review` Step, and classify it as non-final planned implementation, final planned implementation, or PR-review corrective. Reuse this projection for the final-Step review handoff; do not add `step get`, broad `context`, or a redundant refresh.

For a final planned implementation Step, run the same deferred full-PR review gate and conditional corrective builder-to-verifier flow as `/accept-step`; never start more planned work. For a corrective Step, require the same durable matching verifier approval as `/accept-step`, run `taskctl step complete <step-id>`, and stop without another review or verification.

For a non-final planned implementation Step, run `taskctl step complete <step-id>` and then run `taskctl step context` exactly once for the newly selected planned Step. Retain its complete raw output, exact IDs, and artifact paths; do not also run `taskctl step get`, broad `context`, or read all of `plan.md` by default.

Treat `$ARGUMENTS` as optional feedback or implementation guidance for the new Step; it may clarify but cannot widen scope. Require `pending`, run `taskctl step start`, then dispatch one fresh normal `@builder` with the complete raw projection, exact IDs, artifact paths, requirements, `$ARGUMENTS`, validation expectations, and relevant working-tree context.

Only if the builder returns `status: ready_to_submit`, run `taskctl step submit` and trust successful output without refreshing. On `blocked`, report the exact blocker. Never complete the new Step without explicit acceptance. Report the accepted Step, new PR/Step, files, validation, self-review, status, and next action.
