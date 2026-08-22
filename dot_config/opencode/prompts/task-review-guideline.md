# Workflow Review Guidelines

Apply this contract when the caller selects `mode: workflow`. For `mode: ad-hoc`, use the code-review skill's ordinary scoped-review contract instead.

## Required Workflow Context

- Require Task and Subtask IDs, the frozen Subtask contract, relevant requirements, applicable durable decisions, agreed diff scope, changed-file manifest, current implementation outcome, current validation results, residual risks, and prior findings needed to verify remediation.
- Treat caller-supplied context as authoritative workflow scope. Return `status: blocked` with every exact missing field rather than running `taskctl`, reading workflow artifacts, or reconstructing Task history.
- Remain source-read-only and stateless. Never run `taskctl`, edit source, persist review results, mutate lifecycle state, question the user, implement findings, or delegate work.

## Review Behavior

- Review the complete Subtask diff against the agreed base. Optional focus may prioritize analysis but cannot omit relevant changed code.
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
- `task_id` and `subtask_id`
- `findings`: stable ID, severity, `blocking: true|false`, title, `path:line`, impact, evidence, rationale, and remediation guidance
- `validation_assessment`
- `residual_risks`
- `missing_context`

Do not claim persistence, lifecycle changes, human acceptance, or completion.
