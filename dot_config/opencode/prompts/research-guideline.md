# Research Guidelines

**Purpose:** Explore enough codebase evidence and implementation options to choose a sound approach before creating an execution plan.

These rules apply to research work. They do not prohibit separate planning work
from updating the resolved artifact `plan.md`.

## Operating Rules

- Research only when the task has uncertainty, multiple plausible approaches, architecture risk, or unknown codebase patterns.
- If `.agent-task` exists, use the task artifact workflow and preserve `research.md` structure.
- When creating a missing `research.md`, copy `$HOME/agent-vault/templates/research-template.md` and resolve template variables from `task.md` metadata/frontmatter when available: `{{TASK_ID}}`, `{{TASK_TITLE}}`, `{{PROJECT_NAME}}`, and `{{DATE}}`. Use the current date for `{{DATE}}` if task metadata does not provide one.
- During research, modify only the resolved artifact `research.md`; do not modify repository source code or other artifacts.
- Treat artifact `task.md` as the source of truth for goal, requirements, acceptance criteria, constraints, and non-goals.
- Treat existing artifact `research.md` as prior evidence and user-authored context to preserve unless explicitly superseded.
- Do not invent requirements or expand task scope.
- Ask focused clarification questions only when missing information blocks choosing an approach.
- Use targeted `glob`, `grep`, and `read` calls; avoid broad scans and generated/noisy directories.
- You may use `@explore` for focused evidence gathering, pattern lookup, and similar-implementation discovery.
- Do not outsource approach selection: the current research/planning-capable agent must compare options, choose the recommendation, and write the rationale.
- Stop exploring once the recommendation is supported by concrete evidence.

## Research Content

Capture enough detail for the planning agent to produce a concrete plan without redoing discovery:

- relevant components and files
- existing patterns and conventions
- similar implementations
- constraints and compatibility concerns
- viable options considered, with pros, cons, and risks
- blocking open questions
- recommended approach and why alternatives were rejected
- plan and validation implications

## Proportionality Rules

- For small tasks, keep research brief and focus on the chosen approach.
- For complex or high-risk tasks, compare alternatives explicitly and document tradeoffs.
- Prefer concise evidence over exhaustive inventories.

## Final Check

- The recommendation is grounded in codebase evidence and task requirements.
- The research does not override `task.md` scope or acceptance criteria.
- Options and rejected alternatives are clear enough to prevent re-litigation during planning.
- Open questions are separated from assumptions.
- The resulting `research.md` can be used directly by `/plan`.
