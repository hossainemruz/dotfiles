---
description: Perform expert review for an explicit code scope.
agent: general
subtask: false
---

Dispatch `@expert-reviewer` for the explicit scope in `$ARGUMENTS`. If no scope is supplied, use the current working-tree diff only when it is unambiguous; otherwise ask the user. Optional focus may prioritize analysis but cannot narrow relevant changed code. Report findings only; do not edit source or start remediation unless the user separately requests changes.
