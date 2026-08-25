# OpenCode Development Workflow

## Status

This document records the active OpenCode workflow and Devcroft MCP interface. General is the default primary for unplanned ad-hoc work. Orchestrator is selected for explicitly planned Tasks, and Devcroft is their canonical persistence and lifecycle boundary. The former taskctl bridge is retired and must not be used as a fallback.

### Active Devcroft integration

Orchestrator is the sole Devcroft MCP client. Specialists remain stateless, receive bounded context packets from Orchestrator, and return structured results without direct workflow access.

- Devcroft stores Tasks, ordered Subtasks, requirements, research, durable decisions, implementation outcomes, validation, reviews, blockers, feedback, and lifecycle state.
- Automated review and remediation occur before explicit human acceptance.
- The MCP validates transitions, review budgets, and pending-suffix replacement. Orchestrator follows returned allowed actions and never bypasses a rejected transition.
- `taskctl`, `workflow-bridge.json`, and legacy workflow artifacts are not canonical and are not read or written by workflow agents.

## Goals

- Use Sol only where its reasoning quality materially improves the result.
- Keep planning explicit and, when authorized, plan an entire Task as multiple independently reviewable Subtasks.
- Keep lifecycle state and durable workflow records behind a small MCP interface.
- Make Orchestrator the only agent with access to the Devcroft MCP.
- Keep specialist agents stateless and supply them with explicit context and output contracts.
- Give each agent a semantic role, role-specific instructions, and the narrowest permissions it needs.
- Return compact scope-specific context and explicit next actions instead of complete Task history.
- Bound automated remediation so persistent disagreement returns to the user rather than looping indefinitely.

## Terminology

- **Task:** The complete user objective, requirements, research, plan, and durable architectural decisions.
- **Subtask:** An independently implementable and reviewable portion of a Task. A Subtask will normally correspond to one source-control PR, but the workflow does not model the external PR directly.
- **Agent:** A semantic workflow role with a selected model, reasoning variant, instructions, and permission envelope.

`Subtask` is preferred over `Step` because Subtasks can have dependencies without implying that every item is a strictly sequential operation.

## Ownership

### General

General is the default primary agent for unplanned advice, investigation, review, and ad-hoc implementation. It may perform trivial low-risk changes directly or delegate bounded work through Explorer, Advisor, Builder, Builder-high, Executor, Reviewer, Expert Reviewer, and Simplifier. General never calls Devcroft, invokes Planner, reads workflow records, or coordinates Task lifecycle state.

### Orchestrator

Orchestrator is the workflow control plane and sole Devcroft MCP client. It owns:

- User clarification and acceptance.
- Task and Subtask lifecycle transitions.
- Model and role selection.
- Sol usage and escalation decisions.
- Complete specialist handoffs.
- Persistence of requirements, research, plans, durable advisor decisions, outcomes, validation, and reviews.
- Reporting workflow state, validation, findings, and blockers to the user.

### Specialists

Planner, Explorer, Advisor, Builder, Builder-high, Remediator, Reviewer, Expert Reviewer, Executor, and Simplifier never mutate workflow state or call the Devcroft MCP. Each specialist receives a complete bounded context packet and returns a structured result to the calling primary agent.

Specialists should not delegate to one another. In particular, Builder returns an `advisor_required` result when it encounters an unresolved architectural decision; the calling primary agent decides whether to invoke Advisor.

## Context Handoffs

Every specialist invocation receives a complete bounded packet because delegated agents do not inherit the caller's conversation context. The calling primary agent curates specialist results before using them in another packet; agent output is not blindly forwarded as authoritative context.

Every packet identifies the role and `workflow|ad-hoc` mode, exact objective, authoritative requirements and acceptance criteria, in-scope and prohibited changes, applicable accepted decisions, focused repository evidence, working-tree and comparison-base context, prior findings or feedback, validation expectations, and the exact output contract. Workflow packets additionally include the Task key, Subtask ID, frozen contract, accepted dependency outcomes, and relevant lifecycle context. Ad-hoc Builder packets use `none` for Task and Subtask IDs.

