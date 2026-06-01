# Task State

Use `TASK_STATE` blocks in Agent Mode to keep Codex, ChatGPT, and future resumes aligned.

## Block Format

```text
TASK_STATE:
OBJECTIVE: one sentence goal
MODE: LITE|STANDARD|AGENT
CURRENT_STEP: current narrow step
OWNER: Codex|ChatGPT|User|Other
STATUS: planned|in_progress|waiting|blocked|complete
ARTIFACTS:
- local path, URL, Drive link, generated file, or none
VERIFICATION:
- expected check or latest verified result
SAFETY_POLICY:
- key: allow|ask|block|dry_run
BLOCKERS:
- blocker or none
NEXT_ACTION: exact next action
STOP_CONDITIONS:
- condition or none
TOKEN_BUDGET: enough|low|unknown
END_TASK_STATE
```

## Rules

- Keep each field short enough to paste into ChatGPT.
- Use `none` when a list is empty.
- Treat missing `OBJECTIVE`, `CURRENT_STEP`, `NEXT_ACTION`, or `STOP_CONDITIONS` as a reason to pause before acting.
- Update the block before substantial Agent Mode actions, after verification, and before a pause or resume.
- Do not put secrets, tokens, passwords, private keys, or payment data in task state. Refer to their existence generically instead.
- If task state conflicts with visible ChatGPT instructions or user instructions, follow the newest higher-priority instruction and record the conflict as a blocker.

## Example

```text
TASK_STATE:
OBJECTIVE: Add Agent Mode to the chatgpt-handoff skill and push a feature branch.
MODE: AGENT
CURRENT_STEP: Validate edited skill files.
OWNER: Codex
STATUS: in_progress
ARTIFACTS:
- C:\Users\...\Codex-handoff\SKILL.md
VERIFICATION:
- PowerShell helper parses
- Python helper parses
SAFETY_POLICY:
- file_deletion: block
- overwrite_existing_files: ask
BLOCKERS:
- none
NEXT_ACTION: Run local validation checks and commit if clean.
STOP_CONDITIONS:
- destination exists unexpectedly
- secret scan finds a credential
TOKEN_BUDGET: enough
END_TASK_STATE
```
