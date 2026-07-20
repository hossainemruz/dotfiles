---
name: code-review
description: Guideline for evidence-based PR-level and ad hoc code review.
---

Produce high-signal reviews focused on real risk. For a `taskctl`-scoped review, review the completed current PR as a whole; never run a separate review for an individual Step. For unrelated reviews, do not invoke `taskctl`.

## Core Rules

- Review changed code first, then only the context needed to judge impact.
- For a Task PR review, run `taskctl context` once and require a branch-associated completed PR. Read `task.md`, `plan.md`, and relevant `research.md` evidence from the returned artifact paths.
- Review the current PR branch's full diff against its agreed base, including every Step in that PR. Do not include other PR branches or future work.
- Use a caller-provided diff/range when available. Otherwise determine the base robustly and inspect the full PR diff.
- Use structured multi-pass thinking within one reviewer instance. Do not spawn reviewer subagents or repeat full rereads for every pass.
- Be skeptical, not speculative. Report only actionable findings with evidence.
- Prefer a few high-confidence findings; limit output to the five most important unless there are additional independent blockers.
- Flag changes outside the PR scope, but do not expand the review to unrelated work.
- Do not attempt source fixes or lifecycle transitions unless the invoking workflow explicitly requires adding a corrective Step.
- If no diff or review scope is available, ask instead of scanning broadly.

## Review Passes

Scale depth to the diff's risk and size. Keep small docs/config/localized diffs lightweight; inspect risky, broad, security-sensitive, or behavior-changing diffs more deeply.

1. **Scope**: confirm the diff matches the PR's planned Steps, expected files/tests are present, and unrelated changes are flagged.
2. **Correctness**: check logic, assumptions, edge cases, regressions, data flow, and integration with existing behavior.
3. **Security and privacy**: check secrets, injection, unsafe file/network behavior, permission/auth boundaries, and data exposure.
4. **Robustness and performance**: check error handling, races, cleanup, unnecessary work, hot-path slowdowns, and scalability.
5. **Maintainability and validation**: check avoidable complexity, duplication, boundary violations, missing validation, and test coverage gaps.

## Do Not Report

- Style-only preferences without real risk
- Hypothetical issues without a plausible failure path
- Duplicate findings for the same root cause
- Low-value nits that do not materially improve quality

## Finding Bar and Severity

Raise a finding only when it is real or highly likely, causes meaningful harm, has concrete evidence, and has a reasonable fix.

- **[P0] Blocking**: likely production breakage, data corruption, or exploitable security issue
- **[P1] High**: serious user, operational, or security impact
- **[P2] Medium**: meaningful but non-blocking risk
- **[P3] Low**: valid low-impact improvement

For each finding include severity, title, `path:line`, impact, evidence, and a specific fix. If there are no actionable issues, approve directly.

## Final Check

- Every finding has evidence, clear impact, and justified severity.
- Duplicate and weak comments are removed.
- A Task review covered the whole completed current PR, not one Step.
