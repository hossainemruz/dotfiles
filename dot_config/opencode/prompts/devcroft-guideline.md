# Devcroft MCP Guidelines

**Purpose:** Use Devcroft as the sole canonical persistence and lifecycle boundary for Tasks and Subtasks.

## Access Boundary

- Call `devcroft_*` tools directly from Orchestrator only. Never ask a specialist to call the MCP, mutate workflow state, or reconstruct records.
- Never run `taskctl`, edit legacy workflow artifacts, or maintain parallel workflow state. `todowrite` may show session activity but is not canonical.
- Every mutation names an exact Task key and, when applicable, Subtask ID. Never infer a globally selected Task.
- Use `devcroft_list_repositories` to resolve repository keys and `devcroft_list_tasks` to locate candidate Tasks. If more than one candidate remains, ask the user rather than guessing.
- Treat mutation responses as authoritative for resulting state, allowed actions, and next action. Request a fresh context projection only when the next phase needs it.

## Tool Routing

- `devcroft_create_task`: create a draft Task from the complete initial request and known repository keys.
- `devcroft_list_repositories`: discover valid repository keys before Task creation or repository-association updates.
- `devcroft_list_tasks`: list compact Task candidates by repository or status when an exact Task key is not already present in the conversation or command arguments.
- `devcroft_get_context`: request exactly one of `summary`, `planning`, `work`, `review`, or `human`; do not emulate projections from chat history.
- `devcroft_update_task`: replace the complete requirements record, persist bounded research, update repository associations, append a durable decision, or cancel a Task. Never send a partial requirements replacement as though it were a patch.
- `devcroft_apply_plan`: establish the initial ordered plan or atomically replace only the pending suffix. Preserve active and completed Subtasks exactly.
- `devcroft_update_subtask_state`: perform legal lifecycle transitions, record blockers or resolutions, and attach explicit human feedback. Use `escalate_review_budget` only after human intervention authorizes another automated review cycle.
- `devcroft_record_review`: atomically record the current implementation outcome, validation, verdict, and evidence-backed findings. Use repository-relative evidence paths and stable record IDs.

## Payload Integrity

- Requirements updates are complete replacements: preserve stable requirement and question IDs, include every current requirement with its acceptance criteria, include every open question with an answer or `null`, and set readiness to `ready` only when no unanswered question blocks execution.
- Research records contain only `id`, `summary`, `findings`, and `implications`; condense Planner recommendations, alternatives, risks, and assumptions into those accepted fields. Findings use stable IDs and evidence entries with a valid repository key, repository-relative path, and nullable line range.
- Plan entries preserve stable Subtask IDs and provide exact requirement IDs, dependency Subtask IDs, repository keys, and validation expectations. Never send rich Planner-only fields that the tool schema does not accept.
- Review outcomes contain only `id`, `summary`, `decisionIds`, structured `deviations`, and `residualRisks`; changed-file manifests and `future_impact` remain routing context rather than unsupported payload fields. Review records use three linked stable IDs: `validation.outcomeId` equals `outcome.id`, while `review.outcomeId` and `review.validationId` reference those records. Map specialist snake-case output to the MCP's exact field names instead of passing it through blindly.
- Before recording an outcome with implementation decisions, allocate its stable outcome ID, append each decision through `devcroft_update_task` with `activation.scope: outcome` and that outcome ID, then include those decision IDs in the recorded outcome. Use Task-scoped activation only for immediately active durable Advisor directives.
- The MCP review payload has no separate review-kind field. When the standard-versus-expert distinction matters, state it concisely in the review summary rather than inventing an unsupported property.

## Context Discipline

- `summary` is for status and next-action reporting.
- `planning` is for initial planning or pending-suffix revision.
- `work` is the canonical packet for the active Subtask before implementation or remediation.
- `review` is the stored review packet; add the current unrecorded implementation result and validation when dispatching a reviewer.
- `human` is the approval packet shown before explicit acceptance.
- If the server returns `context_too_large`, reduce the requested scope. On `invalid_state` or `ambiguous_context`, refresh context or ask the user; never work around transition validation.

## Persistence Rules

- Persist executable requirements before planning, then persist Planner research and apply the ordered plan.
- Persist a durable Advisor decision only when it affects multiple Subtasks, establishes an invariant, changes or supplements the plan, selects a meaningful architectural alternative, or is likely to be reconsidered.
- Record every completed automated review, including approval. Do not mutate source after approval without rerunning validation and review.
- Explicit human acceptance is the only authority to transition a Subtask from `ready_for_human_review` to `completed`.
- If implementation changes invalidate pending work, revise or confirm the pending plan suffix before completing the current Subtask so the durable workflow cannot lose that obligation.
- Do not store chat transcripts, full diffs, raw command output, absolute paths, environment values, credentials, or secrets in MCP records.

## Error Handling

- Follow the server's returned retryability and next action for `not_found`, `invalid_argument`, `invalid_state`, `ambiguous_context`, `context_too_large`, `review_budget_exhausted`, and `internal` errors.
- On `review_budget_exhausted`, stop automation and request human intervention. Do not retry, reset, or bypass the budget yourself.
- After every mutation, report the resulting Task/Subtask state, changed record IDs when useful, and the one permitted next action.
