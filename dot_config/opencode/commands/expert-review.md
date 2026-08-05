---
description: Perform a premium review; Task findings create one pending corrective Step but are not implemented.
agent: orchestrator
subtask: false
---

Dispatch `@expert-reviewer` for review only. `$ARGUMENTS` is optional concrete ad hoc scope or Task full-PR focus; focus cannot omit relevant changed code. For a Task-backed review, require the canonical completed-PR gate and `remediation-enabled` artifact workflow. Actionable Task findings authorize creation and documentation of exactly one pending corrective Step, then stop and direct the user to `/address-review`. For ad hoc scope, report findings and stop. Never dispatch a builder or edit source; if no usable ad hoc scope exists, ask rather than invoking `taskctl` or scanning broadly.
