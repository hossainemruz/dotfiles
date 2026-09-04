# OpenCode Agent Workflow

## Status

`open-source` is the default primary agent because most work is on public open-source projects. It remains explicit and separate because its provider may retain prompts and repository context for training. Use `general` instead for work that should use the delegated agent workflow or should not be sent through that provider.

There is no persistent workflow control plane. The active primary agent owns the current conversation, and `todowrite` is only session-local activity tracking.

## Primary Agents

### Open Source

`open-source` works autonomously by default and does not delegate unless the user explicitly asks. This keeps its use and any cross-provider context sharing visible.

### General

`general` is the delegating primary agent for advice, investigation, review, and ad-hoc implementation. It owns requirements interpretation, user questions, scope decisions, specialist routing, and the final response.

## Specialists

| Agent | Responsibility |
| --- | --- |
| `explore` | Retrieve bounded repository evidence without making implementation decisions. |
| `advisor` | Resolve one precise, high-leverage implementation decision. |
| `builder` | Implement clear bounded changes using the default implementation model. |
| `builder-terra` | Implement with Terra when explicitly requested. |
| `builder-sol` | Implement highest-impact critical work or use Sol when explicitly requested. |
| `reviewer` | Independently review correctness, security, and code quality. |
| `reviewer-glm` | Perform a faster review with GLM when explicitly requested. |
| `expert-reviewer` | Review exceptional highest-impact changes or perform expert review when explicitly requested. |
| `executor` | Run exact validation commands and return concise evidence. |
| `executor-flash` | Run validation with the fast executor when explicitly requested. |

Specialists do not question the user or delegate to one another. The calling primary supplies complete bounded context and remains responsible for decisions.

## Delegated Implementation

General implements directly only when work is localized, mechanically clear, low risk, free of unresolved behavioral choices, and straightforward to validate. Otherwise it uses Builder after gathering fresh repository evidence directly or through Explorer.

When complexity comes from one consequential unresolved decision, General uses Advisor for that precise decision and then resumes the same Builder session with the accepted directive. Builder sessions are also retained for review-feedback remediation.

Every delegated implementation is validated through Executor and independently reviewed through Reviewer. Material revisions invalidate affected validation and review approval, so both are rerun. Automated remediation stops after three consecutive `changes_requested` cycles and returns to the user.

## Commands

- `/review` performs an ordinary independent review of an explicit scope or unambiguous working-tree diff.
- `/simplify` reviews the current branch for high-confidence simplification opportunities after correctness and security.
- `/expert-review` invokes the exceptional expert reviewer for an explicit or unambiguous scope.
