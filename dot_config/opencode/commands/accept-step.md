---
description: Accept the selected Step.
agent: workflow
subtask: true
---

This invocation is explicit acceptance. Run exactly this sequence: `taskctl step context` once, require `ready_for_review`, run `taskctl step complete <step-id>`, then run `taskctl context` once to report the next Task-level state. Do not add `taskctl step get`, a pre-completion broad `taskctl context`, or any other refresh when those commands succeed. Do not edit files.

Report the updated state and stop; this command performs lifecycle commands only and must not invoke or dispatch any agent or other workflow action. Never start `/next-step` or `/next-step-hard`. If the result says the accepted Step was the final planned implementation Step and completed the PR, or that an accepted PR-review corrective Step returned the PR to completed status, explicitly report that the calling orchestrator must now dispatch exactly one standard `@reviewer` under the full `/review-pr` contract. Otherwise state that any subsequent action requires a new, explicit user command.
