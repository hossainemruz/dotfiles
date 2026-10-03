# OpenCode Agent Workflow

## Status

`general` is the default primary agent, running on `opencode-go/deepseek-v4.1-flash` with variant `max`. Its provider may retain prompts and repository context for training.

There is no persistent workflow control plane. The active primary agent owns the current conversation, and `todowrite` is only session-local activity tracking.

## Primary Agents

### General

`general` is the primary agent for advice, investigation, review, and ad-hoc implementation. It owns requirements interpretation, user questions, scope decisions, and the final response. It gathers evidence itself or through `explore`, makes the edits directly, runs bounded validation, and sends non-trivial changes to `reviewer` or high-impact changes to `expert-reviewer`.

## Specialists

| Agent | Model | Responsibility |
| --- | --- | --- |
| `explore` | `opencode-go/deepseek-v4.1-flash` (high) | Retrieve bounded repository evidence without making implementation decisions. |
| `reviewer` | `opencode-go/deepseek-v4.1-flash` (max) | Independently review correctness, security, and code quality for non-trivial changes. Source-read-only. |
| `expert-reviewer` | `openai/gpt-6.1-sol` (high) | Expert review of high-impact changes: security or authorization boundaries, compatibility and public contracts, concurrency, data integrity and migrations, module seams, and broad cross-cutting refactors. Source-read-only. |

Specialists do not question the user or delegate to one another. The calling primary supplies complete bounded context and remains responsible for decisions.

## Workflow

General gathers repository evidence directly or through Explorer, implements the change itself, runs bounded validation with the repository's own commands, and sends non-trivial changes to Reviewer for an independent pass; high-impact changes go to Expert Reviewer instead, so each revision gets exactly one review tier. Findings return to General to address; a material revision is revalidated and re-reviewed. There is no separate builder, executor, or advisor tier.
