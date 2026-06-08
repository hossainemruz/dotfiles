---
description: Implement the next self-contained sub-task from the plan.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read artifact `plan.md` and
select exactly one active sub-task using this order:
1. continue the single sub-task marked `In Progress`
2. otherwise take the first sub-task marked `Pending` and mark it `In Progress`
3. if multiple sub-tasks are marked `In Progress`, stop and ask which one to continue
4. if there is no `In Progress` or `Pending` sub-task, stop and report that the plan has no remaining implementation work

Treat the selected sub-task entry as the full implementation brief. Implement only that sub-task, following its related requirements, dependencies, in-scope and out-of-scope notes, risks, implementation suggestions, testing guidance, and done-when criteria.

After implementation:
1. run the smallest relevant validation; use `@executor` only for noisy/long checks
2. review against the active sub-task; use `@reviewer` for non-trivial/risky/behavior-changing diffs, self-review trivial docs/config diffs
3. fix any issues you agree with
4. rerun relevant validation after fixes
5. update artifact `plan.md` to mark the sub-task `Completed`

Finish with a short summary:
- completed sub-task
- files changed
- validation result
- review verdict
- next pending sub-task, if any