Requirements, accepted user decisions, durable decisions, and frozen contracts are authoritative. Explorer observations are freshness-bound repository evidence. Advisor directives govern only their supplied decision scope. Review findings are evidence and remediation guidance rather than automatically trusted patch specifications. Unaccepted implementation decisions do not constrain later work unless Orchestrator explicitly persists an immediately applicable durable invariant.

Packets include the repository root or key, branch and HEAD when relevant, agreed base or base-resolution policy, and known staged, unstaged, and untracked changes. Specialists preserve pre-existing changes and return `blocked` when overlapping dirty work cannot be distinguished safely. Expected touchpoints guide discovery but are not strict file allowlists unless the scope explicitly requires one.

## Agents

Agent names describe their semantic workflow responsibilities. This keeps routing, prompts, permissions, and reports understandable without requiring the caller to reinterpret a model-oriented name on every invocation.

| Agent | Model and variant | Permissions | Responsibility |
| --- | --- | --- | --- |
| `general` | GPT-5.6 Terra high | User interaction, repository editing, and ad-hoc specialist dispatch | Own unplanned ad-hoc work without Devcroft lifecycle access. |
| `orchestrator` | GPT-5.6 Terra high | Devcroft MCP, user interaction, repository editing, and specialist dispatch | Own explicit planning and planned Task lifecycle, context handoffs, and escalation decisions. |
| `planner` | GPT-5.6 Sol xhigh | Read-only repository inspection | Research and decompose a complete Task into reviewable Subtasks. |
| `explore` | DeepSeek v4 Flash | Read-only repository inspection | Retrieve bounded repository evidence without making implementation decisions. |
| `advisor` | GPT-5.6 Sol high | Read-only repository inspection | Resolve one precise, high-leverage implementation decision. |
| `builder` | DeepSeek v4 Flash | Repository editing | Implement one clear bounded workflow or ad-hoc change. |
| `builder-high` | GPT-5.6 Terra xhigh | Repository editing | Implement difficult, cross-cutting, integration-heavy, or reasoning-intensive workflow or ad-hoc changes. |
| `remediator` | GPT-5.6 Luna high | Repository editing within supplied finding scope | Address bounded, concrete review findings without reopening implementation design. |
| `reviewer` | GPT-5.6 Terra xhigh | Read-only repository inspection and read-only Git diff commands | Perform the default independent review. |
| `expert-reviewer` | GPT-5.6 Sol high | Read-only repository inspection and read-only Git diff commands | Perform risk-triggered or explicitly requested expert review. |
| `executor` | GPT-5.6 Luna medium | Exact command execution only | Run tests, builds, and other bounded validation commands. |

`builder` is preferred over `worker` because its responsibility is specifically implementation and remediation rather than arbitrary background work. Semantic agents may use shared prompt fragments and skills, but each agent retains a role-specific prompt and least-privilege permission set.

## Planning

Sol xhigh is the dedicated Planner. Planning occurs only after `/plan`, an explicit user request to plan or replan, or explicit confirmation of an Orchestrator recommendation to replan. Executable requirements, stale evidence, Builder uncertainty, and `future_impact: replan_required` do not independently authorize Planner.

Before invoking Planner, Orchestrator should use Explorer to gather relevant repository evidence. Planner receives clarified requirements and that evidence in one complete handoff and should normally return research and the multi-Subtask plan together.

Planner does not question the user directly. If requirements remain blocked, Planner returns the smallest set of blocking questions to Orchestrator. Orchestrator asks the user and resumes the same planning workstream with the answers.

The initial plan is ordered. Once implementation starts, an explicitly authorized Planner invocation may revise only the pending Subtask suffix. The active Subtask and completed Subtasks remain immutable, while pending Subtasks may be added, removed, reordered, or replaced. `devcroft_apply_plan` validates this rule without requiring a separate replanning tool. A requested change to the active frozen contract requires a user scope decision rather than pending-suffix replanning.

## Advisor

Advisor is invoked proactively when an unresolved decision is likely to benefit code architecture, correctness, or long-term maintainability. An Advisor invocation must have a precise decision question rather than a general request to improve the implementation.

### Advisor triggers

Invoke Advisor when a decision involves one or more of:

