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

Expected files: `task.md`, optional `research.md`, `plan.md`, `review.md`.

The user usually creates the task folder from templates in
`$HOME/agent-vault/templates/`. Agents should preserve each artifact's existing
structure and user-authored content. Do not recreate artifacts, overwrite whole
files, or render template variables unless explicitly asked.

## Source-of-truth priority

When artifacts and messages disagree, use this priority order:

1. Latest explicit user instruction.
2. `task.md` for scope and acceptance.
3. `research.md` for evidence, options, tradeoffs, risks, and the recommended
   implementation approach.
4. `plan.md` for sequencing, active work, and progress.
5. `review.md` for findings and validation state.

`research.md` must not override the task scope, requirements, acceptance
criteria, or non-goals in `task.md`. Treat research as implementation guidance
for planning, not as a requirements contract.

If the conflict affects correctness or scope, report it and ask before making
irreversible changes.

## Safe artifact updates

- Prefer bounded updates to existing `Progress` and `Latest Review` sections.
- Use status values consistently: `Pending`, `In Progress`, `Blocked`,
  `Review`, and `Completed`.
- Before starting implementation, mark exactly one commit-sized subtask or PR
  group as `In Progress` when possible.
- After implementation and validation, update only the relevant status/progress
  in `plan.md`. Keep review feedback in `review.md` concise and current.

## Agent behavior

When asked to research, plan, implement, review, summarize, or report progress
for a task:

1. Check whether `.agent-task` exists in the current repository.
2. If it exists, resolve the task artifact directory using the rule above.
3. Read only the relevant artifact files from that directory.
4. Treat those files as task context and prefer them over ad hoc assumptions.
5. Report missing required artifacts (`task.md`, `plan.md`, or `review.md`)
   clearly. Report missing `research.md` only when a research step was requested
   or planning depends on research context.
6. Do not scan the whole Obsidian vault or `$HOME/agent-vault` unless the user
   explicitly asks.
7. If updating task progress, update only the relevant progress/status section
   in `plan.md`. Use `review.md` only for current review findings and validation
   review.
8. Keep repository changes separate from artifact updates and mention both in
   summaries when applicable.
