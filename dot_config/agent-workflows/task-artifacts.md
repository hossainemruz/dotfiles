# Personal taskctl Workflow

Use this workflow only when the request concerns the selected Task, its
artifacts, research, planning, Step implementation, PR review, validation, or
progress. For unrelated questions, repository/config edits, or general advice,
do not invoke `taskctl` merely because the repository has a selected Task.

## Resolve context

- For Task- or PR-level work, run `taskctl context` once from the project
  repository and use the returned Task, PR, and absolute artifact paths.
- For `/next-step` and direct feedback on a Step, run `taskctl context` first to
  resolve aggregate PR state, then `taskctl step get` to resolve the selected
  Step and artifact paths.
- Use `taskctl path <task|research|plan|review>` only to locate an artifact that
  must already exist.
- If context is missing, stale, or ambiguous, report the `taskctl` error and ask
  the user to run the appropriate `taskctl new`, `taskctl use`, or branch setup.

## Sources of truth

- `task.yaml` is canonical for Task, PR, and Step hierarchy and lifecycle. Never
  edit it directly; make lifecycle changes only with `taskctl`.
- `task.md` is authoritative for requirements, acceptance criteria, constraints,
  and non-goals.
- `research.md` contains evidence, options, trade-offs, risks, and the selected
  implementation approach. It cannot expand or override `task.md`.
- `plan.md` contains detailed PR and Step implementation prose. Its generated
  `taskctl:progress` block is a projection of `task.yaml`; never edit content
  between those markers.
- `review.md` stores only the latest PR-level review. There is no separate
  persisted or command-driven Step review.

When sources conflict, follow the latest explicit user instruction, then
`task.md`, `research.md`, and `plan.md`. Treat `taskctl` lifecycle state as
canonical. Ask before proceeding when a conflict affects correctness or scope.

## Artifact operations

- Create missing optional artifacts only with
  `taskctl artifact ensure <research|plan|review>`; use the printed absolute
  path. The command is idempotent and preserves existing prose.
- Preserve template headings and user-authored content. Do not render template
  placeholders or recreate existing artifacts.
- Initial plans use exact `### PR-NNN: Title` and
  `#### STEP-NNN: Title` headings. After writing the prose, register the same
  IDs, titles, order, and parentage with `taskctl plan apply` JSON.
- After execution starts, append newly approved work with `taskctl pr add` or
  `taskctl step add` and add the returned ID's detailed heading to `plan.md`.
  Do not bulk-rewrite started hierarchy.

## Lifecycle rules

- The human starts the workflow with `taskctl new <title>`, fills in `task.md`,
  and invokes `/plan`. Planning ensures `plan.md`, writes the detailed PR/Step
  plan, and registers the matching hierarchy with `taskctl plan apply`.
- The user creates or checks out branches; `taskctl` does not manage Git
  branches. `/next-step` automatically selects the first pending PR and records
  the current named branch with `taskctl pr start <pr-id>` when no PR is active.
  If the checkout is still on a completed PR's branch, ask the user to switch to
  the intended next branch and rerun `/next-step`.
- For one Step at a time, `/next-step` resolves context with both
  `taskctl context` and `taskctl step get`, starts the selected Step, implements
  it, validates it, performs an automatic self-review, fixes accepted issues,
  and runs `taskctl step submit` for user review. Do not invoke a separate
  reviewer or write Step feedback to `review.md`.
- On explicit user acceptance only, run `taskctl step complete`. If the user
  instead gives direct feedback, the agent runs `taskctl context` and
  `taskctl step get`, uses `taskctl step revise`, addresses the feedback,
  validates and self-reviews the update, and submits again. No dedicated revise
  or Step-review command is used.
- There is no persisted `blocked` state. Leave blocked work `in_progress` and
  report the blocker.
- `/review-pr` reviews the completed current PR. Replace `review.md` with the
  latest review and identify the PR and branch. Findings are PR-wide, not tied
  to individual Steps. If findings are actionable, add one corrective Step with
  `taskctl step add` as the lifecycle container for all remediation and append
  its detailed plan heading; this reopens the PR and Task. The reviewer stops
  there. The user explicitly invokes `/address-review`, which runs only in this
  state and addresses the complete `review.md` scope. `/next-step` must detect
  and refuse to start that review-created corrective Step. After the PR is
  approved, the user creates or checks out the next PR branch and invokes
  `/next-step`.

Keep repository changes separate from artifact and lifecycle updates, and
mention both in summaries.
