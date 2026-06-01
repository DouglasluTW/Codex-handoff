# Safety Policy

Safety policy controls how Agent Mode handles risky actions. It is configurable so different users and teams can choose their own risk tolerance.

## Actions

Recommended policy keys:

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

## Values

- `allow`: perform the action when it clearly matches the task.
- `ask`: stop and request approval before the action.
- `block`: do not perform the action.
- `dry_run`: describe or simulate the action without changing external state.

## Precedence

Apply policy in this order:

1. system, developer, workspace, and local safety rules
2. explicit user instruction for the current task
3. task-provided safety policy
4. conservative default policy

Higher-priority rules always win. If rules conflict and the action could expose secrets, overwrite data, delete data, spend money, publish publicly, or change account state, stop and ask.

## Reporting

When policy affects execution, report:

- the action being considered
- the active policy value
- whether Codex proceeded, asked, blocked, or used dry run
- the exact approval needed when asking

Do not include secret values in policy reports.
