---
name: code-review
description: Guideline for evidence-based PR-level and ad hoc code review.
---

Produce high-signal reviews focused on real risk. For a Task-scoped review, use the caller-supplied mode and context below; never review an individual Step as the initial formal review. Reviewers never run `taskctl`.

## Core Rules

- Review changed code first, then only the context needed to judge impact.
- Delegate tests, builds, lint checks, and noisy or multi-command validation to `@executor`; batch related commands into one request when practical. Run a shell command directly only when its output is short and required for review analysis, or when delegation would merely return the same output. Never delegate review judgment, diagnosis, or fixes.
- Use `@explore` only for bounded factual codebase tracing that would otherwise require broad context. Pass the full review context: scope/base, relevant Task or PR projection, changed areas, requirements and constraints, evidence already gathered, the exact factual question, and the required concise `path:line` output. Never delegate review judgment, diagnosis, severity, fixes, or approval, and never require the explorer to run `taskctl` or reconstruct omitted context.
- Use a caller-provided diff/range when available. Otherwise determine the base robustly and inspect the diff required by the selected mode.
- Use structured multi-pass thinking within one reviewer instance. Do not spawn reviewer subagents or repeat full rereads for every pass.
- Before each tool turn, issue all independent diff inspections, searches, reads, and other operations whose inputs are already known together. Build the changed-file manifest once, inspect changed hunks before whole files, and do not reread unchanged ranges.
- Be skeptical, not speculative. Report only actionable findings with evidence.
- Request additional tests only when an observable behavior has a plausible, meaningful regression path that existing validation does not protect. Do not optimize for coverage percentage or private-unit-test count.
- Prefer a few high-confidence findings; limit output to the five most important unless there are additional independent blockers.
- Flag changes outside the PR scope, but do not expand the review to unrelated work.
- Do not attempt source fixes, Task lifecycle transitions, artifact setup, or `plan.md` edits.
- If no diff or review scope is available, ask instead of scanning broadly.

## Task PR Workflow

The caller must select one mode: `remediation-enabled` for an initial completed-PR review, or `verification` after explicit acceptance of its corrective Step.

- Require the caller to supply the complete raw PR projection, exact Task/PR IDs and branch, agreed diff scope/base, requirements, validation expectations, and an existing/ensured `review.md` path. Verification also requires the accepted corrective-Step context. If any consequential field is missing, return `status: blocked` naming the exact missing field; never reconstruct it with `taskctl` or broad artifact reads.
- In `remediation-enabled` mode, review the current PR branch's full diff against its agreed base, including every Step in that PR; never review one Step or include other PRs.
- In `verification` mode, inspect the original findings in `review.md`, the accepted corrective Step and remediation diff, directly affected context and dependencies, and targeted validation. Expand to the full PR only when remediation changes a shared boundary or evidence indicates a cross-cutting regression.
- Replace the supplied `review.md` review content with the evidence-backed, mode-scoped review while preserving its template headings and identifying the PR and branch. Do not retain stale review prose.
- Never edit repository source or begin remediation. Return validation, verdict, findings, PR/branch, and accepted corrective-Step context when applicable.
- In `remediation-enabled` mode, report actionable findings to the orchestrator; it alone decides and creates the single corrective Step. With no findings, approve and create no lifecycle state.
- In `verification` mode, report remaining findings for explicit user direction. Never request or trigger automatic remediation; this mode ends the automatic review cycle.

## Review Passes

Scale depth to the diff's risk and size. Keep small docs/config/localized diffs lightweight; inspect risky, broad, security-sensitive, or behavior-changing diffs more deeply.

1. **Scope**: confirm the diff matches the PR's planned Steps, expected files/tests are present, and unrelated changes are flagged.
2. **Correctness**: check logic, assumptions, edge cases, regressions, data flow, and integration with existing behavior.
3. **Security and privacy**: check secrets, injection, unsafe file/network behavior, permission/auth boundaries, and data exposure.
4. **Robustness and performance**: check error handling, races, cleanup, unnecessary work, hot-path slowdowns, and scalability.
5. **Maintainability and validation**: check avoidable complexity, duplication, boundary violations, missing validation, and observable behavior left exposed to a plausible regression.

## Review Voice

- Give a clear overall verdict and briefly state what most influenced it.
- Be candid about code that is unnecessarily clever, fragile, or especially well-designed, but do not inflate preferences into findings.
- After the formal findings, you may include one clearly labeled non-blocking design observation when it provides substantial value.
- Approval should still communicate confidence and any residual risk; avoid empty praise.

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

For each finding include a stable finding ID plus severity, title, `path:line`, impact, evidence, and a specific fix. If there are no actionable issues, approve directly.

## Structured Handoff

End with a machine-actionable block containing:

- `status: review_complete` or `status: blocked`
- `mode: remediation-enabled`, `verification`, or `ad-hoc`
- `verdict: approved` or `actionable_findings` when complete
- Task/PR IDs and branch when Task-backed
- `review_path` when Task-backed
- `findings`: every finding ID and severity, or `[]`
- validation performed and residual risk

The findings list must exactly account for the actionable findings written to `review.md`. A blocked result must name each exact missing field or concrete blocker.

## Final Check

- Every finding has evidence, clear impact, and justified severity.
- Duplicate and weak comments are removed.
- A remediation-enabled Task review covered the whole completed current PR. A verification review covered the remediation delta and affected context, expanding only when its risk or evidence required it.
