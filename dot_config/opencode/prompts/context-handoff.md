# Delegation Context Handoffs

Every new specialist session starts without the caller's conversation context. Supply one complete bounded packet and require a structured result; never ask a specialist to reconstruct history or infer omitted scope. Preserve and resume the selected Builder pool session for review feedback on the same implementation workstream.

## Common Packet

Include the fields relevant to the delegated role:

- `role`, exact objective, and expected result.
- Authoritative requirements, acceptance criteria, user decisions, and applicable accepted decisions.
- In-scope behavior, explicit non-goals, prohibited changes, and conditions that require `blocked` or escalation rather than wider work.
- Repository root, current branch and HEAD when relevant, agreed comparison base or base-resolution policy, and pre-existing staged, unstaged, or untracked changes that must be preserved.
- Focused repository evidence with relevant files, symbols, and `path:line` references. Label observations as freshness-bound evidence, not authority to reinterpret requirements.
- Expected or current changed-file manifest, prior findings or feedback, validation working directory, exact known commands, expected behavior, and the role-specific output contract.

Use expected touchpoints as guidance rather than a strict file allowlist unless the scope requires one. Send only phase-relevant information, not chat transcripts, complete conversation history, raw logs, or unrelated files.

## Handoff Discipline

- The calling primary agent owns requirements interpretation, routing, user questions, and scope decisions. Specialists do not question the user or delegate. A reused Builder session may retain implementation context but never becomes authoritative for requirements.
- Curate and normalize specialist results before using them in another packet. Do not blindly forward an entire response as authority.
- Distinguish authoritative requirements and accepted decisions from repository evidence, implementation proposals, review guidance, and unaccepted implementation decisions.
- Require a specialist to report every missing field when blocked. Resume the same Builder session with corrected or review context for the same workstream. Start a fresh specialist session only when no reusable session exists, the role changes, or the Builder tier must be deliberately escalated; then provide a complete packet.
- Preserve identified pre-existing working-tree changes. If overlapping dirty changes cannot be distinguished safely, stop rather than overwrite them.
- Step exhaustion does not end a specialist session. When a result reports that the specialist's maximum step limit was reached, or its output was cut off before the required output contract, resume the same session by passing the returned task ID as `task_id` with a short continuation delta naming the remaining work and current validation state. The step budget resets on each dispatch. Do not re-dispatch the same workstream as a fresh complete packet; start a fresh session only when the resume call fails.
- Any source revision invalidates affected validation and prior review approval. Revalidate and independently re-review material revisions.

## Accepted Advisor Directives

When an Advisor directive is accepted for implementation, propagate it as a structured `accepted_advisor_directive`, never as a free-form summary. Keep the selected decision together with the fields below so the implementing model cannot reopen or reinterpret settled judgment:

- Always: `decision_question`, `selected_decision`, `required_invariants`, `implementation_boundaries`, `prohibited_changes`, and `validation_requirements`.
- Usually: `rationale` and `residual_risks`.
- When it informed the decision or Advisor discovered it while investigating: the relevant `evidence` with `path:line` references.
- When Builder could plausibly rediscover the tempting alternative: `rejected_alternative`.
- When useful: `affected_scope`.
- Never forward `missing_context`; resolve it with the caller first or return the decision to Advisor.

## Role-Specific Minimums

- Explorer receives one factual question, orientation, starting points, and scope limits; it returns concise evidence without recommendations.
- Advisor receives one precise decision question, the proposed approach, meaningful alternatives, evidence, constraints, and affected scope.
- Builder pool member (`builder`, `builder-terra`, `builder-sol`) receives the implementation contract, acceptance criteria, evidence, accepted decisions as structured advisor directives when applicable, working-tree context, scope limits, feedback, and validation expectations. Review remediation resumes the implementation session with the current findings, validation, source state, and any authoritative context changes. Advisor resolution likewise resumes the same implementation session with the accepted Advisor directive as a decision delta rather than starting a fresh Builder.
- Executor pool member (`executor`, `executor-flash`) receives only the exact working directory, exact commands, and the evidence to report.
- Reviewer pool member (`reviewer`, `reviewer-glm`, `expert-reviewer`) receives the requirements, accepted decisions, agreed diff scope and base, changed files, implementation result, current validation, residual risks, and prior findings needed to verify remediation.

## Model pool

The task tool has no runtime model parameter, so each role × model combination is a separate subagent. Pool members share the role's prompt, permissions, and steps; only `model` (and cost-driven `variant`) differs.

- Builder pool: `@builder` (`opencode-go/glm-5.3-flash` high, default), `@builder-terra` (`openai/gpt-5.6-terra` high, on explicit request), `@builder-sol` (`openai/gpt-5.6-sol` high, for critical tasks or on explicit request).
- Reviewer pool: `@reviewer` (`openai/gpt-5.6-terra` xhigh, default), `@reviewer-glm` (`opencode-go/glm-5.3-flash` max, on explicit request), `@expert-reviewer` (`openai/gpt-5.6-sol` high, for critical tasks or on explicit request; adds the expert-reviewer guideline).
- Executor pool: `@executor` (`openai/gpt-5.6-luna`, default), `@executor-flash` (`opencode-go/deepseek-v4-flash`, on explicit request).
- The caller's default routing applies unless the user names a pool model for the request ("use sol as builder", "review with glm", "validate with flash"); a user override wins for that request and its follow-ups.
- Stay on the selected pool member for the whole workstream: resume the same session for remediation, Advisor deltas, and re-review. Never stack two pool members on the same work in one cycle.
- Accepted shorthands are `glm` for glm members, `sol` for sol members, `terra` for terra members, and `flash`/`deepseek` for executor-flash. Anything else: ask, don't guess.
