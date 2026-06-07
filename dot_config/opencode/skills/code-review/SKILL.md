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
- Before reviewing any code, read the active sub-task from artifact `plan.md` to understand the intended scope, requirements, and done-when criteria.
- Review only the diff against the base branch; do not review unrelated files or context beyond what is needed to judge impact.
- Use structured multi-pass thinking within one reviewer instance. Do not spawn reviewer subagents or do full repeated rereads for every pass.
- Be skeptical, not speculative.
- Report only actionable findings with evidence.
- Prefer a few high-confidence findings over many weak ones.
- Limit output to the most important 5 findings unless there is a blocker or multiple independent high-impact issues.
- Flag scope creep if the diff includes changes outside the active sub-task, but do not expand the review to cover it.
- Keep findings scoped to the sub-task; do not raise issues that belong to a different sub-task or future work.
- Do not suggest next steps, attempt fixes, or decide what to do with findings. The caller decides.
- If no diff or scope is provided, ask instead of scanning broadly.
- Do not modify any file other than the resolved artifact `review.md`.
- Preserve artifact `review.md` structure.

## Review Passes

Scale depth to the diff's risk and size. Keep small docs/config/localized diffs lightweight; inspect risky, broad, security-sensitive, or behavior-changing diffs more deeply.

1. **Scope**: confirm the diff matches the requested task, required files/tests/docs are present, and unrelated changes are flagged.
2. **Correctness**: check logic, assumptions, edge cases, regressions, data flow, and integration with existing behavior.
3. **Security and privacy**: check secrets, injection risks, unsafe file/network behavior, permission/auth boundaries, and data exposure.
4. **Robustness and performance**: check error handling, race conditions, resource cleanup, unnecessary work, hot-path slowdowns, and scalability risks.
5. **Maintainability and validation**: check avoidable complexity, duplication, boundary violations, missing validation, and test coverage gaps.

## Do Not Report

- Style-only preferences without real risk
- Hypothetical issues without a plausible failure path
- Duplicate findings for the same root cause
- Low-value nits that do not materially improve quality

## Efficiency Rules

- Batch independent reads when gathering context.
- Read only the specific files and sections needed to confirm a finding.
- Do not re-read files you have already reviewed.
- Keep review work in this single reviewer instance; do not use parallel fan-out.
- Skip low-value nits and stop digging once all changed code has been evaluated through the review passes.
- Stop once all changed code has been evaluated against the sub-task criteria.

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
