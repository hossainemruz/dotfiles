---
description: Review the completed current PR.
agent: expert-reviewer
subtask: true
---

Run `taskctl context`; require a branch-associated completed PR; read its Task,
optional research, and plan artifacts. Run `taskctl artifact ensure review`,
validate the PR, and review its full branch diff against the agreed base. Replace
`review.md` prose while preserving headings; identify PR and branch. Findings
are PR-wide, not Step-specific.

For actionable findings, add exactly one Step with
`taskctl step add --pr <pr-id> --title "Address PR review findings"` and append
its exact detailed heading to that PR in `plan.md`, referencing all findings.
Do not edit source or begin remediation; only the user invokes
`/address-review`. If there are no actionable findings, add no Step.

Return validation, verdict, findings, PR/branch, corrective Step, readiness, and
next action: `/address-review`, or branch checkout plus `/next-step` if approved.
