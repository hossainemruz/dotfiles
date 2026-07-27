---
description: Address the latest PR review findings.
agent: builder
subtask: true
---

Run only on explicit user invocation after `/review-pr`. Run `taskctl step context` and use its projected requirements, PR, corrective Step, and artifact paths as the working contract; do not read all of `plan.md` by default. Require `review.md` to identify the current PR/branch and contain actionable findings, and require the single corrective Step created by `/review-pr`; run `taskctl step start` if pending, continue if in progress, or, if ready, apply explicit feedback via `taskctl step revise` and continue; otherwise stop for `/accept-step`.

Treat `review.md` as the PR-wide scope. Address every actionable finding, validate affected behavior, self-review, and fix issues. Do not edit `review.md`, map findings to original Steps, or use a separate reviewer. Run `taskctl step submit` when ready; never complete it without acceptance.

Return findings addressed, files, validation, status, then `/accept-step` and `/review-pr`.
