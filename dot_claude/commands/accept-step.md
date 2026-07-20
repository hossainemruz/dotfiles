---
description: Accept the selected Step
---

This invocation is explicit acceptance. Run `taskctl step get`, require
`ready_for_review`, run `taskctl step complete <step-id>`, then
`taskctl context`. Do not edit files.

Report updated state and recommend `/next-step`, or `/review-pr` when the PR is
complete.
