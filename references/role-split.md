# Role Split

Use role split before ChatGPT-connected work so ChatGPT and Codex use their strengths deliberately.

## Default Roles

- ChatGPT: clarify intent, reason through strategy, generate drafts, review outputs, turn vague requests into concrete tasks, and propose the role split.
- Codex: inspect local state, edit files, run commands, use Git and GitHub, operate approved tools, verify results, maintain task state, and enforce safety policy.
- User: set the objective, approve risky actions, choose tradeoffs, and provide final preference when the role split is ambiguous.
- Tools: perform scoped actions only after Codex maps them to the accepted role split and active safety policy.

## Workflow

1. Codex observes the current task, ChatGPT conversation, local state, and active safety policy.
2. Codex asks ChatGPT to propose a role split. Use `scripts/new_role_split_prompt.ps1` when available.
3. ChatGPT returns a `ROLE_SPLIT` block with ChatGPT role, Codex role, User role, tools, verification, and stop conditions.
4. Codex checks whether the split is executable locally and allowed by policy.
5. Codex records the accepted split in `TASK_STATE`.
6. If the split is unsafe, unclear, or impossible, Codex narrows it or asks the user before acting.

## Block Format

```text
ROLE_SPLIT:
CHATGPT_ROLE:
- reasoning, generation, review, or none
CODEX_ROLE:
- local execution, files, code, Git, validation, or none
USER_ROLE:
- approvals, preferences, missing input, or none
TOOLS:
- tool and purpose, or none
VERIFICATION:
- check or acceptance criterion
STOP_CONDITIONS:
- condition requiring pause or approval
END_ROLE_SPLIT
```

## Rules

- Do not treat ChatGPT's split as permission to bypass Codex safety policy.
- Do not let ChatGPT assign Codex destructive, public, payment, credential, or account-changing actions unless policy allows them.
- If ChatGPT assigns itself local execution, Codex must reinterpret that as Codex-owned work or ask for clarification.
- If the user gives a newer instruction after the split, refresh the split before continuing.