- Module ownership or placement of a new seam.
- Multiple plausible approaches with material maintenance trade-offs.
- Public interfaces or backward compatibility.
- Authentication, authorization, privacy, or trust.
- Persistence, migrations, or data integrity.
- Concurrency, retries, idempotency, or distributed behavior.
- A pattern likely to be repeated by later Subtasks.
- A choice that would be expensive to reverse.

Do not invoke Advisor when Planner already resolved the decision or the repository has an unambiguous established pattern. Builder may identify a new decision during implementation, but it returns an `advisor_required` packet rather than invoking Advisor itself.

### Durable advisor decisions

Persist an advisor decision when it affects multiple Subtasks, establishes an invariant future work must preserve, changes or supplements the plan, selects between meaningful architectural alternatives, or is likely to be reconsidered later.

Do not persist local implementation advice that is evident from the resulting code and has no effect outside the current Subtask.

A durable decision contains:

- Decision question.
- Selected decision.
- Concise rationale.
- Required invariants.
- Affected Subtasks.
- A rejected alternative when the distinction remains relevant.

Durable advisor decisions are appended to the Task through `devcroft_update_task` with Task-scoped activation and become active immediately. Builder-reported implementation decisions are appended with outcome-scoped activation using the prospective outcome ID, then referenced by `devcroft_record_review`; they and recorded deviations become active cross-Subtask context only after the user accepts that Subtask. Unaccepted implementation outcomes must not constrain later work.

## Implementation

Builder uses DeepSeek v4 Flash for clear bounded work. Builder-high uses Terra xhigh for difficult, cross-cutting, integration-heavy, or reasoning-intensive work. Both share the same stateless contract and permission boundary. Implementation complexity and breadth select the Builder tier; risk alone does not.

Before each fresh planned implementation or remediation workstream, Orchestrator obtains the Subtask context and asks Explorer to reconcile it with the current repository. This is a focused freshness check and relevant-file discovery pass, not a repetition of the original Task research.

For a planned Subtask, Orchestrator implements directly only when work is localized, mechanically clear, low risk, free of unresolved behavioral choices, and straightforward to validate. Otherwise the selected Builder receives requirements, plan context, repository evidence, applicable Advisor directives, scope limits, working-tree context, and validation expectations. It returns changed files, implementation summary, requested validation, residual risks, any blocker or Advisor request, implementation decisions, deviations from the plan, and `future_impact: none|context_only|replan_required` for Orchestrator routing.

When an implementation result has `future_impact: replan_required`, Orchestrator reports the exact impact and requests explicit replanning authorization. After authorization, Planner revises or confirms the pending suffix through `devcroft_apply_plan` before the current Subtask is completed. Cross-Subtask invariants that must apply immediately are persisted as durable decisions.

Executor runs exact validation commands after implementation and after remediation. It returns commands, exit codes, and relevant output without making architectural or lifecycle decisions.

### General ad-hoc implementation

General uses the same implementation and risk-routing principles without Devcroft state. It implements genuinely trivial low-risk work directly. It uses Builder for clear bounded work and Builder-high for difficult or cross-cutting work, after obtaining fresh repository evidence itself or through Explorer. Advisor resolves only a precise consequential decision and never performs broad planning.

Every delegated ad-hoc implementation is validated through Executor and independently reviewed by Reviewer or risk-triggered Expert Reviewer. General may omit independent review only for its own genuinely trivial low-risk direct edit. Findings return to General, Builder, or Builder-high according to implementation complexity; workflow-only Remediator is not used. Stop after at most three consecutive `changes_requested` cycles and ask the user rather than looping indefinitely.

## Review

Terra xhigh is the default Reviewer. Sol high is the Expert Reviewer. Review depth is selected by impact risk independently of the implementation tier.

Expert review replaces the default review when high risk is known before review. It is not automatically stacked after a complete default review. Escalate to Expert Reviewer when:

- Security, authorization, concurrency, migration, compatibility, or data-integrity behavior is involved.
- The implementation introduces an important new module seam or public interface.
- A default-review finding is disputed or uncertain.
- The default Reviewer reports insufficient confidence.
- The user explicitly requests expert review.

