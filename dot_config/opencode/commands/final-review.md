---
description: Run final validation and premium review for the full task.
agent: expert-reviewer
subtask: true
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Use artifact `task.md`, optional
`research.md`, and `plan.md` as the source of truth. First run the smallest final
validation covering implemented scope; use `@executor` only for noisy/long checks.
Then review the full diff against base yourself and write artifact `review.md`,
preserving its structure. You may use `@executor` for execution-heavy
validation, but do not delegate review.

Return a compact final summary with:

- validation result
- review verdict
- blocking findings, if any
- merge readiness
- any follow-up work that can be deferred
