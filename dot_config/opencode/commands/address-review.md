---
description: Address the latest PR review findings.
agent: orchestrator
subtask: false
---

Own this composite workflow in the primary control plane. Run `taskctl step context` exactly once and require the current Step to be the one corrective Step referencing the supplied `review.md`. Retain the complete raw projection and exact Task/PR/Step IDs, branch, requirements, and artifact paths. Treat `$ARGUMENTS` as optional bounded feedback, not permission to omit findings.

For `pending`, run `taskctl step start`; for `in_progress`, continue. For `ready_for_review`, run `taskctl step revise` only with explicit feedback, otherwise stop for `/accept-step`. Dispatch one fresh `@builder` remediation workstream (resume only a known retry/feedback workstream for this same corrective Step) with the full projection, exact context, `review.md` path and every finding, feedback, and validation expectations. If it returns `status: ready_to_submit`, run `taskctl step submit`; if blocked, report the exact blocker. Never complete the Step. Report findings addressed, files, validation, lifecycle status, and the explicit `/accept-step` requirement; acceptance triggers one verification review.
