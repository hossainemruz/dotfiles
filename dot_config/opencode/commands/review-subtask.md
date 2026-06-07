---
description: Review current changes against the active plan sub-task.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Ask the `@reviewer` subagent to
review the current branch changes against the repository's default or agreed
base branch using artifact `plan.md` and, when present, `research.md` as source
context. Focus on the single sub-task marked `In Progress`; if multiple sub-tasks are marked
`In Progress`, review the one the current changes most clearly implement and
state that assumption in the review. If none is marked `In Progress`, use the
single sub-task that the current changes most clearly implement and state that
assumption in the review. Evaluate the diff against that sub-task's related
requirements, dependencies, scope boundaries, risks, implementation
suggestions, testing guidance, done-when criteria, and selected research
approach when relevant. Check for correctness issues, regressions, duplication,
missing validation, scope creep, and opportunities to simplify. Write feedback
to artifact `review.md`, preserving its existing structure.
