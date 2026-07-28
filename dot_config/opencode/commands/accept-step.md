---
description: Accept the selected Step.
agent: workflow
subtask: true
---

This invocation is explicit acceptance. Run exactly this sequence: `taskctl step context` once, require `ready_for_review`, run `taskctl step complete <step-id>`, then run `taskctl context` once to report the next Task-level state. Do not add `taskctl step get`, a pre-completion broad `taskctl context`, or any other refresh when those commands succeed. Do not edit files.

Report updated state and recommend `/next-step`, or `/review-pr` when the PR is complete.
