---
description: Address the latest PR review findings.
agent: orchestrator
subtask: false
---

Own this composite workflow in the primary control plane. Run `taskctl step context` exactly once and require the current Step to be the one corrective Step referencing the supplied `review.md`. Retain the complete raw projection and exact Task/PR/Step IDs, branch, requirements, and artifact paths. Treat `$ARGUMENTS` as optional bounded feedback, not permission to omit findings.

For `pending`, run `taskctl step start`; for `in_progress`, continue. For `ready_for_review` with durable matching verification approval in `review.md`, stop for `/accept-step`. For `ready_for_review` without that approval, report the bypass, run `taskctl step revise` to restore `in_progress`, and enter the gate below. For a pending, in-progress, or restored Step, dispatch one fresh `@builder` remediation workstream, or resume only a known workstream for this same corrective Step, with the full projection, any authoritative start/revise result, exact context, `review.md` path and every current finding, feedback, and validation expectations.

When the builder returns `status: ready_to_submit`, keep the Step `in_progress` and immediately dispatch `@review-verifier` in `verification` mode with the builder handoff, full corrective context and diff scope, directly affected context, and `review.md` path. On approval, require the matching durable result in `review.md` and only then run `taskctl step submit`. On remaining findings, do not add a Step or submit; resume the same builder workstream with only those delta findings and repeat verification when ready. Continue until approved or concretely blocked, and report blockers rather than readiness. Never complete the Step. Report findings addressed, files, validation, lifecycle status, and the explicit `/accept-step` requirement.
