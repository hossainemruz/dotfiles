---
description: Create or refresh the implementation plan from the current task artifact.
agent: planner
subtask: true
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read `task.md` and, when present,
`research.md` from that directory. Create or refresh `plan.md` in the same
directory. You may use `@explore` for focused codebase evidence gathering,
pattern lookup, and similar-implementation discovery, but make the final plan
and approach decisions yourself.
Preserve the existing plan template structure. Treat artifact `task.md` as the
source of truth for scope and acceptance; treat `research.md` as implementation
evidence and recommended approach only. Ask clarifying questions only if missing
information would block a correct plan. If `research.md` is missing and the task
has multiple plausible approaches, architecture risk, or unclear codebase
patterns, recommend running `/research` before planning. Return a compact
summary with:
- plan title
- number of sub-tasks
- research approach used, if any
- any blocking open questions
- recommended next command
