---
description: Clarify and refine an exact Task's requirements.
agent: orchestrator
subtask: false
---

Treat `$ARGUMENTS` as the Task key plus requested refinements or context. If the key is absent, use `devcroft_list_tasks` to identify candidates and ask when ambiguous. Obtain `planning` context, evaluate the request against the objective, acceptance criteria, constraints, non-goals, and durable decisions, ask the smallest batch of blocking questions with recommendations, then send one complete requirements replacement through `devcroft_update_task` without silently expanding scope. Do not mutate Subtask state or edit repository source.

Return Task key and title, requirements changes, blockers, and the server's next action.
