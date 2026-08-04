---
description: Review the completed current PR.
agent: orchestrator
subtask: false
---

Own this composite workflow in the primary control plane. Run `taskctl pr context` and require a branch-associated completed current PR, then run `taskctl artifact ensure review`. Dispatch `@reviewer` in `remediation-enabled` mode with the complete raw projection, exact Task/PR IDs and branch, full-PR scope and agreed base, ensured `review.md` path, requirements, validation expectations, and `$ARGUMENTS` as optional focus. Focus cannot narrow the full PR review.

If the structured verdict is `approved`, create no Step and report the result. If it is `actionable_findings`, verify all finding IDs are recorded in `review.md`, then run exactly one `taskctl step add --pr <pr-id> --title "Address PR review findings"`. Append the returned exact detailed Step heading under that PR in `plan.md`, referencing every finding in `review.md`. Obtain the narrow corrective `taskctl step context`, run `taskctl step start`, and dispatch one fresh `@builder` with the full corrective-Step projection, exact IDs/artifact paths, `review.md` path, requirements, findings, and validation expectations. Run `taskctl step submit` only on `status: ready_to_submit`; never complete it. On any blocked result, report the exact blocker.
