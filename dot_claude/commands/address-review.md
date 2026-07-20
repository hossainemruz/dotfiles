---
description: Address the latest PR review findings
---

Run only on explicit user invocation after `/review-pr`. Run `taskctl context`;
require `review.md` to identify the current PR/branch and contain actionable
findings. Run `taskctl step get` and require the single corrective Step created
by `/review-pr`; run `taskctl step start` if pending, continue if in progress,
or, if ready, apply explicit feedback via `taskctl step revise` and continue;
otherwise stop for `/accept-step`.

Treat `review.md` as the PR-wide scope. Address every actionable finding,
validate affected behavior, self-review, and fix issues. Do not edit
`review.md`, map findings to original Steps, or use a separate reviewer. Run
`taskctl step submit` when ready; never complete it without acceptance.

Return findings addressed, files, validation, status, then `/accept-step` and
`/review-pr`.
