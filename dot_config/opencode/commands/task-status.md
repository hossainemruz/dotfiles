---
description: Show selected Task status and next action.
agent: workflow
subtask: true
---

Run `taskctl status` and concisely report Task/PR/Step progress, current work, artifacts, skip reasons, vault Git state, and the appropriate next command among `/next-step`, `/accept-step`, `/review-pr`, and `/address-review`. Distinguish the deferred final-Step `remediation-enabled` review, automatic corrective builder remediation, and pre-submission verification. Remaining verification findings return automatically to the same corrective builder workstream; a ready corrective Step requires matching durable verification approval before `/accept-step`. Do not modify files or lifecycle state.
