---
description: Review the current diff for simplification opportunities and apply worthwhile cleanup.
---

Ask the `@simplifier` subagent to review the current diff for reuse, quality, and efficiency, then apply any worthwhile fixes without widening scope unnecessarily. Keep the work focused on already changed files unless a very small adjacent refactor clearly improves the result. If the simplifications affect behavior, ask the `@executor` subagent to run the smallest relevant validation afterward. Finish with a short summary of the files changed, simplifications made, and validation result.
