---
description: Resume review remediation or apply human-requested Subtask changes.
agent: orchestrator
subtask: false
---

Resume an exact Task's current Subtask through the canonical review-feedback loop. Treat `$ARGUMENTS` as the Task key and explicit human feedback when supplied; otherwise obtain the current durable blocking findings from `review` context. Transition the Subtask to `in_progress` with feedback when necessary. If Orchestrator implemented directly, address the feedback directly; otherwise resume the original `@builder` pool session with the findings, current validation, source state, and authoritative context changes. If that session is unavailable, start a fresh session at the same tier with a complete packet; never promote Builder remediation to builder-sol unless the critical-task threshold is met after Advisor guidance. Obtain a precise Advisor directive when a consequential decision is unresolved, validate through `@executor`, and require another standard review by default. Use expert review only at the exceptional highest-impact threshold or on explicit user request. Record the review through Devcroft and stop at `ready_for_human_review`, `blocked`, or a request for explicit replanning authorization; never complete the Subtask.
