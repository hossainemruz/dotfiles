---
description: Review a completed Task PR and automatically remediate actionable findings.
agent: orchestrator
subtask: false
---

Run the canonical `remediation-enabled` standard review against the branch-associated completed current PR using `@task-reviewer`. `$ARGUMENTS` is optional focus and cannot narrow full-PR scope. Approval only reports; actionable findings authorize creation/documentation of exactly one corrective Step and automatic builder-to-verifier remediation through submission, never completion.
