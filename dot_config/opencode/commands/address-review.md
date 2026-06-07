---
description: Address review feedback.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read artifact `review.md` and
address the actionable findings one by one without widening scope
unnecessarily. For any finding that requires code changes, delegate the
implementation to `@build`. After changes are made, ask the `@executor`
subagent to run the relevant validation for the affected code. Then update
artifact `review.md` so each finding is marked `Addressed` or `Not Addressed`,
with a brief rationale for anything intentionally left unresolved. Finish with
a short summary of what changed and whether another review pass is recommended.
