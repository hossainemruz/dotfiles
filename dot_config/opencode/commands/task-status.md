---
description: Show selected Task status and next action.
agent: workflow
subtask: true
---

Run `taskctl status` and concisely report Task/PR/Step progress, current work, artifacts, skip reasons, vault Git state, and the appropriate next command among `/next-step`, `/accept-step`, `/review-pr`, and `/address-review`. Distinguish automatic initial `remediation-enabled` review, automatic corrective builder remediation, and the single post-acceptance `verification` review; verification findings require explicit user direction. Do not modify files or lifecycle state.
