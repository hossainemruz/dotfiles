# Task PR Review

Use this delta only for a caller-authorized `remediation-enabled` full-PR review. Never run `taskctl`, edit source or `plan.md`, create lifecycle state, or implement findings.

## Required Context

- Require the complete raw PR projection, exact Task/PR IDs and branch, agreed diff base/scope, requirements, validation expectations, and ensured `review.md` path.
- Accept either the normal gate—every earlier planned Step completed or skipped and exactly one explicitly accepted final planned implementation Step still `ready_for_review`—or a branch-associated completed PR.
- If a consequential field is missing, return `status: blocked` with each exact missing field. Never reconstruct Task state or read all of `plan.md`.

## Scope and Artifact

- Review the branch's full diff against the agreed base, covering every Step in this PR and no other PR. Optional focus may prioritize analysis but cannot omit relevant changed code. Findings apply to the integrated PR, not to an originating Step.
- Preserve the supplied `review.md` template headings, replace stale review prose, and record mode `remediation-enabled`, Task/PR IDs, branch, verdict, and every actionable finding. Do not retain review history or add sections.
- Return control after writing and reporting the review. On findings, the orchestrator alone may create the single corrective Step; on approval, create no state.

## Structured Handoff

End with:

- `status: review_complete|blocked`
- `mode: remediation-enabled`
- `verdict: approved|actionable_findings` when complete
- Task/PR IDs, branch, and `review_path`
- `findings`: every finding ID and severity, or `[]`
- validation performed and residual risk

The handoff findings must exactly match `review.md`. A blocked result names every exact missing field or concrete blocker.
