---
description: Accept the selected Step.
agent: workflow
subtask: true
---

This invocation is explicit acceptance. Run exactly this sequence: `taskctl step context` once, require `ready_for_review`, run `taskctl step complete <step-id>`, then run `taskctl context` once to report the next Task-level state. Do not add `taskctl step get`, a pre-completion broad `taskctl context`, or any other refresh when those commands succeed. Do not edit files.

Report the updated state and stop; this command performs lifecycle commands only and must not invoke or dispatch any agent or other workflow action. Never start `/next-step` or `/next-step-hard`. If the accepted final planned implementation Step completed the PR, report that the orchestrator must dispatch one standard `remediation-enabled` Task PR review with the returned PR/branch and Step context. If an accepted PR-review corrective Step returned the PR to completed status, report that it must instead dispatch `@review-verifier` for one `verification` Task PR review with that context. Otherwise state that subsequent action requires a new explicit user command.
