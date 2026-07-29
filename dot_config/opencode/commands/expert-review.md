---
description: Perform a premium in-depth review.
agent: expert-reviewer
subtask: true
---

Perform the expert agent's in-depth review workflow. Treat `$ARGUMENTS` as optional review scope or focus; optional focus does not permit omitting relevant changed code. Support either the selected `taskctl` completed PR or an unrelated caller-provided scope. For an unrelated review with no usable scope, ask instead of scanning broadly.

The calling orchestrator owns remediation: when actionable findings are returned, it must immediately dispatch one fresh builder workstream. For a Task-backed review, pass the PR/branch, created corrective Step, and `review.md` context for the builder's system-loaded Task PR remediation workflow; for an unrelated review, pass all findings as the bounded implementation contract. The reviewer must stop after review and artifact/lifecycle setup and must not edit source itself.
