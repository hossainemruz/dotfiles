---
description: Implement Task PR review findings, verify them, and submit the corrective Step.
agent: orchestrator
subtask: false
---

Execute the canonical corrective-Step remediation and verifier-before-submit loop. `$ARGUMENTS` is bounded feedback and cannot omit current findings. This command may start or revise the one corrective Step and submit it only after matching durable verifier approval; it never creates another Step or completes the corrective Step.
