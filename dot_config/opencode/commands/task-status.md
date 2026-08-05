---
description: Show selected Task status and next action.
agent: workflow
subtask: true
---

Run `taskctl status` and concisely report Task/PR/Step progress, current work, artifacts, skip reasons, vault Git state, and applicable next commands among `/next-step`, `/next-step-hard`, `/accept-step`, `/accept-and-go`, `/review-pr`, and `/address-review`. Distinguish normal implementation, the final PR gate, and corrective remediation without restating their protocols. Do not modify files or lifecycle state.
