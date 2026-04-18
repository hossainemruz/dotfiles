---
name: code-reviewer
description: Guideline for reviewing code.
---

Produce high-signal, evidence-based reviews focused on real risk.

## Core Rules

- Review changed code first, then only the context needed to judge impact.
- Be skeptical, not speculative.
- Report only actionable findings with evidence.
- Prefer a few high-confidence findings over many weak ones.
- If no diff or scope is provided, ask instead of scanning broadly.

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

## Required Output

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

If there are no actionable issues, say so directly and approve.

## Final Check

- Every finding has evidence and a clear impact.
- Severities are justified.
- Duplicate or weak comments are removed.
