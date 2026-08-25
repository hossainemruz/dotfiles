---
description: Manually run the standard review loop for the current Subtask.
agent: orchestrator
subtask: false
---

Run the canonical standard workflow review for an exact Task's current implemented and validated Subtask using `@reviewer`. Treat `$ARGUMENTS` as the Task key plus optional focus that cannot narrow the agreed Subtask diff. Obtain `review` context, record the outcome, validation, verdict, and findings through `devcroft_record_review`, and route blocking findings back through the original Builder session, validation, and re-review loop. If Orchestrator implemented directly, it addresses the findings itself. On approval, transition to `ready_for_human_review` and obtain `human` context. Stop there or at `blocked`; never accept or complete the Subtask.
