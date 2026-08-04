---
description: Select the next PR and implement its next Step.
agent: orchestrator
subtask: false
---

Own this composite workflow in the primary control plane. Run `taskctl context`:

- Active `in_progress` PR: use it.
- No current PR: select the first pending PR from `taskctl pr list --json` and run `taskctl pr start <pr-id>` on the current named, non-default branch; if no PR is pending, report no planned work.
- Completed current PR: identify the first pending PR, ask the user to switch to its branch, and stop. If none remains, report no planned work.

Never manage Git branches. Once the current PR is established, run `taskctl step context` exactly once; retain its complete raw output and exact Task/PR/Step IDs and artifact paths. Do not also run `taskctl step get` or read all of `plan.md` by default. Step IDs are Task-wide. If this is the PR-review corrective Step, stop and require `/address-review`.

Treat `$ARGUMENTS` as optional feedback or implementation guidance; it may clarify but cannot widen the Step. For `pending`, run `taskctl step start`; for `in_progress`, continue. For `ready_for_review`, run `taskctl step revise` only when explicit feedback is supplied, otherwise stop for `/accept-step`.

Dispatch one fresh `@builder` workstream for this Step (resume only a known retry/feedback workstream for this same Step). Pass the complete raw projection, exact IDs, artifact paths, requirements, `$ARGUMENTS`, validation expectations, and relevant working-tree context. If it returns `status: ready_to_submit`, run `taskctl step submit` and trust successful output without refreshing. If blocked, report the exact blocker. Never complete without explicit acceptance. Report PR/Step, files, validation, self-review, lifecycle status, and next action.
