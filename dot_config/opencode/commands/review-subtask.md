---
description: Manually run the standard review loop for the current Subtask.
agent: orchestrator
subtask: false
---

Run the canonical standard workflow review for the current implemented and validated Subtask using `@reviewer`. `$ARGUMENTS` is optional focus and cannot narrow the agreed Subtask diff. Persist the result yourself and automatically route blocking findings through the bounded remediation, validation, and re-review loop. Stop at logical `ready_for_human_review` or `blocked`; never accept or complete the Subtask.
