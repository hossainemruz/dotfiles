---
description: Accept the selected Step.
agent: orchestrator
subtask: false
---

This invocation is explicit acceptance. Own the composite workflow in the primary control plane. Run `taskctl step context` once, require `ready_for_review`, run `taskctl step complete <step-id>`, then run `taskctl context` once for Task-level state. Do not add `taskctl step get`, a pre-completion broad context query, or a redundant refresh.

If the accepted final planned implementation Step completed the PR, prepare and dispatch exactly one `remediation-enabled` Task PR review: run `taskctl pr context`, run `taskctl artifact ensure review`, and pass `@reviewer` the complete raw projection, exact IDs/branch, scope/base, ensured `review.md` path, requirements, validation expectations, and accepted-Step context. If it returns actionable findings, create and dispatch the one corrective Step exactly as defined by the orchestrator guideline; if approved, create no Step.

If the accepted Step was the corrective Step and the PR is completed, prepare the same context/artifact and dispatch exactly one `@review-verifier` in `verification` mode with the accepted corrective-Step context. Verification creates no Step and never auto-remediates. Otherwise stop for an explicit next command; never start another planned Step here. Report lifecycle and any review/remediation result.
