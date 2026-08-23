---
description: Explicitly accept the current approved Subtask.
agent: orchestrator
subtask: false
---

This invocation is explicit human acceptance of the one `ready_for_human_review` Subtask for the exact Task key in `$ARGUMENTS` or unambiguous conversation context. Obtain `human` context and require current passing validation, automated approval, and no blocker. If decisions or deviations affect pending work, revise or confirm the pending suffix before acceptance. Then transition the Subtask to `completed` through `devcroft_update_subtask_state`. Never start the next Subtask; report the server's next action.
