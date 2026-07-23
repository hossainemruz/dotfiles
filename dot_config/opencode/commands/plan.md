---
description: Create and register the selected Task plan.
agent: planner
subtask: true
---

Perform the planning skill's planning workflow for the selected Task. Treat `$ARGUMENTS` as optional planning constraints or emphasis; they may shape the plan but cannot override `task.md`. Create or update `plan.md`, register its matching PR/Step hierarchy through `taskctl`, and do not edit source code.

Return PR/Step counts, blockers, and `/next-step` after branch checkout.
