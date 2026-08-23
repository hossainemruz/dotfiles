---
description: Create and clarify a Task through Devcroft.
agent: orchestrator
subtask: false
---

Treat `$ARGUMENTS` as the complete initial Task request. Resolve valid repository keys with `devcroft_list_repositories`, create the draft with `devcroft_create_task`, ask only blocking questions with recommendations, and replace the Task's requirements through `devcroft_update_task` once they are executable. Do not plan or edit repository source unless the user explicitly continues with planning.

Return the Task key, clarified objective, repository associations, unresolved blockers, and `/plan` as the next action when requirements are executable.
