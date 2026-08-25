---
description: Resume review remediation or apply human-requested Subtask changes.
agent: orchestrator
subtask: false
---

Resume an exact Task's current Subtask through the canonical review-feedback loop. Treat `$ARGUMENTS` as the Task key and explicit human feedback when supplied; otherwise obtain the current durable blocking findings from `review` context. Transition the Subtask to `in_progress` with feedback when necessary. If Orchestrator implemented directly, address the feedback directly; otherwise resume the original `@builder` or `@builder-high` session with the findings, current validation, source state, and authoritative context changes. Start a new Builder-high session only when the original session is unavailable or deliberate capability escalation is required. Obtain a precise Advisor directive when a consequential decision is unresolved, validate through `@executor`, and require another risk-selected standard or expert review recorded through Devcroft. Stop at `ready_for_human_review`, `blocked`, or a request for explicit replanning authorization; never complete the Subtask.
