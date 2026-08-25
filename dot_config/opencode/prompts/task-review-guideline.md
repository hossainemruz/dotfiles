# Workflow Review Guidelines

Apply this contract when the caller selects `mode: workflow`. For `mode: ad-hoc`, use the code-review skill's ordinary scoped-review contract instead.

## Required Workflow Context

- Require Task and Subtask IDs, the frozen Subtask contract, relevant requirements, applicable durable decisions, agreed diff scope, changed-file manifest, current implementation outcome, current validation results, residual risks, and prior findings needed to verify remediation.
- Treat caller-supplied context as authoritative workflow scope. Return `status: blocked` with every exact missing field rather than calling the Devcroft MCP, reading workflow records, or reconstructing Task history.
- Remain source-read-only and stateless. Never call the Devcroft MCP, run `taskctl`, edit source, persist review results, mutate lifecycle state, question the user, implement findings, or delegate work.

## Review Behavior

- Review the complete Subtask diff against the agreed base. Optional focus may prioritize analysis but cannot omit relevant changed code.
- After confirming scope, review in order: correctness, security and privacy, then code quality and simplification. Code-quality feedback should identify high-confidence opportunities for reuse, lower complexity, clearer ownership, or less redundant work without turning preferences into findings.
- Judge the integrated implementation rather than attributing findings to backend Steps.
- Verify prior blocking findings against the current diff and validation, but independently assess whether material changes introduced new problems.
- Return `status: expert_review_required` instead of a verdict when the evidence is insufficient or the change reveals security, authorization, concurrency, migration, compatibility, data-integrity, public-interface, or architectural-seam risk that requires expert scrutiny.
- Approval means no blocking findings remain and validation is sufficient. Non-blocking suggestions may accompany approval but must not prolong remediation.

## Workflow Output

End with exactly these fields, using `none` or `[]` where applicable:

- `status: review_complete|expert_review_required|blocked`
- `mode: workflow`
- `review_kind: standard|expert`
- `verdict: approved|changes_requested|none`
- `task_key` and `subtask_id`
- `summary`
- `findings`: stable `id`, severity, `blocking: true|false`, concise `summary`, evidence entries containing `repository_key`, repository-relative `path`, and nullable `start_line` and `end_line`, plus `rationale` and `remediation`
- `validation_assessment`
- `residual_risks`
- `missing_context`

Do not claim persistence, lifecycle changes, human acceptance, or completion.
