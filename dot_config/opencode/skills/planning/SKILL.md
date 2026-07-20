---
name: planning
description: Researches implementation options and creates taskctl-compatible implementation plans.
---

Research implementation options or write execution plans for the selected `taskctl` Task. Use this workflow only for Task-related requests or explicit artifact work; do not invoke `taskctl` for unrelated planning or advice.

## Scope

- Run `taskctl context` once and use its absolute artifact paths. Do not scan the vault or infer paths from repository files.
- Research requests create `research.md` with `taskctl artifact ensure research`, then edit only that artifact.
- Planning requests create `plan.md` with `taskctl artifact ensure plan`, edit its prose, and register the matching hierarchy with `taskctl plan apply`.
- Do not modify repository source code during research or planning.
- Do not create formal plans for advisory, exploratory, or review-only requests.
- Research only when uncertainty, multiple plausible approaches, architecture risk, or unknown codebase patterns justify it.
- Preserve artifact structure and user-authored content. Never edit `task.yaml` or content between the `taskctl:progress` markers in `plan.md`.

## Sources of Truth

- The latest user instruction sets immediate scope.
- `task.yaml` is canonical lifecycle state and may be changed only by `taskctl`.
- `task.md` is the binding requirements contract: goal, scope, acceptance criteria, constraints, non-goals, and edge cases.
- `research.md` is implementation evidence: options, trade-offs, risks, and the selected approach. It cannot override `task.md`.
- `plan.md` contains detailed implementation guidance; its generated progress block is not agent-authored state.
- Ask only clarification questions that block correctness or scope.

## Efficiency

- Prefer FFF for file/content discovery, LSP for symbol navigation, and ast-grep for structural searches; use `glob`/`grep` only for exact-glob or regex fallback, then read targeted ranges.
- Use `@explore` only for focused codebase evidence or pattern lookup that would cost more in the main context.
- Use `@executor` only for command-heavy, non-mutating validation needed for research or planning. Run short `taskctl` commands directly.
- Stop once the recommendation or plan is supported by concrete evidence.

## Research Workflow

1. Run `taskctl context`; read its `task` artifact and existing `research` artifact when present.
2. Run `taskctl artifact ensure research` before writing when the artifact is absent. Use the path printed by the command; do not render templates manually.
3. Identify relevant files, components, existing patterns, and similar implementations with targeted searches and reads.
4. Compare viable approaches, including trade-offs, risks, constraints, compatibility concerns, validation implications, and blocking questions.
5. Select one recommended approach yourself.
6. Write the evidence and decision to `research.md` without changing Task scope.

## Planning Workflow

1. Run `taskctl context`; read `task.md` and optional `research.md` from the returned paths.
2. If `research.md` is absent, perform the focused codebase investigation needed to make the plan reliable within this planning run. Do not block the normal `/plan` workflow merely because a separate research artifact is missing.
3. Run `taskctl artifact ensure plan` and preserve its template structure.
4. Add a concise Requirements Snapshot with stable IDs (`R1`, `R2`, ...), while preserving any existing acceptance-criterion IDs.
5. Break work into ordered, cohesive, independently reviewable PRs.
6. Break each PR into atomic Steps whose IDs remain unique across the whole Task. Avoid mixing unrelated refactors, behavior changes, migrations, tests, and cleanup.
7. Use the exact headings below. PR IDs are Task-local; Step IDs are unique across the entire Task.
   - `### PR-NNN: Title`
   - `#### STEP-NNN: Title`
8. For each PR include its objective, requirement IDs, dependencies, review scope, expected areas, scope limits, risks, validation, and completion condition. For each Step include its purpose, requirement IDs, concrete changes, validation, and review notes.
9. Reuse IDs for unchanged draft work and keep initial IDs sequential. While the Task remains `draft`, the hierarchy may be replaced when the requested plan refresh requires it. Do not put mutable status fields in detailed prose.
10. After writing `plan.md`, send a JSON object containing the identical PR and Step IDs, titles, order, and parentage to `taskctl plan apply` over standard input. Do not create a plan JSON file in the repository.
11. If execution has started, do not attempt bulk replacement. Preserve the registered hierarchy; use `taskctl pr add` or `taskctl step add` only for newly approved work, then append the detailed heading using the returned ID. Never skip or reopen work without explicit user direction.
12. If `taskctl` rejects the hierarchy or projection update, report the error and repair the plan/JSON mismatch rather than editing `task.yaml`.

## Lifecycle Rules

- Planning does not start a PR or Step.
- `taskctl` derives Task and PR status from Step state.
- Do not manually mark work Pending, In Progress, Ready for Review, or Completed in `plan.md`; lifecycle commands maintain the generated progress block.
- Public API, schema, migration, or compatibility-affecting changes should be isolated when practical.

## Final Check

For research:
- The recommendation is grounded in codebase evidence and Task requirements.
- Alternatives, risks, and open questions are clear.

For planning:
- The plan is ordered, actionable, scoped, and self-contained.
- Every PR and Step maps to requirements and has concrete validation.
- IDs, titles, ordering, and parentage match the JSON accepted by `taskctl plan apply`.
- Scope limits, risks, dependencies, and completion conditions are explicit.
