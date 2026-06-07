---
description: Create or update the current task artifact
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, and
update `task.md` there while preserving its existing structure. Assume the task
folder/files already exist; do not create them or render template variables
unless explicitly asked.

Interview for goal, requirements, acceptance criteria, out-of-scope items, and
open questions. Use the user's exact language, preserve existing content unless
asked to rewrite, confirm before writing, then summarize and suggest `/plan`.
