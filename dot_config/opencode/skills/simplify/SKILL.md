---
name: simplify
description: Review changed code for reuse, quality, and efficiency, then fix any issues found.
---

# Simplify: Code Review and Cleanup

Review the current branch state against the repository's default branch for reuse, quality, and efficiency, including committed and uncommitted changes. Apply only worthwhile cleanup.

## Operating Rules

- Review the full current branch state against the repository's default branch, including committed changes plus staged and unstaged working tree changes. Also include untracked files when they are part of the current work.
- Determine the comparison branch robustly. Prefer `origin/HEAD` when available, then the current branch upstream, then `origin/main`, `origin/master`, `main`, and `master`. If none succeeds, stop and report that you could not determine the base branch.
- Keep changes tightly scoped to files changed in the branch diff unless a very small adjacent refactor materially improves the result.
- Prefer high-confidence, low-risk simplifications. Skip speculative or wide-scope refactors.
- Skip generated, vendored, minified, lock, cache, build-output, and other non-source artifacts unless they are directly relevant to the simplification.
- Use `@executor` only for tests, builds, git commands, or other execution-heavy validation when behavior may have changed or command output is needed.
- If you skip a candidate because it is a false positive, too risky, or not worthwhile, mention it briefly in the final summary.

## Phase 1: Identify Branch Changes

1. Resolve the comparison branch in this order: `origin/HEAD`, the current branch upstream, `origin/main`, `origin/master`, `main`, then `master`.
2. Compute `BASE` from the first candidate that succeeds with `git merge-base HEAD <candidate>`. If none succeeds, stop and report that you could not determine the base branch.
3. Run `git diff --name-status "$BASE"` to get tracked files changed in the current branch state relative to `BASE`, including rename/delete status.
4. Exclude deleted files from file reads, but keep them in mind when evaluating whether nearby code can now be simplified.
5. Run `git ls-files --others --exclude-standard` to collect untracked files, then keep only files that are plausibly part of the current work. Exclude obvious temp files, screenshots, scratch notes, caches, and build artifacts unless the diff makes them relevant.
6. Combine both into the review scope.
7. Run `git diff "$BASE"` to inspect the tracked diff for the current branch state.
8. For untracked files, inspect only the files in scope that are relevant to the simplification pass.
9. If there are no changed or untracked files in scope, report that there are no current branch changes to simplify and stop.

## Phase 2: Choose Review Depth

If the scoped change is small and simple (for example, 1-2 files with limited, localized edits), do the review yourself and skip subagents.

Use parallel subagents only when the diff is large enough or varied enough that separate reuse, quality, and efficiency passes are likely to find materially different issues.

If you review the diff yourself, still cover all three lenses below before moving to Phase 3.

## Phase 3: Launch Three Review Subagents in Parallel When Needed

When Phase 2 indicates parallel review is worthwhile, launch three `@explore` subagents concurrently in a single message. Pass each agent:

- the branch base reference
- the changed file list
- a concise summary of the changed areas, and only the relevant diff hunks when needed
- this instruction: "Inspect only files touched by the branch diff plus minimal adjacent context. Return at most 3-5 actionable, high-confidence findings with title, file:line, why it matters, evidence, and exact fix. Ignore style-only nits and speculative refactors. Skip generated/vendor/minified/lock files unless directly relevant. Do not write to any file."

Do not blindly paste the full diff to all three agents when the changed file list and targeted hunks are enough.

### Subagent 1: Code Reuse Review

For each change:

1. **Search for existing utilities and helpers** that could replace newly written code. Look for similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. **Flag any new function that duplicates existing functionality.** Suggest the existing function to use instead.
3. **Flag any inline logic that could use an existing utility** — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

### Subagent 2: Code Quality Review

Review the same changes for hacky patterns:

1. **Redundant state**: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. **Parameter sprawl**: adding new parameters to a function instead of generalizing or restructuring existing ones
3. **Copy-paste with slight variation**: near-duplicate code blocks that should be unified with a shared abstraction
4. **Leaky abstractions**: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. **Stringly-typed code**: using raw strings where constants, enums (string unions), or branded types already exist in the codebase
6. **Unnecessary comments**: comments explaining WHAT the code does (well-named identifiers already do that), narrating the change, or referencing the task/caller — delete; keep only non-obvious WHY (hidden constraints, subtle invariants, workarounds)

### Subagent 3: Efficiency Review

Review the same changes for efficiency:

1. **Unnecessary work**: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. **Missed concurrency**: independent operations run sequentially when they could run in parallel
3. **Hot-path bloat**: new blocking work added to startup or per-request/per-render hot paths
4. **Recurring no-op updates**: state/store updates inside polling loops, intervals, or event handlers that fire unconditionally — add a change-detection guard so downstream consumers aren't notified when nothing changed. Also: if a wrapper function takes an updater/reducer callback, verify it honors same-reference returns (or whatever the "no change" signal is) — otherwise callers' early-return no-ops are silently defeated
5. **Unnecessary existence checks**: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
6. **Memory**: unbounded data structures, missing cleanup, event listener leaks
7. **Overly broad operations**: reading entire files when only a portion is needed, loading all items when filtering for one

## Phase 4: Deduplicate and Prioritize Findings

If subagents were launched, wait for all three to complete. Deduplicate overlapping findings that point to the same root cause. If you reviewed the diff yourself, consolidate the findings from your three lenses. Prioritize fixes that materially improve reuse, quality, or efficiency without widening scope.

## Phase 5: Apply Worthwhile Fixes

Fix each worthwhile issue directly. Skip false positives, risky changes, and low-value churn.

If your fixes may have changed behavior, ask `@executor` to run the smallest relevant validation.

## Phase 6: Summarize

Briefly summarize:

- files changed
- worthwhile simplifications applied
- any skipped opportunities and why
- validation result, if run, or why validation was not needed

If no worthwhile changes were needed, say the branch diff was already clean.
