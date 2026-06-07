---
description: Review current changes against the active plan subtask
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read `plan.md` and, when present, `research.md`. Review the current branch diff
against the active `In Progress` subtask. If none is active, use the subtask most
clearly implemented by the diff and state that assumption.

Check correctness, regressions, scope creep, validation gaps, duplication,
security/reliability risk, simplification, and relevant research consistency.
Write concise, actionable findings/verdict to `review.md`; preserve structure;
no history or repeated context. Do not fix code unless asked.
