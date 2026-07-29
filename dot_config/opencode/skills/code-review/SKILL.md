---
name: code-review
description: Guideline for evidence-based PR-level and ad hoc code review.
---

Produce high-signal reviews focused on real risk. For a `taskctl`-scoped review, review the completed current PR as a whole; never run a separate review for an individual Step. For unrelated reviews, do not invoke `taskctl`.

## Core Rules

- Review changed code first, then only the context needed to judge impact.
- Delegate tests, builds, lint checks, and noisy or multi-command validation to `@executor`; batch related commands into one request when practical. Run a shell command directly only when its output is short and required for review analysis, or when delegation would merely return the same output. Never delegate review judgment, diagnosis, or fixes.
- Use `@explore` only for bounded factual codebase tracing that would otherwise require broad context. Pass the full review context: scope/base, relevant Task or PR projection, changed areas, requirements and constraints, evidence already gathered, the exact factual question, and the required concise `path:line` output. Never delegate review judgment, diagnosis, severity, fixes, or approval, and never require the explorer to run `taskctl` or reconstruct omitted context.
- Use a caller-provided diff/range when available. Otherwise determine the base robustly and inspect the full PR diff.
- Use structured multi-pass thinking within one reviewer instance. Do not spawn reviewer subagents or repeat full rereads for every pass.
- Before each tool turn, issue all independent diff inspections, searches, reads, and other operations whose inputs are already known together. Build the changed-file manifest once, inspect changed hunks before whole files, and do not reread unchanged ranges.
- Be skeptical, not speculative. Report only actionable findings with evidence.
- Prefer a few high-confidence findings; limit output to the five most important unless there are additional independent blockers.
- Flag changes outside the PR scope, but do not expand the review to unrelated work.
- Do not attempt source fixes or lifecycle transitions except for the corrective-Step setup defined below.
- If no diff or review scope is available, ask instead of scanning broadly.

## Task PR Workflow

The caller must select one mode: `remediation-enabled` for an initial completed-PR review, or `verification` after explicit acceptance of its corrective Step.

- Run `taskctl pr context` exactly once and require a branch-associated completed PR. Do not substitute broad `taskctl context`, combine it with `taskctl step get`, or refresh after success. Treat the projection as the working contract and do not read all of `plan.md` by default.
- Review the current PR branch's full diff against its agreed base, including every Step in that PR; never review one Step or include other PRs.
- Run `taskctl artifact ensure review`, then replace the latest review prose in `review.md` with the evidence-backed PR-wide review while preserving template headings and identifying the PR and branch.
- Never edit repository source or begin remediation. Return validation, verdict, findings, PR/branch, corrective-Step state, and readiness to the orchestrator.
- In `remediation-enabled` mode, actionable findings create exactly one Step with `taskctl step add --pr <pr-id> --title "Address PR review findings"`; append that returned Step's exact detailed heading under the PR in `plan.md`, referencing every finding in `review.md`. Add no Step without findings, and return control for automatic orchestrator remediation.
- In `verification` mode, never add a corrective Step or trigger automatic remediation. Record and report any remaining findings for explicit user direction; this mode ends the automatic review cycle.

## Review Passes

Scale depth to the diff's risk and size. Keep small docs/config/localized diffs lightweight; inspect risky, broad, security-sensitive, or behavior-changing diffs more deeply.

1. **Scope**: confirm the diff matches the PR's planned Steps, expected files/tests are present, and unrelated changes are flagged.
2. **Correctness**: check logic, assumptions, edge cases, regressions, data flow, and integration with existing behavior.
3. **Security and privacy**: check secrets, injection, unsafe file/network behavior, permission/auth boundaries, and data exposure.
4. **Robustness and performance**: check error handling, races, cleanup, unnecessary work, hot-path slowdowns, and scalability.
5. **Maintainability and validation**: check avoidable complexity, duplication, boundary violations, missing validation, and test coverage gaps.

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
