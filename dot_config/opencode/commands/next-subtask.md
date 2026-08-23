---
description: Implement, validate, and automatically review the next eligible Subtask.
agent: orchestrator
subtask: false
---

Execute the canonical Devcroft Subtask workflow. Treat `$ARGUMENTS` as the exact Task key plus bounded implementation guidance that cannot widen the frozen contract. Transition only the first eligible Subtask to `in_progress`, obtain its `work` context, reconcile that context through `@explore`, obtain any required `@advisor` directive, dispatch `@builder`, validate through `@executor`, and run the standard or risk-triggered expert review and bounded remediation loop. Persist every review through `devcroft_record_review`; on approval, transition to `ready_for_human_review` and obtain `human` context. Stop there, at `blocked`, or at another explicit blocker; never accept or complete the Subtask.
