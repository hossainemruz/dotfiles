---
description: Accept the current Step and implement the next Step.
agent: builder
subtask: true
---

This invocation is both explicit acceptance of the current Step and explicit authorization to start the next planned implementation Step in the same PR.

Run `taskctl step context` exactly once, require the selected Step to be `ready_for_review`, and run `taskctl step complete <step-id>`. Then run `taskctl context` exactly once and use its returned Task/PR state; do not add `taskctl step get` or any other refresh when these commands succeed.

If accepting the Step completed the PR, stop instead of selecting another PR. For a final planned implementation Step, report that the orchestrator must dispatch one standard `remediation-enabled` Task PR review with the returned PR/branch and accepted-Step context. For a PR-review corrective Step, report that it must instead dispatch `@review-verifier` for one `verification` Task PR review with that context. If no next planned Step exists, report the updated state and stop.

Otherwise, run `taskctl step context` exactly once for the newly selected Step and use its projected requirements, PR, Step, and artifact context as the working contract; do not also run `taskctl step get` or read all of `plan.md` by default. If it is the `/review-pr` corrective Step referencing `review.md`, stop and require `/address-review`.

Treat `$ARGUMENTS` as optional feedback or implementation guidance for the new Step; it may clarify the work but cannot widen the Step scope. Require the new Step to be `pending`, run `taskctl step start`, read the relevant artifacts, implement only that Step, validate, self-review the diff, fix issues, and rerun affected checks. Do not use a separate reviewer or `review.md`.

Run `taskctl step submit` when ready; when it succeeds, trust its returned state and do not follow it with `taskctl step get` or another context query. Never complete the new Step without explicit acceptance. Report the accepted Step, new PR/Step, files, validation, self-review, status, and next action.
