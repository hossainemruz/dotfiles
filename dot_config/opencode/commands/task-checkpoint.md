---
description: Append a concise checkpoint to the current plan artifact.
---

Read `.agent-task` and resolve the artifact directory as
`$HOME/agent-vault/<contents-of-.agent-task>`. Add a checkpoint to artifact
`plan.md`, preserving its structure. Use this command for task
progress, selected subtask, status changes, validation progress, and the next
action. Do not add checkpoints to `task.md` or `review.md`; keep detailed
review entries in `review.md` `Review History`.

The checkpoint should include:

- timestamp
- what changed
- validation result or `Not run`
- review result or `Not reviewed`
- next action

Also update the bounded `AGENT_STATUS_START` / `AGENT_STATUS_END` block in
`plan.md` when present. Do not rewrite unrelated sections.
