---
description: Load and summarize the current Obsidian task artifacts
---

Read `.agent-task` from the current repository. Resolve the task artifact
directory as `$HOME/agent-vault/<contents-of-.agent-task>`. Then inspect the
expected artifact files in that directory:

- `task.md`
- optional `research.md`
- `plan.md`
- `review.md`

Summarize the available task context, including the resolved artifact path and
which expected files are present or missing. Do not scan the rest of
`$HOME/agent-vault` unless explicitly asked.
