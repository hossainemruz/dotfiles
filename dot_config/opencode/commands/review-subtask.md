---
description: Review current changes against the active plan sub-task.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Review current branch changes
against the default/agreed base using `plan.md` and optional `research.md`. Use
`@reviewer` for non-trivial/risky/behavior-changing diffs; self-review trivial
docs/config-only diffs. Focus on the single sub-task marked `In Progress`; if multiple sub-tasks are marked
`In Progress`, review the one the current changes most clearly implement and
state that assumption in the review. If none is marked `In Progress`, use the
single sub-task that the current changes most clearly implement and state that
assumption in the review. Evaluate the diff against that sub-task's related
requirements, dependencies, scope boundaries, risks, implementation
suggestions, testing guidance, done-when criteria, and selected research approach
when relevant. Check for correctness issues, regressions, duplication, missing
validation, scope creep, and opportunities to simplify. Write feedback to
artifact `review.md`, preserving its existing structure.
