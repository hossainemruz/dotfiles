---
description: Show selected Task status and next action.
agent: executor
subtask: true
---

Run `taskctl status` and concisely report Task/PR/Step progress, current work, artifacts, skip reasons, vault Git state, and the appropriate next command among `/next-step`, `/accept-step`, `/review-pr`, and user-invoked `/address-review`. Do not modify files or lifecycle state.
