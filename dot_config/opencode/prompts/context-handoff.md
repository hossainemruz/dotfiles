# Delegation Context Handoffs

Every new specialist session starts without the caller's conversation context. Supply one complete bounded packet and require a structured result; never ask a specialist to reconstruct history or infer omitted scope. Preserve and resume the selected Builder or Builder-high session for review feedback on the same implementation workstream.

## Common Packet

Include the fields relevant to the delegated role:

- `role` and `mode: workflow|ad-hoc`.
- Exact objective and expected result.
- Authoritative requirements, acceptance criteria, user decisions, and applicable durable decisions.
- For workflow mode, exact Task key, Subtask ID, frozen contract, accepted dependency outcomes, and current lifecycle feedback.
- In-scope behavior, explicit non-goals, prohibited changes, and conditions that require `blocked` or escalation rather than wider work.
- Repository root or key, current branch and HEAD when relevant, agreed comparison base or base-resolution policy, and pre-existing staged, unstaged, or untracked changes that must be preserved.
- Focused repository evidence with relevant files, symbols, and `path:line` references. Label observations as freshness-bound evidence, not authority to reinterpret requirements.
- Expected or current changed-file manifest, prior findings or feedback, validation working directory, exact known commands, expected behavior, and the role-specific output contract.

Use expected touchpoints as guidance rather than a strict file allowlist unless the scope requires one. Send only phase-relevant information, not chat transcripts, complete Task history, raw logs, or unrelated files.

## Handoff Discipline

- The calling primary agent owns requirements interpretation, routing, user questions, and scope decisions. Specialists never own workflow state, question the user, or delegate. A reused Builder session may retain implementation context but never becomes authoritative for requirements or lifecycle state.
- Curate and normalize specialist results before using them in another packet. Do not blindly forward an entire response as authority.
- Distinguish authoritative requirements and accepted decisions from repository evidence, implementation proposals, review guidance, and unaccepted implementation decisions.
- Require a specialist to report every missing field when blocked. Resume the same Builder session with corrected or review context for the same workstream. Start a fresh specialist session only when no reusable session exists, the role changes, or the Builder tier must be deliberately escalated; then provide a complete packet.
- Preserve identified pre-existing working-tree changes. If overlapping dirty changes cannot be distinguished safely, stop rather than overwrite them.
- Any source revision invalidates affected validation and prior review approval. Revalidate and independently re-review material revisions.

## Role-Specific Minimums

- Explorer receives one factual question, orientation, starting points, and scope limits; it returns concise evidence without recommendations.
- Planner receives an explicit planning authorization, clarified requirements, non-goals, evidence, accepted decisions and outcomes, and any mutable pending suffix.
- Advisor receives one precise decision question, the proposed approach, meaningful alternatives, evidence, constraints, and affected scope.
- Builder or Builder-high receives the implementation contract, acceptance criteria, evidence, decisions, working-tree context, scope limits, feedback, and validation expectations. Review remediation resumes the implementation session with the current findings, validation, source state, and any authoritative context changes.
- Executor receives only the exact working directory, exact commands, and the evidence to report.
- Reviewer or Expert Reviewer receives the requirements, accepted decisions, agreed diff scope and base, changed files, implementation result, current validation, residual risks, and prior findings needed to verify remediation.
