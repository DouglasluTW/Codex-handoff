# Agent Loop

Use Agent Mode when Codex has enough context, token budget, and permission to drive a Codex-ChatGPT workflow across tools without asking at every step.

## Loop

1. OBSERVE: read the latest ChatGPT state, check for user messages newer than the saved checkpoint, local state, visible artifacts, prior handoff blocks, and current `TASK_STATE`.
2. PLAN: if a newer ChatGPT user instruction exists, classify it and refresh role split before choosing one narrow next action with an expected verification result.
3. ACT: use the least risky tool that can move the task forward.
4. VERIFY: check the expected result before continuing.
5. REPORT: update ChatGPT or Codex with the result, artifacts, and any caveats.
6. DECIDE NEXT: continue, retry once with a narrower action, ask for input, stop, or supersede the current step if a newer instruction replaces it.

## Mode Selection

- Use Lite Mode for a single prompt, download, or review loop.
- Use Standard Mode when another machine or durable ChatGPT audit trail matters.
- Use Agent Mode when Codex should keep driving across multiple steps and tools.

Agent Mode does not mean unlimited autonomy. It means Codex can continue while the objective, allowed tools, verification gates, and active safety policy remain clear.

## Role Split And New Instructions

Before ChatGPT-connected work, ask ChatGPT to propose a role split and record the accepted split in task state. Read `role-split.md`.

During observe and polling, treat newer ChatGPT user messages as new instructions. Read `chatgpt-instructions.md`.

If a new instruction is accepted, merged, blocked, or supersedes the current task, update task state before acting. If Codex cannot classify the instruction safely, stop and ask for confirmation.

## Safety Policy

Represent task-specific safety as:

```yaml
safety_policy:
  file_deletion: ask
  overwrite_existing_files: ask
  cleanup_generated_files: ask
  install_or_uninstall_scripts: ask
  send_email: ask
  public_posting: ask
  payment_actions: block
  browser_account_changes: ask
  expose_secrets: block
```

Allowed values:

- `allow`: proceed when the task clearly requires the action.
- `ask`: stop and request approval before the action.
- `block`: do not perform the action.
- `dry_run`: describe or simulate the action without mutating state.

The default policy is conservative. User-provided policy can loosen or tighten it, but higher-priority system, developer, workspace, and local safety rules always win.

For policy-specific guidance, read `safety-policy.md`.

## Verification Gates

Before moving to the next step, verify the result that matters for the task:

- file exists, file count matches, or expected artifact path is present
- tests, lint, build, parse, or dry-run checks pass
- ChatGPT returned the requested review result or approval phrase
- generated assets match requested count, format, and visible quality checks
- Git status, branch, and remote target match the intended operation
- no secret, credential, payment, deletion, overwrite, or public action is being crossed without policy approval

If verification fails twice for the same step, stop with a `BLOCKED` or local report instead of looping.

## Resume And Token Budget

Before a long pause, context transition, or low-token moment, refresh `TASK_STATE` with:

- objective
- current step
- last verified result
- artifacts
- next action
- blockers
- active safety policy

If this state cannot be made clear, stop and ask for input rather than continuing from memory.

## Run Log

Use a run log when the workflow is long-running, likely to resume later, or has multiple artifacts and review loops. The log can stay in the Codex thread, be pasted into ChatGPT, or be written to a user-approved file.

Use `scripts/new_run_log_entry.ps1` to print a compact entry after meaningful progress, before a pause, and after a resume. Do not write a log file unless the user asks for one or has approved the destination.
