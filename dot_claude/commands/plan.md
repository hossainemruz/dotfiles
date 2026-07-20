---
description: Create and register the selected Task plan
---

Run `taskctl context`; read `task.md` and optional `research.md`; then run
`taskctl artifact ensure plan`. Write an actionable requirements-linked plan of
cohesive PRs and atomic Steps with validation, using exact
`### PR-NNN: Title` and `#### STEP-NNN: Title` headings. Step IDs are unique
across the Task. Preserve user prose and the generated progress block.

Register the identical IDs, titles, order, and parentage through
`taskctl plan apply` JSON on stdin. Draft hierarchy may be replaced; after work
starts, preserve it and use `taskctl pr add`/`taskctl step add` for approved
additions. If research is absent, investigate enough to plan reliably. Do not
edit source.

Return PR/Step counts, blockers, and `/next-step` after branch checkout.
