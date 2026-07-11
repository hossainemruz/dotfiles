# Personal Task Artifact Workflow

Repos opt in with `.agent-task`. If absent, ignore this workflow. If present,
use this workflow only when the user request is task-related: it mentions the
active task, task artifacts, `/task-*` style commands, planning, research,
implementation from `plan.md`, review feedback, validation status, or progress.
For unrelated questions, repo/config edits, or general advice, do not read task
artifacts just because `.agent-task` exists.

## Resolve current task

- Read `.agent-task` as a relative path inside `$HOME/agent-vault`.
- Artifact directory: `$HOME/agent-vault/<.agent-task contents>`.
- Example: `tasks/faber/FB-001` → `$HOME/agent-vault/tasks/faber/FB-001`.

## Artifacts

Expected: `task.md`, optional `research.md`, `plan.md`, `review.md`.
Preserve existing structure and user-authored content. Do not recreate artifacts,
overwrite whole files, or render template variables unless asked.

## Source of truth

When artifacts/messages conflict:
1. latest explicit user instruction
2. `task.md` for scope, requirements, acceptance, constraints, non-goals
3. `research.md` for evidence, options, tradeoffs, risks, recommended approach
4. `plan.md` for sequencing, active work, progress
5. `review.md` for findings and validation state

`research.md` guides implementation only; it must not expand or override
`task.md`. If conflict affects correctness or scope, report it and ask before
irreversible changes.

## Safe updates

- Prefer bounded updates to existing `Progress`, `Agent Status`, and `Latest Review` sections.
- Use status values consistently: `Pending`, `In Progress`, `Blocked`, `Review`, `Completed`.
- Before implementation, mark exactly one commit-sized subtask `In Progress` when possible. Derive PR-group status from its subtask statuses.
- After implementation/validation, update only relevant progress/status in `plan.md`.
- Keep review feedback in `review.md` concise and current.

## Agent behavior

For task-related research, planning, implementation, review, summaries, or progress:
1. Check for `.agent-task`.
2. Resolve artifact directory using the rule above.
3. Read only relevant artifact files.
4. Treat artifacts as task context; prefer them over ad hoc assumptions.
5. Report missing required artifacts (`task.md`, `plan.md`, `review.md`). Report missing `research.md` only for research or when planning depends on it.
6. Do not scan the rest of `$HOME/agent-vault` unless asked.
7. If updating task progress, update only relevant progress/status in `plan.md`; use `review.md` only for current review findings/validation review.
8. Keep repository changes separate from artifact updates and mention both in summaries.
