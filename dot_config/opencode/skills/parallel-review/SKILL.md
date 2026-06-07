---
name: parallel-review
description: Concurrent three-agent code review for non-trivial diffs, with a single delegated review pass for small/simple changes.
permissions:
  edit: allow
---

# Parallel Review

For non-trivial diffs, run three focused `@explore` review agents concurrently,
then aggregate their findings into the current task artifact `review.md`. For
small, simple diffs, delegate to a single `@explore` review pass instead. Do
not review code inline yourself — always delegate the actual review reasoning
to `@explore` and reserve this agent for scoping and aggregation. If
`.agent-task` exists, use the task artifact workflow.

## Phase 1: Gather Context

1. Run `git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD~1)` to get the full diff. Fall back to `git diff HEAD~1` if the base branch is unknown.
2. If artifact `plan.md` exists, read the sub-task marked `In Progress` to scope the review. If none is marked, read the task intent from artifact `task.md` if present.

## Phase 2: Choose Review Depth

Assess the scoped diff before launching any subagents, then choose how many `@explore` passes to spawn. Do not review the code yourself in either case.

If the diff is small and simple (for example, 1-2 files with limited, localized edits and no cross-cutting concerns), spawn a **single** `@explore` agent covering all three focus areas below, then aggregate its findings into artifact `review.md` and stop.

Use the three-agent parallel fan-out only when the diff is large enough, risky enough, or varied enough that separate focused passes are likely to find materially different issues.

## Phase 3: Launch Three Review Agents in Parallel When Needed

Spawn all three `@explore` agents in a **single message**. Pass each agent:

- The full diff text
- The active sub-task scope and done-when criteria (if available)
- Their specific focus area (below)
- This instruction: "Return a list of findings only. For each finding include: severity (P0–P3), title, file:line, why it matters, evidence (the failure path), and a specific fix. Do not write to any file."

### Subagent 1 — Correctness & Security

1. **Logic errors**: wrong conditions, off-by-one, incorrect operator precedence, missing nil/zero checks, incorrect loop bounds
2. **Error handling**: swallowed errors, missing early returns, wrong error types propagated up the call stack
3. **Data integrity**: incorrect mutation of shared state, wrong assumptions about input shape or ordering
4. **Security**: injection vectors (SQL, shell, template), auth/authz gaps, sensitive data in logs or errors, insecure defaults, path traversal, missing input sanitization at system boundaries

### Subagent 2 — Robustness & Performance

1. **Edge cases**: missing input validation at boundaries, unhandled nil/empty/overflow, fragile assumptions about external system behavior
2. **Resource leaks**: unclosed handles, missing defer/cleanup, goroutine or thread leaks
3. **Performance**: N+1 patterns, redundant computation in hot paths, blocking calls on the critical path, unbounded data structures
4. **Concurrency**: missing locks, incorrect atomics, deadlock potential, TOCTOU races

### Subagent 3 — Maintainability & Tests

1. **Test coverage**: missing tests for new behavior, untested edge cases, non-deterministic tests
2. **Scope creep**: changes outside the active sub-task's stated scope or done-when criteria
3. **Duplication**: new code that replicates existing utilities or patterns in the codebase
4. **Abstraction quality**: leaky abstractions, broken encapsulation, parameter sprawl, misleading names
5. **Unnecessary complexity**: over-engineered solutions, dead code, magic values without constants

## Phase 4: Aggregate and Write

Wait for the spawned `@explore` agent(s) to complete — one for a small diff, all three for a parallel fan-out. Then:

1. **Deduplicate**: if two agents flagged the same root cause, keep the more specific finding and drop the duplicate.
2. **Sort by severity**: P0 → P1 → P2 → P3. Within a severity, correctness and security findings come first.
3. Write the aggregated findings to artifact `review.md`, preserving its structure.

If there are no actionable findings, say so directly and approve.
