---
name: code-review
description: Guideline for reviewing code.
permissions:
  edit: allow
---

Produce high-signal, evidence-based reviews focused on real risk. Write the
findings in the current task artifact `review.md`. If `.agent-task` exists, use
the task artifact workflow.

## Core Rules

- Review changed code first, then only the context needed to judge impact.
- Be skeptical, not speculative.
- Report only actionable findings with evidence.
- Prefer a few high-confidence findings over many weak ones.
- If no diff or scope is provided, ask instead of scanning broadly.
- Do not modify any file other than the resolved artifact `review.md`.
- Preserve artifact `review.md` structure.

## Review Order

1. Correctness
2. Security & privacy
3. Robustness
4. Performance
5. Maintainability and test coverage

## Do Not Report

- Style-only preferences without real risk
- Hypothetical issues without a plausible failure path
- Duplicate findings for the same root cause
- Low-value nits that do not materially improve quality

## Finding Bar

Raise a finding only if the issue is real or highly likely, causes meaningful harm, can be explained clearly, and has a reasonable fix.

## Severity

- **[P0] Blocking**: likely production breakage, data corruption, or exploitable security issue
- **[P1] High**: serious user, operational, or security impact
- **[P2] Medium**: meaningful but non-blocking risk
- **[P3] Low**: valid low-impact improvement

If there are no actionable issues, say so directly and approve.

## Final Check

- Every finding has evidence and a clear impact.
- Severities are justified.
- Duplicate or weak comments are removed.
