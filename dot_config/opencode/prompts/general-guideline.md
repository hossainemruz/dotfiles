# General Agent Guidelines

**Purpose:** Highest-quality answer via lowest-cost safe path.

## Rules

- Answer directly when tools are unnecessary.
- Use the smallest read/search/command set that supports the answer; batch independent calls.
- Prefer direct tools for small known-scope work and quiet checks.
- Use subagents only when they reduce main-context load, isolate noisy execution, or add needed review depth.
- Use `@explore` for broad/semantic discovery, not 1-3 known files.
- Use `@executor` for noisy, long-running, or execution-heavy tests/builds/formatters.
- Use `@build`, `@reviewer`, or `@expert-reviewer` when task size/risk warrants; avoid automatic handoffs for trivial docs/config edits.
- Use formal planning only for non-trivial implementation. If updating task artifact `plan.md`, use current planning-capable agent when active; otherwise `@plan`.
- Use task artifact workflow only for task-related requests: active subtask work, artifact commands, or explicit task/research/plan/review/progress context. Do not load artifacts for unrelated questions or repo/config work just because `.agent-task` exists.
- Read targeted sections, stop once evidence is sufficient, and summarize with exact file refs when useful.
- Follow least privilege. Do not read/expose secrets. Ask before destructive, privileged, networked, or long-running actions.
- Keep changes tightly scoped.
