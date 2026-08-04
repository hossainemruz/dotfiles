# Personal taskctl Workflow

Use this workflow only when the request concerns the selected Task, its artifacts, research, planning, Step implementation, PR review, validation, or progress. For unrelated questions, repository/config edits, or general advice, do not invoke `taskctl` merely because the repository has a selected Task.

## Resolve context

- Use broad `taskctl context` only for Task-level state or PR selection.
- Use `taskctl step context` once for Step implementation and direct feedback. Use `taskctl pr context` once for Step acceptance/classification and PR review; acceptance reuses that projection as the review handoff when applicable.
- Use `taskctl path <task|research|plan|review>` only to locate an artifact that must already exist.
- If context is missing, stale, or ambiguous, report the `taskctl` error and ask the user to run the appropriate `taskctl new`, `taskctl use`, or branch setup.

## Sources of truth

- `task.yaml` is canonical for Task, PR, and Step hierarchy and lifecycle. Never edit it directly; make lifecycle changes only with `taskctl`.
- `task.md` is authoritative for requirements, acceptance criteria, constraints, and non-goals.
- `research.md` contains evidence, options, trade-offs, risks, and the selected implementation approach. It cannot expand or override `task.md`.
- `plan.md` contains detailed PR and Step implementation prose. Its generated `taskctl:progress` block is a projection of `task.yaml`; never edit content between those markers.
- `review.md` stores the durable PR review-gate result. Initial full-PR findings are remediation input; verification replaces or updates them with mode `verification`, matching PR, branch, and corrective Step, plus an approved or remaining-findings verdict. There is no separate persisted Step review.

When sources conflict, follow the latest explicit user instruction, then `task.md`, `research.md`, and `plan.md`. Treat `taskctl` lifecycle state as canonical. Ask before proceeding when a conflict affects correctness or scope.

## Artifact operations

- Create missing optional artifacts only with `taskctl artifact ensure <research|plan|review>`; use the printed absolute path. The command is idempotent and preserves existing prose.
- Preserve template headings and user-authored content. Do not render template placeholders or recreate existing artifacts.
- Initial plans use exact `### PR-NNN: Title` and `#### STEP-NNN: Title` headings. After writing the prose, register the same IDs, titles, order, and parentage with `taskctl plan apply` JSON.
- After execution starts, append newly approved work with `taskctl pr add` or `taskctl step add` and add the returned ID's detailed heading to `plan.md`. Do not bulk-rewrite started hierarchy.

## Lifecycle rules

- The human starts the workflow with `taskctl new <title>`, fills in `task.md`, and invokes `/plan`. Planning ensures `plan.md`, writes the detailed PR/Step plan, and registers the matching hierarchy with `taskctl plan apply`.
- The user creates or checks out branches; `taskctl` does not manage Git branches. `/next-step` automatically selects the first pending PR and records the current named branch with `taskctl pr start <pr-id>` when no PR is active. If the checkout is still on a completed PR's branch, ask the user to switch to the intended next branch and rerun `/next-step`.
- For one Step at a time, `/next-step` obtains one `taskctl step context`, starts the selected Step, implements it, validates it, performs an automatic self-review, fixes accepted issues, and runs `taskctl step submit` for user review. Do not invoke a separate reviewer or write Step feedback to `review.md`.
- On explicit user acceptance only, run `taskctl step complete`. Acceptance obtains one `taskctl pr context`, identifies the sole ready Step, and classifies it as non-final planned implementation, final planned implementation, or review corrective. Direct feedback instead uses one `taskctl step context`, `taskctl step revise`, implementation, validation, self-review, and resubmission. No dedicated revise or Step-review command is used.
- There is no persisted `blocked` state. Leave blocked work `in_progress` and report the blocker.
- Accepting a non-final planned implementation Step completes it and stops unless `/accept-and-go` explicitly authorizes starting the next planned Step.
- Accepting the final planned implementation Step defers completion and runs one standard `remediation-enabled` full-PR review while that Step remains `ready_for_review` and the PR remains in progress. On approval, complete the accepted final Step and create no corrective Step. On findings, add exactly one pending `Address PR review findings` Step while the final Step is still ready, append its exact detailed heading under the PR in `plan.md` with every finding ID, then complete the final Step. The corrective Step keeps the PR in progress.
- Start the corrective Step from one `taskctl step context` and dispatch a fresh builder automatically. Builder readiness triggers `@review-verifier` before submission while the Step remains `in_progress`. Approval must be written durably to `review.md` before `taskctl step submit`. Remaining findings return automatically to the same builder and Step, followed by verification again; never add another corrective Step. Blocked work stays in progress and is reported.
- Later explicit acceptance of the corrective Step requires matching durable verification approval in `review.md`, completes it, and stops. It never launches another full-PR review or verifier. This check prevents manual submission from bypassing verification.
- `/accept-and-go` follows the same rules: only non-final planned Steps continue to the next planned Step; final planned Steps run the deferred review gate; verified corrective Steps complete and stop.
- `/address-review` is the fallback/manual entry to the same corrective builder-to-verifier-before-submit loop and never waits for a separate verification command.
- Explicit `/review-pr` and Task-backed `/expert-review` may continue to require a branch-associated completed PR. Findings add and start one corrective Step and enter the same builder-to-verifier loop; approval adds no lifecycle state. `/next-step` must refuse to start a review-created corrective Step. After final approval and acceptance, the user creates or checks out the next PR branch and invokes `/next-step`.

Keep repository changes separate from artifact and lifecycle updates, and mention both in summaries.
