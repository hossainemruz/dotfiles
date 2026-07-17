---
description: Research implementation options before planning the current task.
agent: planner
subtask: true
---

Resolve the current task artifact directory from `.agent-task` as
`$HOME/agent-vault/<contents-of-.agent-task>`. Read `task.md` and any existing
`research.md` from that directory. Perform the research yourself. You may use
`@explore` for focused codebase evidence gathering, pattern lookup, and
similar-implementation discovery, but make the final approach decision
yourself. If `research.md` is missing, create it from
`$HOME/agent-vault/templates/research-template.md` and resolve template
variables using values from `task.md` metadata/frontmatter when available:
`{{TASK_ID}}`, `{{TASK_TITLE}}`, `{{PROJECT_NAME}}`, and `{{DATE}}`. Use the
current date for `{{DATE}}` if task metadata does not provide one. Once
`research.md` is present, explore the codebase and create or refresh
`research.md` in the same directory, preserving the existing research template
structure and user-authored content.

Treat `task.md` as the source of truth for goal, requirements, acceptance
criteria, constraints, and non-goals. Treat `research.md` as implementation
evidence and approach selection only; it must not expand or override task scope.

The research should:

- identify relevant components and existing patterns
- find similar implementations when useful
- compare viable implementation options with pros, cons, and risks
- list constraints and blocking open questions
- recommend one implementation approach with concise rationale
- call out implications for the later implementation plan and validation

Return a compact summary with:

- research title
- options considered
- recommended approach
- blocking open questions, if any
- recommended next command
