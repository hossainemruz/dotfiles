---
description: Create or update the current task.md artifact from a description.
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Update `task.md` there while
preserving its existing template structure. Assume the task folder and artifact
files already exist; do not create them or render template variables unless
explicitly asked.

Interview the user to capture the task. Ask for:
1. Goal — what should be accomplished and why
2. Requirements — specific behaviors, constraints, or invariants
3. Acceptance criteria — how to verify it is done
4. Out-of-scope — what must not change or be added
5. Open questions — anything unclear that could affect scope or correctness

Use the user's exact language; do not reinterpret or expand scope. Preserve
existing user-authored content and the template structure unless the user
explicitly asks for a rewrite. Confirm with the user before writing. Return a
compact summary with the task title, artifact path, and suggest running `/plan`
next.
