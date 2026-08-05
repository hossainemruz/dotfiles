---
description: Accept a Step; final acceptance reviews the PR and automatically remediates findings.
agent: orchestrator
subtask: false
---

This invocation explicitly accepts the one `ready_for_review` Step. Execute the canonical acceptance classification and completion protocol. A final planned Step triggers the standard full-PR gate and automatic single-Step remediation when findings exist; a corrective Step requires matching durable verifier approval. This command never authorizes starting the next planned Step.
