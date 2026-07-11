---
description: Review current changes against the active plan sub-task.
agent: reviewer
subtask: true
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Review current branch changes
against the default/agreed base using `plan.md` and optional `research.md`.
Require exactly one sub-task marked `In Progress`. If none or multiple are
marked `In Progress`, stop and report the status inconsistency without writing
review feedback. Evaluate the diff against the active sub-task's related
requirements, dependencies, scope boundaries, risks, implementation
suggestions, testing guidance, done-when criteria, and selected research approach
when relevant. Check for correctness issues, regressions, duplication, missing
validation, scope creep, and opportunities to simplify. Write feedback to
artifact `review.md`, preserving its existing structure.
