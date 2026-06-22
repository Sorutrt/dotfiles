---
name: agent-testing
description: Guide for asking an independent agent to test or verify implementation behavior. Use when the user asks Codex to have another agent, subagent, or separate reviewer test changes; when a change needs independent behavioral verification; or when applying the testing policy from codex/AGENTS.md to validate expected behavior and preserved behavior without overfitting to the implementer's assumptions.
---

# Agent Testing

## Overview

Use an independent agent as a verification surface after the implementer has defined expected behavior, preserved behavior, and concrete checks. Keep the delegated task narrow, artifact-driven, and focused on observable behavior.

## Workflow

1. Read the nearest applicable `AGENTS.md` before drafting the test request.
2. State the expected behavior changed by the implementation.
3. State the existing behavior that must remain unchanged.
4. Choose the smallest useful verification scope:
   - reproduction steps for a bug fix
   - focused unit or integration tests
   - command output inspection
   - manual behavior checks when tests are not cost-effective
5. Spawn an independent agent only when the user has asked for agent-based testing or delegation, or when the current tool policy permits subagent validation.
6. Continue local non-overlapping work while the agent runs, if any remains.
7. Review the agent's result before trusting it. Treat findings as input, not authority.
8. Report what was tested, what passed or failed, and what remains unverified.

## Delegation Prompt

Give the agent raw context and a bounded task. Do not include the intended answer or your diagnosis unless the test explicitly requires it.

Use this shape:

```text
Use $agent-testing to independently verify the behavior of this change.

Repository: <path or repo name>
Relevant files or diff: <paths, PR, or patch>
Expected changed behavior:
- <short bullet>

Behavior that must remain unchanged:
- <short bullet>

Please run or propose the smallest useful checks. Report:
- commands or manual checks performed
- pass/fail result
- concrete failures with file/line references when applicable
- remaining unverified risk
Do not modify files unless explicitly asked.
```

For code-editing verification, assign a disjoint write scope and make that explicit. Tell the agent that other edits may exist and it must not revert them.

## Result Handling

- Reproduce important failures locally when feasible.
- If the agent only proposed tests, decide whether to run them yourself.
- If the agent changed files, inspect the diff before integrating.
- If the agent finds no issues, still mention any test gaps or environment limits in the final report.
- If agent testing is unavailable, fall back to the same expected-behavior and preserved-behavior checklist locally.
