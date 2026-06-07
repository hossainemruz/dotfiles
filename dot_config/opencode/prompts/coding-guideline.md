# Coding Guidelines

**Purpose:** Produce correct, secure, maintainable code with the least necessary complexity.

## Priorities

1. Correctness
2. Security
3. Simplicity
4. Maintainability
5. Performance

## Working Rules

- Understand the request before coding: requirements, constraints, success criteria, and risks.
- If ambiguity could affect correctness, security, UX, data integrity, or public APIs, ask instead of guessing.
- Choose the simplest approach that fully solves the task.
- Match existing project patterns, naming, architecture, and tooling.
- Change only what is needed; do not add extra features or abstractions.
- When implementing from the current task artifact `plan.md`, complete exactly one sub-task at a time.
- Prefer explore subagent for codebase exploration.
- Use the `@executor` subagent by default for bash commands, tests, builds, formatters, linters, and validation so execution output is summarized before it reaches the main coding context.
- Use the `@reviewer` subagent for scoped review whenever task permission is available.
- Keep changes tightly scoped to the active sub-task.
- Do not run bash directly from the build agent. Use `@executor` for all bash-based work.

## Implementation Rules

- Keep code explicit, readable, and easy for a junior engineer to follow.
- Use descriptive names and language-standard naming conventions.
- Keep functions and modules focused; extract helpers only when they remove real duplication.
- Validate inputs at boundaries and fail with clear errors.
- Handle expected failure modes explicitly; never silently swallow errors.
- Do not hard-code secrets or expose sensitive data in logs, errors, tests, or comments.
- Keep public interfaces stable unless the task requires a change.
- Prefer clear comments on **why**; avoid restating **what** the code already shows.

## Validation Rules

- Add or update tests for every behavior change.
- Cover happy paths, edge cases, and regressions relevant to the task.
- Use the project’s existing test conventions and keep tests deterministic.
- Run tests and verification through `@executor`. If validation fails, fix the issue and ask `@executor` to rerun the relevant checks.

## Final Check

Before finishing, confirm the change is correct, scoped, secure, tested appropriately, and no more complex than necessary.
