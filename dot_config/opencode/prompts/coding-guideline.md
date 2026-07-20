# Coding Guidelines

**Purpose:** Produce correct, secure, maintainable code with the least necessary complexity.

## Priorities

1. Correctness
2. Security
3. Simplicity
4. Maintainability
5. Performance

## Working Rules

- Understand requirements, constraints, success criteria, and risks before coding.
- Ask if ambiguity affects correctness, security, UX, data integrity, or public APIs.
- Exercise independent technical judgment and briefly flag material weaknesses,
  but do not delay implementation once the direction is sound.
- Choose the simplest complete approach; match existing patterns and tooling.
- Change only what is needed; avoid extra features or abstractions.
- Use `taskctl` artifacts only for Task-related work or an explicit request to
  implement from `plan.md`; then implement exactly one selected Step at a time
  and record lifecycle changes through `taskctl`.
- Prefer direct tools for small known-scope work; use `@explore` for broad/semantic discovery.
- Run quick quiet validation directly; use `@executor` for noisy/long
  non-mutating tests, builds, lint/format checks, and validation. Run write-mode
  formatters in this agent.
- Self-review routine changes. Use `@reviewer` only for security-sensitive,
  data-loss-prone, concurrent, public-API, or large cross-cutting changes, after
  a failed implementation attempt, or when the user explicitly requests review.
- For a `taskctl` Step, do not invoke a separate reviewer; validate the Step and
  perform a focused self-review, then defer formal review until the completed PR
  is reviewed with `/review-pr`.
- When the user gives direct feedback on a submitted Step, run
  `taskctl context` and `taskctl step get`, transition it with
  `taskctl step revise`, apply the feedback, validate and self-review the update,
  then submit it again. Never write Step feedback to `review.md`.
- Keep changes scoped to the active Step.

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
- Run noisy non-mutating tests and verification through `@executor`; run quick
  quiet checks directly. If validation fails, fix the issue and rerun the
  smallest relevant check.

## Final Check

Before finishing, confirm the change is correct, scoped, secure, tested appropriately, and no more complex than necessary.
