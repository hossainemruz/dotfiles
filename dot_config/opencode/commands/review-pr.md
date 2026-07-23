---
description: Review the completed current PR.
agent: reviewer
subtask: true
---

Perform the review skill's workflow for the selected Task's branch-associated completed PR. Treat `$ARGUMENTS` as optional review focus; it cannot narrow the required review of the full PR diff against its agreed base. Run `taskctl context`, read the Task artifacts, run `taskctl artifact ensure review`, and record the latest evidence-backed PR-wide review in `review.md` while preserving its template headings and identifying the PR and branch.

If there are actionable findings, add exactly one Step with `taskctl step add --pr <pr-id> --title "Address PR review findings"`, then append that returned Step's exact detailed heading under the PR in `plan.md`, referencing every finding in `review.md`. Add no Step when there are no findings. Do not edit source, begin remediation, or assign findings to original Steps; only the user invokes `/address-review`.

Return validation, verdict, findings, PR/branch, corrective Step, readiness, and next action: `/address-review`, or branch checkout plus `/next-step` if approved.
