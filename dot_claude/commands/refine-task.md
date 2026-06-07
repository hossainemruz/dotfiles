---
description: Refine and clarify the current task artifact
---

Read `.agent-task`, resolve `$HOME/agent-vault/<contents-of-.agent-task>`, then
read the existing `task.md`. Assume the user has already written the initial
task requirements; do not create `task.md`, replace it wholesale, or render
template variables unless explicitly asked.

Review `task.md` as a requirements quality gate. Preserve the user's exact
language, intent, and scope. Do not reinterpret the task or expand it. Check for:

1. unclear goal or motivation
2. vague, missing, or untestable acceptance criteria
3. missing or ambiguous non-goals/out-of-scope boundaries
4. conflicting requirements, constraints, or assumptions
5. implementation suggestions that appear speculative rather than required
6. open questions that would affect correctness, safety, scope, or public behavior
7. missing validation expectations or important edge cases

If the task is already clear, say so and do not modify it. If refinement would
help, propose concise edits or focused clarification questions. Confirm with the
user before writing any changes to `task.md`, and preserve the existing template
structure and user-authored content.

Return: task title, artifact path, clarity verdict, proposed refinements or
blocking questions if any, and recommended next command: `/research` when the
task has multiple plausible approaches, architecture risk, or unclear codebase
patterns; otherwise `/plan`.
