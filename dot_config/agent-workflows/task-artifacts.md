# Personal Task Artifact Workflow

This is a personal workflow for repositories that opt in with a `.agent-task`
file. Do not require repository-level instructions for this workflow.

## Resolving the current task

If the current repository contains a `.agent-task` file, read it as a relative
path inside `$HOME/agent-vault`.

Resolve the task artifact directory as:

```text
$HOME/agent-vault/<contents-of-.agent-task>
```

For example, if `.agent-task` contains `tasks/faber/FB-001`, the task artifact
directory is `$HOME/agent-vault/tasks/faber/FB-001`.

## Artifacts and templates

Expected files: `task.md`, `plan.md`, `review.md`.

The user usually creates the task folder from templates in
`$HOME/agent-vault/templates/`. Agents should preserve each artifact's existing
structure and user-authored content. Do not recreate artifacts, overwrite whole
files, or render template variables unless explicitly asked.

## Source-of-truth priority

When artifacts and messages disagree, use this priority order:

1. Latest explicit user instruction.
2. `task.md` for scope and acceptance.
3. `plan.md` for sequencing, active work, and progress.
4. `review.md` for findings and validation state.

If the conflict affects correctness or scope, report it and ask before making
irreversible changes.

## Safe artifact updates

- Prefer bounded updates: `AGENT_STATUS_START` / `AGENT_STATUS_END`,
  `Progress`, `Latest Review`, `Review History`, or `plan.md` `Checkpoints`.
- Treat `plan.md` `Checkpoints` and `review.md` `Review History` as append-only logs.
- Use status values consistently: `Pending`, `In Progress`, `Blocked`,
  `Review`, and `Completed`.
- Before starting implementation, mark exactly one commit-sized subtask or PR
  group as `In Progress` when possible.
- After implementation and validation, update the relevant status in `plan.md`
  and add a `plan.md` checkpoint with what changed, validation, review result,
  and next action. Keep detailed review history in `review.md`.

## Agent behavior

When asked to plan, implement, review, summarize, or report progress for a
task:

1. Check whether `.agent-task` exists in the current repository.
2. If it exists, resolve the task artifact directory using the rule above.
3. Read only the relevant artifact files from that directory.
4. Treat those files as task context and prefer them over ad hoc assumptions.
5. Report missing `task.md`, `plan.md`, or `review.md` clearly.
6. Do not scan the whole Obsidian vault or `$HOME/agent-vault` unless the user
   explicitly asks.
7. If updating task progress, update the relevant progress/status section in
   `plan.md` and add a `plan.md` checkpoint. Use `review.md` only for review
   findings, validation review, and review history.
8. Keep repository changes separate from artifact updates and mention both in
   summaries when applicable.
