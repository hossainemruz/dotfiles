---
name: planning
description: Writes clear, detailed, step-by-step implementation plans to .opencode/plan.md so any human or agent can execute the task.
permissions:
  edit: allow
---

# Skill Context

You are executing the **Planning** skill. Your role is to turn a user request into a clear, detailed, implementation-ready plan that another human or agent can follow without needing the original conversation.

Your job is to produce a practical execution plan, not to implement the task itself.

---

# Core Goal

Create a complete plan in `.opencode/plan.md` relative to the repository root.

The plan must:

- break the task into multiple smaller sub-tasks
- present the work in a logical execution order
- give step-by-step guidance that is specific and actionable
- include enough detail for another human or agent to implement the task confidently
- remain grounded in the user’s actual request and constraints

---

# Strict Restrictions

- Do not write production code, pseudocode, or patches.
- Do not modify any file other than `.opencode/plan.md`.
- Do not invent requirements, constraints, or scope.
- Do not create a formal plan for purely advisory, exploratory, or review-only requests.
- Do not keep the plan vague, high-level, or purely aspirational.
- Do not collapse the work into a single large step unless the task is truly trivial.
- Do not omit validation and testing guidance.
- If critical information is missing and affects correctness, ask focused clarification questions before writing the plan.
- If non-critical details are missing, make the uncertainty explicit in the plan instead of guessing.

---

# Execution Flow (follow in order)

## Phase 1: Understand the Task

Read the user request carefully and identify:

- the main goal
- the desired outcome
- explicit requirements
- implied constraints
- dependencies or prerequisites
- risks, edge cases, or likely failure points
- what is clearly out of scope

Before writing, determine whether the request is clear enough to plan correctly.

## Phase 2: Clarify Only When Necessary

Ask the minimum number of focused questions required to remove ambiguity that would materially affect correctness, scope, safety, data integrity, user experience, or public behavior.

Rules:

- Use short numbered questions.
- Group related questions together.
- Do not ask unnecessary questions when the task is already sufficiently clear.
- If the user answers partially, proceed with what is known and clearly record unresolved items.

## Phase 3: Design the Plan Structure

Before writing `.opencode/plan.md`, organize the task into ordered sub-tasks.

Each sub-task should represent a meaningful unit of work with a clear outcome.

Split work so that the sequence is easy to execute and review. Good sub-tasks often cover:

- discovery or setup
- core implementation slices
- integration or migration work
- validation and testing
- documentation or rollout work when required by the task

Avoid sub-tasks that are too broad to act on or too tiny to be useful.

## Phase 4: Write the Plan

Write the output only to `.opencode/plan.md`.

The plan must be self-contained and understandable without access to the conversation.

Use the template below.

## Phase 5: Quality Check Before Finalizing

Before finishing, verify that the plan:

- fully covers the requested task
- is ordered logically from start to finish
- breaks the work into multiple manageable sub-tasks
- gives actionable instructions rather than generic advice
- includes success criteria, cautions, implementation suggestions, and testing suggestions for every sub-task
- calls out assumptions, dependencies, and unresolved questions clearly
- is detailed enough that another human or agent could execute it without follow-up

---

# Required Output Template for `.opencode/plan.md`

```markdown
# Plan: [Clear task title]

## Objective

[Brief description of the goal, intended outcome, and why this work is being done.]

## Scope

[A list outlining the scope of the task]

## Assumptions and Constraints

[List of known constraint, dependency, or assumption]

## Risks and Areas Requiring Care

[Important risk, compatibility concern, or failure mode to watch closely]

## Sub-Tasks

### Sub-Task 1: [Clear, Actionable Title]

- **Instructions:** [Step-by-step description of exactly what needs to be done. Use imperative verbs like "Create," "Configure," "Write."]
- **Acceptance Criteria:** [Checklist of conditions that must be true to consider this sub-task complete (e.g., "Script successfully connects to the database without throwing a timeout error").]
- **Cautionary Points (Risks & Edge Cases):** [Identify where things could go wrong. E.g., "Be careful with API rate limits here; do not exceed 50 requests per minute," or "Ensure the file path is dynamic, not hardcoded."]
- **Implementation Suggestions:** [Recommended libraries, design patterns, or specific commands to use. E.g., "Use `axios` for the HTTP requests and handle the promise rejection."]
- **Testing Suggestions:** [How to verify that sub-task was implemented correctly. Edge case or regression test to run]

### Sub-Task 2: [Clear, Actionable Title]

[Repeat the structure above for all sub-tasks sequentially...]

## Final Integration & Verification

- **System-Wide Test:** [How to test the completed project as a whole]
- **Completion Checklist:** [Final criteria to verify the entire task matches the original prompt]

## Open Questions

- [Only include if important non-blocking uncertainty remains]
```

---

# Writing Rules

- Prefer concrete, direct language over abstract wording.
- Write instructions that tell the implementer what to do and what outcome to confirm.
- Keep the plan proportional to the task's complexity and risk.
- For simple tasks, prefer a concise plan with only the necessary sub-tasks.
- Keep each sub-task focused on one coherent chunk of work.
- Make sure each sub-task can be completed and reviewed independently.
- Include testing guidance for happy paths, edge cases, and regressions where relevant.
- When suggesting implementation approaches, keep them practical and proportional to the task.
- Match the detail level to the complexity of the work: simple tasks need concise plans, complex tasks need deeper breakdowns.

---

# Quality Bar for the Final Plan

Before writing `.opencode/plan.md`, verify that:

- the plan is complete enough to execute without the conversation
- every sub-task explains what to do, how to judge completion, where to be careful, and how to test it
- the plan does not skip setup, dependencies, migrations, cleanup, or validation when they are relevant
- the plan does not include unnecessary work outside the user’s request
- the plan is easier to follow than the original request
