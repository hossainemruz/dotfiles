---
description: Run final validation and premium review for the full task.
---

Use `.opencode/task.md` and `.opencode/plan.md` as the source of truth for the intended outcome. First ask the `@executor` subagent to run the smallest final validation that covers the implemented scope. Then ask the `@expert-reviewer` subagent to perform a final in-depth review of the full diff against the base branch using the `code-review` skill and write the result to `.opencode/review.md`.

Return a compact final summary with:
- validation result
- review verdict
- blocking findings, if any
- merge readiness
- any follow-up work that can be deferred
