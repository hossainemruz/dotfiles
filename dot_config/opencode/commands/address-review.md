---
description: Address the latest PR review findings.
agent: builder
subtask: true
---

Run the builder guideline's Task PR review-remediation workflow for the current corrective Step, whether explicitly invoked or automatically dispatched. Treat `$ARGUMENTS` as optional bounded context, not permission to omit findings. Return findings addressed, files, validation, and submitted status, then require explicit `/accept-step`; never complete the Step. After acceptance, the orchestrator dispatches `@review-verifier` for one `verification` review.