Review receives the requirements, Subtask context, agreed diff scope and base, current branch and HEAD when relevant, changed files, implementation result, working-tree context, and validation results. Devcroft does not store full diffs, so Orchestrator invalidates approval after any source revision and requests another review after material remediation.

The remediation loop continues until there are no blocking findings, not until there are no suggestions. Automatic review permits at most three consecutive `changes_requested` verdicts before requiring human intervention.

Each finding should include a stable ID, severity, blocking status, evidence, rationale, and remediation guidance. Orchestrator records both approval and actionable findings through the MCP.

### Remediation routing

Review guidance is evidence and direction, not an automatically trusted patch specification. Orchestrator dispatches Remediator when all blocking findings are concrete, localized, low risk, and do not require a new architectural or behavioral decision. Examples include a missed guard, a localized error path, a test correction, a small compatibility fix with explicit expected behavior, or mechanical cleanup directly required by a finding.

Orchestrator returns ordinary broader findings to Builder and difficult, cross-cutting, integration-heavy, or reasoning-intensive findings to Builder-high. This includes findings that change architecture, public behavior, persistence, authorization, concurrency, or broad implementation structure; span several modules; are unclear or disputed; require an Advisor decision; or follow a failed remediation attempt. Findings from Expert Reviewer use the appropriate Builder tier unless explicitly classified as mechanical.

Remediator receives the current findings, relevant context, affected files, scope limits, and validation expectations. It must map each change to finding IDs and return unresolved findings rather than widening scope. Executor validates every remediation. Default Reviewer verifies the result unless an unresolved finding still meets the expert-review triggers, in which case Expert Reviewer verifies it.

Automated review allows at most three consecutive `changes_requested` verdicts. `devcroft_record_review` tracks the attempt count and moves the Subtask to `blocked` when the budget is exhausted. Approval resets the count; human-requested changes begin a new bounded automated-review cycle. Further work after exhaustion requires user intervention.

Automated approval and human acceptance remain separate. If the user requests changes during human review, Orchestrator records the feedback, returns the Subtask to `in_progress`, dispatches Remediator, Builder, or Builder-high using the same routing rules, reruns validation, and requires another automated review before requesting human acceptance again.

## Devcroft MCP Interface

The MCP server is named `devcroft`. Its internal tool names omit the prefix because OpenCode registers MCP tools using the server name as a prefix.

The MCP is a persistence and workflow-validation module. It stores canonical records, validates legal transitions, produces bounded context, and reports allowed next actions. It does not question the user, perform research or planning, dispatch agents, edit source code, execute validation, review changes, manage source branches, or infer human intent.

| Internal tool | OpenCode tool | Responsibility |
| --- | --- | --- |
| `create_task` | `devcroft_create_task` | Create a draft Task from the initial request and repository keys. |
| `list_repositories` | `devcroft_list_repositories` | List valid repository keys for Task association and plan records. |
| `list_tasks` | `devcroft_list_tasks` | List compact Task candidates, optionally filtered by repository or status. |
| `get_context` | `devcroft_get_context` | Return bounded Task or Subtask context for a requested scope. |
| `update_task` | `devcroft_update_task` | Replace requirements or research, update repository associations, append a durable decision, or cancel the Task. |
| `apply_plan` | `devcroft_apply_plan` | Establish the initial ordered plan or atomically revise only its pending Subtask suffix. |
| `update_subtask_state` | `devcroft_update_subtask_state` | Start, block, submit for human review, return for human feedback, reopen, or complete a Subtask. |
| `record_review` | `devcroft_record_review` | Store the reviewed implementation outcome, validation, verdict, and findings; track attempts; and enforce the remediation budget. |

The MCP implementation validates legal state transitions even though they share one `update_subtask_state` tool. Separate `start_subtask` and `accept_subtask` tools are unnecessary.

Every mutation explicitly names its Task and, when applicable, its Subtask. The server returns an ambiguity error rather than guessing a target, and it does not persist a globally selected Task.

### Context projections

`devcroft_get_context` returns deterministic scope-specific projections rather than complete Task history:

