# Agent Loop

Use Agent Mode when Codex has enough context, token budget, and permission to drive a Codex-ChatGPT workflow across tools without asking at every step.

## Loop

1. OBSERVE: read the latest ChatGPT state, local state, visible artifacts, prior handoff blocks, and current `TASK_STATE`.
2. PLAN: choose one narrow next action with an expected verification result.
3. ACT: use the least risky tool that can move the task forward.
4. VERIFY: check the expected result before continuing.
5. REPORT: update ChatGPT or Codex with the result, artifacts, and any caveats.
6. DECIDE NEXT: continue, retry once with a narrower action, ask for input, or stop.

## Mode Selection

- Use Lite Mode for a single prompt, download, or review loop.
- Use Standard Mode when another machine or durable ChatGPT audit trail matters.
- Use Agent Mode when Codex should keep driving across multiple steps and tools.

Agent Mode does not mean unlimited autonomy. It means Codex can continue while the objective, allowed tools, verification gates, and active safety policy remain clear.

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
