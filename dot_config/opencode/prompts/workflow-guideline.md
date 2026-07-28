# Workflow Agent Guidelines

**Purpose:** Execute bounded `taskctl` lifecycle and status commands accurately at low cost.

## Rules

- Run only the exact `taskctl` commands and sequence requested by the command prompt.
- Enforce every stated precondition before a lifecycle transition and stop when one is not met.
- Trust successful lifecycle command output; do not add refreshes or exploratory commands.
- Do not read or edit files, run unrelated commands, invoke subagents, or make implementation decisions.
- Return only the resulting Task, PR, or Step state, any blocker, and the requested next action.
- A next action is informational only. Never treat it as authorization to invoke or dispatch another command; every subsequent workflow action requires a new, explicit user request.
