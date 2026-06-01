# ChatGPT Instructions

Use this reference when handoff is active and the user may give new instructions in the ChatGPT conversation, including from mobile.

## Intake Flow

```text
detect -> classify -> accept/merge/block -> update TASK_STATE -> replan
```

## Detection

At handoff startup, save a ChatGPT checkpoint in task state. During every observe or polling step, compare the visible ChatGPT conversation to that checkpoint.

Treat a newer user message after the checkpoint as `NEW_USER_INSTRUCTION`. This is an update, not a no-update condition.

This is not push notification. Codex can only detect the new instruction when it reads ChatGPT during observe or polling, or after the current command/tool action returns.

## Classification

- `new`: instruction has been detected but not yet accepted.
- `accepted`: instruction is safe, clear, and becomes the current task.
- `merged`: instruction is compatible with the current task and updates the plan.
- `blocked`: instruction is unsafe, unclear, impossible, or requires approval.
- `superseded`: instruction replaces the previous task or current step.

## Source

Use:

- `ChatGPT` when the source is the visible ChatGPT conversation.
- `Mobile` when the message is known to come from a mobile ChatGPT surface.
- `Codex` when the instruction came directly from the Codex thread.
- `Unknown` when the surface cannot be determined.

## Rules

- Newer user instructions have priority over the existing handoff plan.
- If a new instruction is compatible with the current task, merge it and refresh role split.
- If it changes the objective, mark the previous work as superseded and re-plan.
- If it conflicts with task state or touches deletion, overwrite, payment, public posting, account changes, or secrets, block or ask according to safety policy.
- Do not execute a new instruction until `TASK_STATE` records the instruction text or summary, source, status, and next action.
