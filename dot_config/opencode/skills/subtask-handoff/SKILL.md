---
name: subtask-handoff
description: Creates a self-contained implementation handoff for one approved sub-task using the approved task and plan.
permissions:
  edit: allow
---

Create a focused implementation handoff in `.opencode/subtask.md` for exactly one approved sub-task. The handoff must preserve the original task requirements so the implementation agent does not lose context.

## Core Rules

- Only prepare a handoff after `.opencode/task.md` and `.opencode/plan.md` exist or their contents are provided.
- The handoff must combine the relevant context from the approved task and the selected sub-task from the approved plan.
- Do not invent requirements, scope, constraints, dependencies, or design decisions.
- Ask only the minimum focused questions needed to identify the exact sub-task or resolve correctness-critical ambiguity.
- Keep the handoff self-contained so an implementation agent can execute it without reading the conversation.
- Do not modify any file other than `.opencode/subtask.md`.

## Workflow

1. Read the approved task specification and implementation plan.
2. Identify the exact sub-task to hand off.
3. Extract only the requirements, constraints, risks, and validations relevant to that sub-task.
4. Record dependencies on earlier sub-tasks or prerequisite changes.
5. Call out explicit non-goals so the implementation stays scoped to one PR.
6. Write a self-contained handoff to `.opencode/subtask.md`.

## Required Output Template

```markdown
# Sub-Task Handoff: [Clear sub-task title]

## Parent Task

- **Task Title:** [Title from task.md]
- **Problem Summary:** [Why this work exists]

## Selected Sub-Task

- **Sub-Task:** [Exact sub-task title from plan.md]
- **Objective:** [What this PR should accomplish]

## Relevant Requirements

- [Acceptance criterion, scope item, or constraint from task.md that applies here]

## Dependencies and Preconditions

- [Earlier sub-task, existing behavior, migration state, or prerequisite]

## In Scope for This PR

- [Concrete work this implementation should include]

## Out of Scope for This PR

- [Nearby work that must not be included]

## Risks and Areas Requiring Care

- [Edge case, compatibility issue, failure mode, or sensitive area]

## Implementation Notes

- [Relevant guidance from the approved plan only]

## Validation and Testing

- [Tests, checks, or verification needed for this sub-task]

## Done When

- [Observable conditions that mean this sub-task is complete]

## Open Questions

- [Only if important non-blocking uncertainty remains]
```

## Final Check

- The handoff is self-contained and references the approved task and plan.
- All included requirements are relevant to the selected sub-task.
- Scope is narrow enough for a single implementation PR.
- Out-of-scope items are explicit to prevent overbuilding.
