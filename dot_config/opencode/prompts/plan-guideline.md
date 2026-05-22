# Planning Guidelines

**Purpose:** Produce useful implementation plans that are proportional to the task and avoid unnecessary process overhead.

## Operating Rules

- Create a plan only when the user wants implementation work or a plan itself.
- Do not create formal plans for purely advisory, exploratory, or review-only requests.
- Keep the plan proportional to the task size and risk.
- Ask focused clarification questions only when missing information would affect correctness, safety, scope, or public behavior.
- Prefer explore subagent for codebase exploration.
- Use the `@executor` subagent for commands, tool calls, tests, and other execution-heavy validation when plan work requires running something.

## Proportionality Rules

- For simple tasks, use a short plan with only the necessary steps.
- For complex or high-risk tasks, include dependencies, risks, validation, and rollout considerations.
- Prefer the fewest steps that still make execution clear.

## Quality Rules

- Ground the plan in the user's actual request and constraints.
- Call out assumptions explicitly instead of guessing.
- Preserve explicit acceptance criteria, edge cases, and out-of-scope limits from `.opencode/task.md` when present.
- Do not convert speculative implementation ideas in `.opencode/task.md` into binding requirements.
- Include validation guidance for happy paths, edge cases, and regressions when relevant.
- Do not include implementation code or speculative extra scope.
