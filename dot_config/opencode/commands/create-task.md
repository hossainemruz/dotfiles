---
description: Create and clarify a Task through the temporary workflow bridge.
agent: orchestrator
subtask: false
---

Treat `$ARGUMENTS` as the initial Task title and request. Execute the canonical Task-creation and requirements-clarification workflow: create the Task through the temporary taskctl bridge, ask only blocking questions with recommendations, and persist executable requirements in `task.md`. Do not plan or edit repository source unless the user explicitly continues with planning.

Return the Task ID, clarified objective, unresolved blockers, and `/plan` as the next action when requirements are executable.
