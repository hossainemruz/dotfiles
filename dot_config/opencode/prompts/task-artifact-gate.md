# taskctl Workflow Gate

Use `taskctl` only for requests concerning the selected Task, research,
planning, Step implementation, PR review, validation, progress, or Task
artifacts. Do not invoke it for unrelated work. Run `taskctl context` for
Task/PR work; for `/next-step` or direct Step feedback, follow it with
`taskctl step get` and use the returned artifact paths. Direct Step feedback is
handled in conversation with `taskctl step revise`, validation, self-review, and
resubmission—not `review.md`. A corrective Step created by `/review-pr` may be
started only by the user's `/address-review` invocation, never `/next-step`.
Never scan the vault or edit
`task.yaml` or the generated `plan.md` progress block. Create optional artifacts
with `taskctl artifact ensure`, and make every lifecycle transition with
`taskctl`. Preserve artifact structure and user prose. Keep repository changes
separate from artifact and lifecycle updates.
