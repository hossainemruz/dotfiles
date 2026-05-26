---
name: parallel-review
description: Concurrent three-agent code review across correctness/security, robustness/performance, and maintainability/tests. Faster than sequential review for any non-trivial diff.
permissions:
  edit: allow
---

# Parallel Review

Run three focused `@explore` review agents concurrently, then aggregate their findings into `.agents/tasks/review.md`.

## Phase 1: Gather Context

1. Run `git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD~1)` to get the full diff. Fall back to `git diff HEAD~1` if the base branch is unknown.
2. If `.agents/tasks/plan.md` exists, read the sub-task marked `In Progress` to scope the review. If none is marked, read the task intent from `.agents/tasks/task.md` if present.

## Phase 2: Launch Three Review Agents in Parallel

Spawn all three `@explore` agents in a **single message**. Pass each agent:
- The full diff text
- The active sub-task scope and done-when criteria (if available)
- Their specific focus area (below)
- This instruction: "Return a list of findings only. For each finding include: severity (P0–P3), title, file:line, why it matters, evidence (the failure path), and a specific fix. Do not write to any file."

### Agent 1 — Correctness & Security (`@explore`)

1. **Logic errors**: wrong conditions, off-by-one, incorrect operator precedence, missing nil/zero checks, incorrect loop bounds
2. **Error handling**: swallowed errors, missing early returns, wrong error types propagated up the call stack
3. **Data integrity**: incorrect mutation of shared state, wrong assumptions about input shape or ordering
4. **Security**: injection vectors (SQL, shell, template), auth/authz gaps, sensitive data in logs or errors, insecure defaults, path traversal, missing input sanitization at system boundaries

### Agent 2 — Robustness & Performance (`@explore`)

1. **Edge cases**: missing input validation at boundaries, unhandled nil/empty/overflow, fragile assumptions about external system behavior
2. **Resource leaks**: unclosed handles, missing defer/cleanup, goroutine or thread leaks
3. **Performance**: N+1 patterns, redundant computation in hot paths, blocking calls on the critical path, unbounded data structures
4. **Concurrency**: missing locks, incorrect atomics, deadlock potential, TOCTOU races

### Agent 3 — Maintainability & Tests (`@explore`)

1. **Test coverage**: missing tests for new behavior, untested edge cases, non-deterministic tests
2. **Scope creep**: changes outside the active sub-task's stated scope or done-when criteria
3. **Duplication**: new code that replicates existing utilities or patterns in the codebase
4. **Abstraction quality**: leaky abstractions, broken encapsulation, parameter sprawl, misleading names
5. **Unnecessary complexity**: over-engineered solutions, dead code, magic values without constants

## Phase 3: Aggregate and Write

Wait for all three agents to complete. Then:

1. **Deduplicate**: if two agents flagged the same root cause, keep the more specific finding and drop the duplicate.
2. **Sort by severity**: P0 → P1 → P2 → P3. Within a severity, correctness and security findings come first.
3. Write the aggregated findings to `.agents/tasks/review.md` using the template below.

```markdown
# Code Review Summary

**Scope**: [feature/fix reviewed]
**Overall risk**: High / Medium / Low
**Verdict**: Approve / Approve with comments / Request changes

## Findings

### [P0] Blocking

- **Title**
  - **Location**: `path/to/file.ext:10-24`
  - **Why it matters**: [impact]
  - **Evidence**: [failure path]
  - **Fix**: [specific recommendation]

### [P1] High

### [P2] Medium

### [P3] Low

## Suggested Next Steps

- [ ] Fix P0/P1 findings before merge
- [ ] Add or update tests where noted
- [ ] Re-run relevant validation after fixes
```

If there are no actionable findings, say so directly and approve.
