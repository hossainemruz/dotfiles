---
name: code-review
description: Evidence-based PR review and code review for a working-tree diff, caller-scoped changes, or review findings.
---

Produce high-signal reviews focused on real risk. Review source without editing it, and never run `taskctl`, mutate workflow state, persist review artifacts, question the user, or delegate work.

## Core Rules

- Review changed code first, then only the context needed to judge impact.
- Reuse caller-supplied requirements, plans, relevant files and symbols, repository evidence, diff scope, and validation results before discovering more. Perform only the targeted factual tracing needed to judge the supplied diff. Return insufficient confidence rather than delegating or inventing missing validation.
- Use a caller-provided diff/range when available. Otherwise determine the base robustly and inspect only the requested scope.
- Build the changed-file manifest once, inspect changed hunks before whole files, batch independent reads, and avoid rereading unchanged ranges.
- Be skeptical, not speculative. Report only actionable findings with evidence.
- Request additional tests only when an observable behavior has a plausible, meaningful regression path that existing validation does not protect. Do not optimize for coverage percentage or private-unit-test count.
- Prefer a few high-confidence findings; limit output to the five most important unless there are additional independent blockers.
- Flag changes outside the PR scope, but do not expand the review to unrelated work.
- If no diff or review scope is available, return `status: blocked` with the missing scope instead of scanning broadly or questioning the user.

## Review Passes

Scale depth to the diff's risk and size. Keep small docs/config/localized diffs lightweight; inspect risky, broad, security-sensitive, or behavior-changing diffs more deeply.

1. **Scope**: confirm the diff matches the requested change and flag unrelated work.
2. **Correctness**: check logic, assumptions, edge cases, regressions, data flow, and integration with existing behavior.
3. **Security and privacy**: check secrets, injection, unsafe file/network behavior, permission/auth boundaries, and data exposure.
4. **Robustness and performance**: check error handling, races, cleanup, unnecessary work, hot-path slowdowns, and scalability.
5. **Maintainability and validation**: check avoidable complexity, duplication, boundary violations, missing validation, and observable behavior left exposed to a plausible regression.

## Do Not Report

- Style-only preferences without real risk
- Hypothetical issues without a plausible failure path
- Duplicate findings for the same root cause
- Low-value nits that do not materially improve quality
- Coverage targets, missing tests for private helpers, or tests of implementation details without an unprotected behavioral risk

## Finding Bar and Severity

Raise a finding only when it is real or highly likely, causes meaningful harm, has concrete evidence, and has a reasonable fix.

- **[P0] Blocking**: likely production breakage, data corruption, or exploitable security issue
- **[P1] High**: serious user, operational, or security impact
- **[P2] Medium**: meaningful but non-blocking risk
- **[P3] Low**: valid low-impact improvement

For each finding include a stable ID, severity, `blocking: true|false`, title, `path:line`, impact, evidence, rationale, and specific remediation guidance. Sort by severity. Blocking status depends on whether the finding must be resolved for the requested behavior to be safe and correct, not severity alone. Approve when no blocking findings remain; valid non-blocking suggestions may accompany approval.

## Structured Handoff

End with `status: review_complete|blocked`, the caller-selected mode (default `ad-hoc`), `verdict: approved|changes_requested` when complete, `findings` with every ID, severity, and blocking status or `[]`, validation assessment, residual risk, and missing context. Use `changes_requested` only when at least one finding is blocking. A blocked result names each exact missing field or concrete blocker.

## Final Check

- Every finding has evidence, clear impact, justified severity, and no duplicate root cause.
