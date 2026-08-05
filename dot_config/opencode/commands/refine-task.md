---
description: Refine the selected Task requirements.
agent: planner
subtask: true
---

Run the planning skill's refinement workflow. Treat `$ARGUMENTS` as requested refinements or context to evaluate without silently expanding scope. Ask the smallest batch of independent blocking questions and sequence only dependent questions. Once clear, apply valid refinements to `task.md`; if none are needed, do not edit it.

Return Task ID/title/path, verdict, blockers, and `/research` or `/plan`.
