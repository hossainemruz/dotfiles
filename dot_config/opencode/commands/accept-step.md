---
description: Accept the selected Step.
agent: orchestrator
subtask: false
---

This invocation is explicit acceptance. Own the composite workflow in the primary control plane. Run `taskctl pr context` exactly once, require exactly one `ready_for_review` Step, and classify it from that projection as a non-final planned implementation Step, the final planned implementation Step, or the PR-review corrective Step. Reuse this projection for any review handoff; do not run `step context`, `step get`, broad `context`, or a redundant refresh for classification.

For a non-final planned implementation Step, run `taskctl step complete <step-id>` and stop. Never start the next Step here.

For the final planned implementation Step, do not complete it yet. Run `taskctl artifact ensure review` and dispatch exactly one standard `@reviewer` in `remediation-enabled` mode against the full PR while the Step remains ready and the PR remains in progress. On approval, run `taskctl step complete <step-id>`; the derived PR completes, and no corrective Step is created. On actionable findings, verify every finding ID is in `review.md`; run exactly one `taskctl step add --pr <pr-id> --title "Address PR review findings"`, append its exact detailed heading under the PR in `plan.md` referencing every finding ID, and then run `taskctl step complete <accepted-final-step-id>`. Obtain one corrective `taskctl step context`, start it, and automatically run the fresh-builder then verifier-before-submit loop defined by the orchestrator guideline. If review is blocked, report the blocker without changing lifecycle state.

For the corrective Step, require `review.md` to contain mode `verification` and a durable approved verdict matching this Task/PR, branch, and corrective Step. If missing or mismatched, reject acceptance without completing it. Otherwise run `taskctl step complete <step-id>` and stop. Do not dispatch a reviewer or verifier. Report lifecycle, review/remediation result, and any blocker.
