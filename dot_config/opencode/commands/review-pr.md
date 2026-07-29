---
description: Review the completed current PR.
agent: reviewer
subtask: true
---

Run the review skill's Task PR workflow in `remediation-enabled` mode. Treat `$ARGUMENTS` as optional focus; it cannot narrow the full PR diff or required review passes. Return the workflow's validation, verdict, findings, PR/branch, corrective-Step state, and readiness. With findings, return control for orchestrator remediation; when approved, report branch checkout plus `/next-step` as informational only.
