---
name: planning
description: Writes clear, detailed, step-by-step implementation plans to .agents/tasks/plan.md so any human or agent can execute the task.
permissions:
  edit: allow
---

Create a practical execution plan in `.agents/tasks/plan.md`, not implementation code.

## Core Rules

- Plan only when the request needs implementation work or a formal plan.
- Do not modify any file other than `.agents/tasks/plan.md`.
- Do not invent scope, requirements, or constraints.
- Treat `.agents/tasks/task.md` as the implementation-agnostic requirements contract when it exists.
- Preserve explicit problem statements, in-scope items, acceptance criteria, edge cases, out-of-scope items, constraints, and open questions from `.agents/tasks/task.md` when present.
- If `.agents/tasks/task.md` includes implementation ideas, separate them from binding requirements instead of promoting speculative details into scope.
- Ask only the minimum clarification questions needed for correctness or scope.
- Keep the plan proportional: concise for simple work, detailed for complex work.
- Treat `.agents/tasks/task.md` as the source of truth for requirements when it exists.
- Include a concise requirements snapshot in the plan so each sub-task preserves the original intent.
- Map each sub-task to the specific requirements, constraints, or acceptance criteria it addresses.
- Use stable requirement IDs such as `R1`, `R2`, and `R3` in the Requirements Snapshot so sub-tasks can refer to them unambiguously.
- Make every sub-task self-contained enough that another agent can implement it directly from `plan.md` without a separate handoff file.
- Initialize every newly created sub-task with status `Pending`.
- If the work should be split across multiple PRs, keep each sub-task scoped tightly enough for one implementation pass.
- Prefer concrete validation commands or checks when known; otherwise describe the exact verification approach.

## Workflow

1. Identify the goal, requirements, constraints, risks, dependencies, and out-of-scope items.
2. If critical information is missing, ask focused numbered questions.
3. If `.agents/tasks/task.md` exists, extract a short requirements snapshot from it, including acceptance criteria, edge cases, out-of-scope boundaries, and constraints relevant to implementation, and assign stable IDs such as `R1`, `R2`, and `R3`.
4. Break the work into ordered sub-tasks with clear outcomes.
5. For each sub-task, list the related requirements so downstream agents can trace the work back to the approved task.
6. For each sub-task, include its objective, dependencies, in-scope work, explicit non-goals, key risks, implementation suggestions, and validation guidance.
7. Initialize each newly created sub-task as `Pending` and use explicit status markers such as `Pending`, `In Progress`, and `Completed` so agents can reliably pick the next sub-task.
8. Prefer concrete validation commands or checks when known.
9. Explain core concepts with appropriate code example when necessary.
10. Write a self-contained plan that can be executed without the conversation.

## Required Output Template

```markdown
# Plan: [Clear task title]

## Objective

[Goal and intended outcome]

## Requirements Snapshot

- **R1:** [Relevant requirement, acceptance criterion, or constraint from task.md]

## Scope

- [In-scope work]

## Assumptions and Constraints

- [Known assumptions, dependencies, constraints]

## Risks and Areas Requiring Care

- [Key risks, compatibility concerns, or failure modes]

## Core concepts

Explain core concepts with code level example if necessary.

## Sub-Tasks

### Sub-Task 1: [Clear title]

- **Status:** Pending
- **Objective:** [What this sub-task should accomplish]
- **Related Requirements:** [Requirement IDs or short labels from the Requirements Snapshot]
- **Dependencies and Preconditions:** [Earlier sub-task, existing behavior, migration state, or prerequisite]
- **In Scope for This Sub-Task:** [Concrete work this implementation should include]
- **Out of Scope for This Sub-Task:** [Nearby work that must not be included]
- **Instructions:** [Specific actions]
- **Acceptance Criteria:** [How to know it is done]
- **Cautionary Points (Risks & Edge Cases):** [Where to be careful]
- **Implementation Suggestions:** [Practical guidance if helpful]
- **Testing Suggestions:** [Concrete commands, checks, or verification steps]
- **Done When:** [Observable conditions that mean this sub-task is complete]

## Final Integration & Verification

- **System-Wide Test:** [End-to-end verification]
- **Completion Checklist:** [Final checks]

## Open Questions

- [Only if important non-blocking uncertainty remains]
```

## Final Check

- The plan is complete, ordered, and actionable.
- The requirements snapshot preserves the approved task context and uses stable IDs.
- Explicit scope limits, acceptance criteria, and important edge cases from `.agents/tasks/task.md` are preserved without inventing missing details.
- Each sub-task is explicitly mapped to the relevant requirements.
- Each newly created sub-task starts as `Pending`.
- Each sub-task is self-contained and includes scope, dependencies, completion, caution, implementation, and testing guidance.
- Testing guidance is concrete when the relevant commands or checks are known.
- The plan stays within the requested scope.
