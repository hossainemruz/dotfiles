# Temporary taskctl Bridge

**Purpose:** Emulate the Devcroft persistence boundary until the MCP exists without exposing taskctl or workflow artifacts to specialists.

## Backend Boundary

- Run every `taskctl` command directly in Orchestrator. Never dispatch a workflow agent or include taskctl commands in a specialist handoff.
- Treat taskctl as canonical for its Task, PR, Step, and artifact hierarchy. Store only bridge-only fields in `workflow-bridge.json`; do not duplicate taskctl status there.
- Resolve one selected Task at a time. Use the absolute artifact paths returned by taskctl and never scan the vault or infer another Task.
- Preserve taskctl templates, generated progress markers, and user-authored prose. Never edit `task.yaml` directly.

## Compatibility Model

- A Devcroft Task maps to one taskctl Task.
- A Devcroft Subtask maps to one taskctl PR. New plans create exactly one planned implementation Step inside each PR; that Step is a temporary backend detail rather than a second user-facing unit of work.
- For a legacy PR with multiple Steps, treat the whole PR as one Subtask. Intermediate Step transitions are backend bookkeeping; logical human acceptance occurs only after the PR's implementation is complete, current validation passes, and automated PR review approves.
- Task status remains derived from taskctl plus the bridge-only blocker and automated-approval fields.

## Logical Operations

- `create_task`: run `taskctl new <title>`, resolve the resulting Task context, and write clarified requirements to `task.md`.
- `get_context(summary|planning)`: use one `taskctl context` projection and read only the relevant artifact sections and bridge fields.
- `get_context(work)`: use one `taskctl step context` projection plus the frozen PR/Subtask contract, relevant artifacts, accepted dependency outcomes, feedback, and bridge fields.
- `get_context(review|human)`: use one `taskctl pr context` projection plus the current unrecorded implementation result, validation, latest durable review, and bridge fields.
- `update_task`: edit only the appropriate canonical artifact. Requirements belong in `task.md`; research and durable Advisor decisions belong in `research.md`.
- `apply_plan`: ensure `plan.md`, write the detailed ordered Subtask plan using matching `### PR-NNN: Title` and single `#### STEP-NNN: Implement Subtask` headings, then send the identical hierarchy to `taskctl plan apply` over standard input.
- `update_subtask_state`: use taskctl PR/Step lifecycle commands for represented transitions and update only bridge-only fields when taskctl has no equivalent.
- `record_review`: ensure and update `review.md` yourself with the current implementation outcome, validation, review kind, attempt, verdict, findings, decisions, deviations, future impact, and residual risks; then update bridge-only review fields.

## Bridge Record

Place `workflow-bridge.json` beside the Task artifacts. Create it only when a bridge-only field is first needed, serialize it deterministically, and keep this shape:

```json
{
  "schema_version": 1,
  "task_id": "TASK-ID",
  "subtasks": {
    "PR-001": {
      "blocker": null,
      "review_attempts": 0,
      "automated_review": null,
      "future_impact": "none",
      "accepted_outcome": null
    }
  }
}
```

- `automated_review` is `null` or a compact object containing `kind`, `verdict`, and the current validation summary. Set it to `null` before any implementation or remediation edit.
- `accepted_outcome` remains `null` until explicit human acceptance, then stores only the concise implementation summary, durable decisions, deviations, and `future_impact` needed by later Subtasks.
- `blocker` is `null` or a concise safe reason. Do not store chat transcripts, source diffs, raw command output, absolute source paths, environment values, credentials, or secrets.
- Bridge writes are not atomic or schema-validated like the future MCP. Re-read the narrow record before mutation, preserve unknown Subtask entries, reject an unknown `schema_version`, and stop rather than guessing after conflicting or malformed state.

## State Projection

- `pending`, `in_progress`, and `completed` come from taskctl.
- Logical `blocked` overrides taskctl presentation when the Subtask's bridge `blocker` is non-null.
- Logical `ready_for_human_review` requires the final implementation Step to be `ready_for_review`, current passing validation in `review.md`, and bridge `automated_review.verdict: approved`.
- Starting or revising a Subtask clears its blocker and automated approval. `changes_requested` increments `review_attempts`; approval resets the count to zero. Human-requested changes also reset the count to zero and start a new bounded cycle.

## Lifecycle Conventions

- Select a PR with `taskctl context` and `taskctl pr list --json`; start only the first eligible pending PR with `taskctl pr start <pr-id>` on the current named non-default branch. Never manage Git branches.
- Use the taskctl start transition documented by the installed CLI for a pending Step. If a required exact form is absent from supplied instructions, inspect only that command's help rather than guessing.
- After implementation and validation, use `taskctl step submit` to establish backend `ready_for_review`, then run automated review before showing the result to the user.
- On automated or human changes, use `taskctl step revise`, clear bridge approval, remediate, validate, resubmit, and review again. Do not create corrective Steps.
- Only explicit human acceptance authorizes `taskctl step complete`. For a legacy multi-Step PR, intermediate Step completion is allowed only to advance backend bookkeeping after validated implementation; it is not logical Subtask acceptance.
- When a required pending-suffix revision cannot be represented by taskctl's legal append-only operations, preserve current state, report the limitation, and request human intervention instead of editing `task.yaml` or allowing plan/state divergence.

## Compact Result Contract

After every mutation report the resulting logical state, changed Task/PR/Step or artifact identifiers, `allowed_actions`, and one `next_action`. Obtain a fresh projection only when the next phase requires it.