| Scope | Contents |
| --- | --- |
| `summary` | Task state, compact Subtask progress, blockers, allowed actions, and next action. |
| `planning` | Requirements, research, active durable decisions, accepted Subtask outcomes, and the pending plan suffix. |
| `work` | Current Subtask contract, relevant requirements and research, applicable decisions, accepted dependency outcomes, current feedback, and validation expectations. |
| `review` | Current Subtask contract, latest recorded implementation outcome, validation, residual risks, applicable feedback, and prior findings needed for review. The caller supplies the current unrecorded implementation result. |
| `human` | Human-facing approval packet containing the implementation summary, automated approval, validation, decisions, deviations, residual risks, and allowed decisions. |

Mandatory context is never silently truncated. An over-broad request returns `context_too_large`; history pagination and semantic retrieval are deferred until an observed need justifies them.

Mutation responses remain compact and return the resulting state, changed record IDs, `allowed_actions`, and `next_action`. Callers request a fresh context projection only when the next phase needs it.

### Error contract

Workflow failures use a small stable vocabulary:

```text
not_found
invalid_argument
invalid_state
ambiguous_context
context_too_large
review_budget_exhausted
internal
```

Every error returns a safe message, whether it is retryable, and a permitted next action such as `refresh_context`, `reduce_context_scope`, `request_human_intervention`, or `revise_future_plan`.

### Storage guarantees

Canonical records include a schema version and are decoded strictly. The implementation validates changes in memory, serializes deterministically, and performs atomic temporary-file replacement under a local mutation lock. Unknown schema versions and invalid transitions are rejected before writing.

The store does not contain chat transcripts, full source diffs, raw command output, absolute source paths, environment values, credentials, or secrets. Task revisions, Git synchronization, source commit binding, and persisted idempotency receipts are deferred until demonstrated workflow needs justify them.

### MCP permissions

The Devcroft MCP is denied globally and enabled only for Orchestrator:

```json
{
  "permission": {
    "devcroft_*": "deny"
  },
  "agent": {
    "orchestrator": {
      "permission": {
        "devcroft_*": "allow"
      }
    }
  }
}
```

These permissions control OpenCode tool access. The MCP implementation should not expose an alternate state-mutating CLI or directly writable state store to specialist agents.

## State Model

Subtasks use the following states:

```text
pending
in_progress
ready_for_human_review
blocked
completed
```

Agent review remains an activity rather than a persistent lifecycle state. Task status should be derived from its plan and Subtask states where practical, avoiding duplicate state that can become inconsistent.

Subtasks are ordered, and only the first eligible pending Subtask may enter `in_progress`. Starting a Subtask freezes its contract. Human feedback and review findings guide revisions without silently replacing that contract.

`ready_for_human_review` requires current automated approval and validation. Human acceptance moves the Subtask directly to `completed`; human changes return it to `in_progress`. Completing a Subtask activates its accepted implementation decisions and deviations. Any required pending-plan revision must be persisted before completion so that obligation cannot be lost between sessions.

## Workflow

