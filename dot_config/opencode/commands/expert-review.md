---
description: Perform a premium in-depth review.
agent: orchestrator
subtask: false
---

Own this composite workflow in the primary control plane. Treat `$ARGUMENTS` as optional review scope or focus; focus cannot omit relevant changed code. Support either a Task-backed completed PR or an unrelated caller-provided scope. For an unrelated review with no usable scope, ask instead of scanning broadly or invoking `taskctl`.

For a Task-backed review, run `taskctl pr context`, require a branch-associated completed current PR, and run `taskctl artifact ensure review`. Dispatch `@expert-reviewer` with the complete raw projection, `remediation-enabled` mode, exact Task/PR IDs and branch, full-PR scope/base, ensured `review.md` path, requirements, validation expectations, and focus. If actionable findings return, perform the same exactly-one corrective-Step setup, fresh remediation-builder dispatch, and submit-on-readiness flow as `/review-pr`; create no Step on approval.

For an ad hoc review, dispatch `@expert-reviewer` with the concrete scope/base, requirements, and validation expectations and no Task context. On actionable findings, dispatch one bounded fresh `@builder` with all findings and no Task lifecycle work; on approval, dispatch nothing. The reviewer never edits source or creates lifecycle state.
