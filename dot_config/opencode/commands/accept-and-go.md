---
description: Accept a Step, then automatically continue planned work or review and remediate the final PR.
agent: orchestrator
subtask: false
---

This invocation explicitly accepts the one `ready_for_review` Step and, only when it is a non-final planned Step, authorizes starting, implementing with `@builder`, and submitting the next planned Step under the canonical protocol. `$ARGUMENTS` is bounded guidance for that new Step. Final and corrective acceptance follow their canonical gates and stop without starting more planned work.
