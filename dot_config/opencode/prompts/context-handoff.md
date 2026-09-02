# Delegation Context Handoffs

Every new specialist session starts without the caller's conversation context. Supply one complete bounded packet and require a structured result; never ask a specialist to reconstruct history or infer omitted scope. Preserve and resume the selected Builder or Builder-high session for review feedback on the same implementation workstream.

## Caller Scoping

Two kinds of callers share this file, and every packet must match what its caller can actually own:

- A **workflow caller** owns canonical Task state through `devcroft_*` tools and delegates work on planned Subtasks. It selects `mode: workflow` for such delegations and supplies the complete workflow-mode fields below. When a call or command explicitly names an ad-hoc scope, even this caller sends `mode: ad-hoc` and omits workflow framing.
- An **ad-hoc caller** holds no `devcroft_*` tools, invokes no Planner, and owns no canonical Task state. Every delegation it makes is `mode: ad-hoc`; it never sets `workflow`, and it does not introduce Task keys, Subtask IDs, frozen contracts, lifecycle phases, or other workflow bookkeeping into handoffs or reported results.

No packet blends modes. If you catch yourself writing workflow fields into an ad-hoc packet, stop: either the work genuinely belongs to a managed Subtask owned by the workflow caller, or those fields do not belong there.

## Common Packet

Include the fields relevant to the delegated role:

- `role`, exact objective, expected result, and `mode: workflow|ad-hoc`. Only a caller owning Devcroft Task state may select `workflow`; every other caller selects `ad-hoc`.
- Authoritative requirements, acceptance criteria, user decisions, and applicable durable decisions.
- Workflow-mode additions only: exact Task key and Subtask ID written as self-contained labeled data — recipients cannot resolve these identifiers anywhere else, so spell out what each refers to — plus the frozen contract, accepted dependency outcomes, and current lifecycle feedback in concrete terms.
- In-scope behavior, explicit non-goals, prohibited changes, and conditions that require `blocked` or escalation rather than wider work.
- Repository root (plus its repository key for workflow packets), current branch and HEAD when relevant, agreed comparison base or base-resolution policy, and pre-existing staged, unstaged, or untracked changes that must be preserved.
- Focused repository evidence with relevant files, symbols, and `path:line` references. Label observations as freshness-bound evidence, not authority to reinterpret requirements.
- Expected or current changed-file manifest, prior findings or feedback, validation working directory, exact known commands, expected behavior, and the role-specific output contract.

Use expected touchpoints as guidance rather than a strict file allowlist unless the scope requires one. Send only phase-relevant information, not chat transcripts, complete Task or session history, raw logs, or unrelated files.

## Handoff Discipline

- The calling primary agent owns requirements interpretation, routing, user questions, and scope decisions. Specialists never own canonical records or workflow state, question the user, or delegate. A reused Builder session may retain implementation context but never becomes authoritative for requirements or lifecycle state.
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
- When Task-backed: `affected_subtasks`.
- Never forward `missing_context`; resolve it with the caller first or return the decision to Advisor.

## Role-Specific Minimums

Ad-hoc callers dispatch no Planner; its line below exists solely for the workflow caller.

- Explorer receives one factual question, orientation, starting points, and scope limits; it returns concise evidence without recommendations.
- Planner (workflow caller only) receives an explicit planning authorization, clarified requirements, non-goals, evidence, accepted decisions and outcomes, and any mutable pending suffix.
- Advisor receives one precise decision question, the proposed approach, meaningful alternatives, evidence, constraints, and affected scope.
- Builder or Builder-high receives the implementation contract, acceptance criteria, evidence, accepted decisions as structured advisor directives when applicable, working-tree context, scope limits, feedback, and validation expectations. Review remediation resumes the implementation session with the current findings, validation, source state, and any authoritative context changes. Advisor resolution likewise resumes the same implementation session with the accepted Advisor directive as a decision delta rather than starting a fresh Builder.
- Executor receives only the exact working directory, exact commands, and the evidence to report.
- Reviewer or Expert Reviewer receives the requirements, accepted decisions, agreed diff scope and base, changed files, implementation result, current validation, residual risks, and prior findings needed to verify remediation.
