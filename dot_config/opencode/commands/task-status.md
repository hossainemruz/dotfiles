---
description: Show an exact Task's status and the one permitted next action.
agent: orchestrator
subtask: false
---

Treat `$ARGUMENTS` as the Task key. If absent, use `devcroft_list_tasks` to identify candidates and ask when ambiguous. Obtain the exact Task's `summary` context without mutating lifecycle state. Report Task and Subtask progress, the active blocker if any, review-attempt budget, current automated approval and validation, pending replanning, and the server's one permitted next action. Do not dispatch a specialist.
