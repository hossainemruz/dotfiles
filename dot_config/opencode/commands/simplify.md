---
description: Review current changes for code-quality and simplification feedback.
agent: general
subtask: false
---

Dispatch `@reviewer` with `mode: ad-hoc` to review the full current branch state against its resolved default branch, including committed and uncommitted changes. Treat `$ARGUMENTS` as optional code-quality or simplification emphasis; it may prioritize but cannot narrow the changed-file scope or skip the Reviewer's correctness and security passes. Request high-confidence feedback on reuse, unnecessary complexity, duplication, avoidable indirection, ownership boundaries, redundant work, and safe simplification. Report findings only; do not edit source or start a remediation loop unless the user separately requests changes.
