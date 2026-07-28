---
description: Address the latest PR review findings.
agent: builder
subtask: true
---

Run after a Task-backed `/review-pr` or `/expert-review` with actionable findings, either by explicit user invocation or automatic orchestrator dispatch. Run `taskctl step context` exactly once and use its projected requirements, PR, corrective Step, and artifact paths as the working contract; do not also run `taskctl context`, `taskctl step get`, or read all of `plan.md` by default. Require `review.md` to identify the current PR/branch and contain actionable findings, and require the single corrective Step created by the review; run `taskctl step start` if pending, continue if in progress, or, if ready, apply explicit feedback via `taskctl step revise` and continue; otherwise stop for `/accept-step`.

Treat `review.md` as the PR-wide scope. Address every actionable finding, validate affected behavior, self-review, and fix issues. Do not edit `review.md`, map findings to original Steps, or use a separate reviewer. Run `taskctl step submit` when ready; when it succeeds, trust its returned state and do not follow it with `taskctl step get` or another context query. Never complete it without acceptance.

Return findings addressed, files, validation, status, then `/accept-step` and `/review-pr`.
