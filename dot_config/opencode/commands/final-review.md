---
description: Run final validation and premium review for the full task.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Use artifact `task.md` and
`plan.md` as the source of truth for the intended outcome. First ask the
`@executor` subagent to run the smallest final validation that covers the
implemented scope. Then ask the `@expert-reviewer` subagent to perform a final
in-depth review of the full diff against the base branch itself and write the
result to artifact `review.md`, preserving its structure. The `@expert-reviewer` may use `@executor` for
execution-heavy validation, but should not delegate the review to other
subagents.

Return a compact final summary with:
- validation result
- review verdict
- blocking findings, if any
- merge readiness
- any follow-up work that can be deferred
