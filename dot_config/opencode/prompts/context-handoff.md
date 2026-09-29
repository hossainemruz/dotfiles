# Delegation Context Handoffs

Every new specialist session starts without the caller's conversation context. Supply one complete bounded packet and require a structured result; never ask a specialist to reconstruct history or infer omitted scope.

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

- The calling primary agent owns requirements interpretation, routing, user questions, and scope decisions. Specialists do not question the user or delegate.
- Curate and normalize specialist results before reusing them. Do not blindly forward an entire response as authority.
- Distinguish authoritative requirements and accepted decisions from repository evidence, review guidance, and unaccepted proposals.
- Require a specialist to report every missing field when blocked. Resume the same specialist session with corrected or follow-up context for the same workstream; start a fresh session only when no reusable session exists, the role changes, or the scope changes enough to need a complete packet.
- Preserve identified pre-existing working-tree changes. If overlapping dirty changes cannot be distinguished safely, stop rather than overwrite them.
- Step exhaustion does not end a specialist session. When a result reports that the specialist's maximum step limit was reached, or its output was cut off before the required output contract, resume the same session by passing the returned task ID as `task_id` with a short continuation delta naming the remaining work and current validation state. The step budget resets on each dispatch. Do not re-dispatch the same workstream as a fresh complete packet; start a fresh session only when the resume call fails.
- Any source revision invalidates affected validation and prior review approval. Revalidate and re-review material revisions.

## Role-Specific Minimums

- `@explore` receives one factual question, orientation, starting points, and scope limits; it returns concise evidence with `path:line` references and no recommendations.
- `@reviewer` receives the requirements, accepted decisions, agreed diff scope and base, changed files, implementation result, current validation, residual risks, and prior findings needed to verify remediation. Resume the same Reviewer session for re-review of a material revision.
