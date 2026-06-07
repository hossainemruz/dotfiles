---
description: Review current changes against the active plan subtask
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read `plan.md` and review the current branch diff against the active `In
Progress` subtask. If none is active, use the subtask most clearly implemented
by the diff and state that assumption.

Check correctness, regressions, scope creep, missing validation, duplication,
security/reliability risk, and simplification opportunities. Write actionable
findings and verdict to `review.md`, preserving its structure. Do not fix code
unless explicitly asked.