```mermaid
sequenceDiagram
    participant User
    participant Orchestrator
    participant MCP as Devcroft MCP
    participant Planner
    participant Explorer
    participant Advisor
    participant Builders as Builder / Builder-high
    participant Remediator
    participant Executor
    participant Reviewer

    User->>Orchestrator: Create Task
    Orchestrator->>MCP: devcroft_list_repositories
    Orchestrator->>MCP: devcroft_create_task(initial request, repository keys)
    loop Until requirements are executable
        Orchestrator->>User: Blocking questions and recommendation
        User-->>Orchestrator: Clarification
        Orchestrator->>MCP: devcroft_update_task(requirements)
    end

    User->>Orchestrator: Explicitly authorize /plan
    Orchestrator->>Explorer: Gather planning evidence
    Explorer-->>Orchestrator: Repository evidence
    Orchestrator->>Planner: Requirements and evidence
    Planner-->>Orchestrator: Research and multi-Subtask plan
    Orchestrator->>MCP: devcroft_update_task(research)
    Orchestrator->>MCP: devcroft_apply_plan(plan and Subtasks)

    User->>Orchestrator: Implement Subtask
    Orchestrator->>MCP: devcroft_update_subtask_state(in_progress)
    Orchestrator->>MCP: devcroft_get_context(work)
    Orchestrator->>Explorer: Reconcile context with repository
    Explorer-->>Orchestrator: Relevant files, symbols, and current evidence

    alt Unresolved high-leverage decision
        Orchestrator->>Advisor: Decision packet
        Advisor-->>Orchestrator: Directive and invariants
        opt Decision is durable
            Orchestrator->>MCP: devcroft_update_task(decision)
        end
    end

    alt Trivial, localized, and low risk
        Orchestrator->>Orchestrator: Implement frozen Subtask directly
    else Clear bounded implementation
        Orchestrator->>Builders: Context, evidence, and directive
        Builders-->>Orchestrator: Implementation result
    else Difficult or cross-cutting implementation
        Orchestrator->>Builders: Dispatch Builder-high with the same bounded contract
        Builders-->>Orchestrator: Implementation result
    end
    Orchestrator->>Executor: Run validation
    Executor-->>Orchestrator: Commands, exit codes, and output

    loop Until completed or blocked
        Orchestrator->>MCP: devcroft_get_context(review)
        Orchestrator->>Reviewer: Review context, current outcome, and validation
        Reviewer-->>Orchestrator: Verdict and findings
        opt Implementation decisions
            Orchestrator->>MCP: devcroft_update_task(decision, outcome activation)
        end
        Orchestrator->>MCP: devcroft_record_review(outcome and review)
        alt Changes requested and budget remains
            alt Findings are bounded and mechanical
                Orchestrator->>Remediator: Findings and bounded context
                Remediator-->>Orchestrator: Remediation result by finding ID
            else Findings require implementation reasoning
                Orchestrator->>Builders: Findings and complete work context using the appropriate tier
                Builders-->>Orchestrator: Revised implementation result
            end
            Orchestrator->>Executor: Rerun affected validation
            Executor-->>Orchestrator: Validation result
        else Review budget exhausted
            MCP-->>Orchestrator: blocked and request_human_intervention
            Orchestrator->>User: Report blocker and unresolved findings
        else Approved and validation passes
            Orchestrator->>MCP: devcroft_update_subtask_state(ready_for_human_review)
            Orchestrator->>MCP: devcroft_get_context(human)
            Orchestrator->>User: Present human review packet
            alt User accepts
                User-->>Orchestrator: Accept
                opt Pending work is affected
                    Orchestrator->>User: Request explicit replanning authorization
                    User-->>Orchestrator: Authorize replanning
                    Orchestrator->>Planner: Confirm or revise pending suffix
                    Planner-->>Orchestrator: Updated pending plan
                    Orchestrator->>MCP: devcroft_apply_plan(pending suffix)
                end
                Orchestrator->>MCP: devcroft_update_subtask_state(completed)
            else User requests changes
                User-->>Orchestrator: Feedback
                Orchestrator->>MCP: devcroft_update_subtask_state(in_progress, feedback)
                alt Feedback is bounded and mechanical
                    Orchestrator->>Remediator: Human feedback and bounded context
                    Remediator-->>Orchestrator: Remediation result
                else Feedback requires implementation reasoning
                    Orchestrator->>Builders: Human feedback and complete work context using the appropriate tier
                    Builders-->>Orchestrator: Revised implementation result
                end
                Orchestrator->>Executor: Rerun affected validation
                Executor-->>Orchestrator: Validation result
            end
        end
    end
```

## Legacy Bridge Retirement

The OpenCode workflow now uses Devcroft directly. The Orchestrator prompt and commands must reference only `devcroft_*` tools, while specialists remain stateless and MCP-denied.

The integration requires:

- Deny `taskctl` access and remove the temporary bridge prompt from active configuration.
- Use the corresponding `devcroft_*` tool for every workflow read or mutation.
- Migrate any still-active legacy Task data into Devcroft before deleting its external artifacts; this is an explicit data-migration operation, not an agent fallback path.
- Preserve each semantic agent's role-specific prompt, shared prompt fragments, and least-privilege permissions.
- Preserve routing of every workflow specialist invocation through Orchestrator.
- Deny `devcroft_*` globally and allow it only for Orchestrator.
