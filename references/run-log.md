# Run Log

Use run log entries in Agent Mode to make long-running Codex-ChatGPT workflows resumable and auditable.

## Block Format

```text
RUN_LOG_ENTRY:
TIME: local ISO timestamp
TASK: short task id or title
STEP: current step
ACTION: what was done
RESULT: what changed or was learned
ARTIFACTS:
- path, URL, generated file, or none
VERIFICATION:
- check result or none
NEXT_ACTION: exact next action
END_RUN_LOG_ENTRY
```

## Rules

- Print entries after meaningful progress, before a pause, and after a resume.
- Keep entries concise enough to paste into ChatGPT.
- Do not include secrets, credentials, private keys, passwords, payment data, or hidden browser state.
- Prefer local paths and URLs that another agent can use.
- If the log is written to a file, use a user-approved destination and do not overwrite an existing file without approval.

## Relationship To Task State

`TASK_STATE` is the current resume point. `RUN_LOG_ENTRY` is the chronological history.

Use both when the workflow is complex:

- task state tells the next agent what to do now
- run log explains how the workflow got there
