---
description: Implement, validate, and automatically review the next eligible Subtask.
agent: orchestrator
subtask: false
---

Execute the canonical Devcroft Subtask workflow. Treat `$ARGUMENTS` as the exact Task key plus bounded implementation guidance that cannot widen the frozen contract. Transition only the first eligible Subtask to `in_progress`, obtain its `work` context, and reconcile that context through `@explore`. Obtain any required precise `@advisor` directive, then implement directly only for genuinely trivial low-risk work or dispatch `@builder` by default, including after Advisor guidance. Dispatch `@builder-high` only when the work meets the exceptional highest-impact system-critical threshold and remains beyond Builder after Advisor guidance. Preserve the selected Builder session for review feedback. Validate through `@executor`, then run standard review by default; use expert review only at the exceptional highest-impact threshold or on explicit user request. Run the bounded feedback loop by resuming the Builder session for revisions. Persist every review through `devcroft_record_review`; on approval, transition to `ready_for_human_review` and obtain `human` context. Stop there, at `blocked`, at a request for explicit replanning authorization, or at another explicit blocker; never accept or complete the Subtask.
