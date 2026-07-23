---
name: simplify
description: Review changed code for reuse, quality, and efficiency, then fix worthwhile issues.
---

# Simplify

Review the current branch state against its base, then apply only high-confidence, low-risk cleanup.

## Scope

- Resolve the comparison base robustly: try `origin/HEAD`, the current branch upstream, `origin/main`, `origin/master`, `main`, then `master`; use the first candidate for which `git merge-base HEAD <candidate>` succeeds. Stop and report if none succeeds.
- Review the branch diff from that merge base, including committed, staged, and unstaged changes.
- Include untracked files only when they are plausibly part of the current work.
- Keep edits to changed files. Allow a tiny adjacent refactor only when it materially improves the changed code without broadening behavior or ownership.
- Exclude generated, vendored, minified, lock, cache, build-output, and other non-source artifacts unless directly relevant.
- If no relevant changes exist, report that there is nothing to simplify and stop.

## Review

Inspect the changed code and only the surrounding context needed to assess these lenses:

### Reuse

- Prefer existing helpers, shared modules, constants, types, and established patterns over duplicated or hand-rolled logic.
- Consolidate copy-paste only when the shared abstraction is clearer and remains appropriately scoped.

### Quality

- Remove redundant state, parameters, indirection, and comments that merely narrate the code.
- Correct leaky abstractions, stringly typed logic, and avoidable complexity when the fix is local and clear.
- Preserve public interfaces and existing behavior unless a behavior correction is clearly required by the changed code.

### Efficiency

- Remove redundant computation, I/O, API calls, N+1 work, unconditional no-op updates, hot-path bloat, leaks, and overly broad reads.
- Prefer direct operations with explicit error handling over existence pre-checks that introduce TOCTOU races.
- Suggest or introduce concurrency only when operations are genuinely independent, the benefit is material, and ordering, cancellation, and error semantics remain explicit and correct.

## Apply and Validate

- Deduplicate overlapping observations and fix only worthwhile issues within scope; skip speculative refactors and low-value churn.
- Use targeted repository search and symbol navigation to confirm reuse opportunities before changing code.
- When a fix may change behavior, delegate the smallest relevant tests, build, lint, or other validation to `@executor`.
- Keep deterministic tests and existing project conventions; explain when validation is not needed or no practical check exists.

## Report

Concisely summarize files changed, simplifications applied, material opportunities skipped and why, and validation results. If no worthwhile fix was needed, say the branch diff was already clean.
