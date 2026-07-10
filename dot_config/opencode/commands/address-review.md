---
description: Address review feedback.
agent: build
subtask: true
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read artifact `review.md` and
address actionable findings one by one without widening scope. Run relevant
validation; use `@executor` only for noisy/long checks. Then
mark each finding in `review.md` as `Addressed` or `Not Addressed`, with brief
rationale for anything unresolved. Finish with changed files and whether another
review pass is recommended.
