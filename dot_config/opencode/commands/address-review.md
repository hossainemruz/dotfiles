---
description: Address review feedback.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read artifact `review.md` and
address actionable findings one by one without widening scope. Use direct edits
for small known-scope fixes; delegate to `@build` for multi-step or isolation-worthy
fixes. Run relevant validation; use `@executor` only for noisy/long checks. Then
mark each finding in `review.md` as `Addressed` or `Not Addressed`, with brief
rationale for anything unresolved. Finish with changed files and whether another
review pass is recommended.
