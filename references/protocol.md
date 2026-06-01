# Handoff Protocol

## Lite Mode

Use Lite Mode for one computer, one ChatGPT conversation, and one clear task. Lite Mode minimizes token use by avoiding routine `CLAIM`, `STATUS`, `RESULT`, and `DONE` blocks.

Lite Mode flow:

1. Read the current ChatGPT conversation.
2. Post one compact task instruction with role boundaries, acceptance checks, and the approval phrase.
3. Let ChatGPT generate and self-review visible outputs in the same conversation.
4. If needed, post one short correction for missing count, missing self-review, failed items, or missing approval phrase.
5. After ChatGPT replies `APPROVED FOR DOWNLOAD`, download and organize the artifacts locally.
6. Report the local output folder, filenames, ChatGPT self-review conclusion, and any missing items in Codex.

Lite Mode task template:

```text
請接續目前這段對話的最新任務，不要重新開題。

Codex 只負責搬運、搜尋、下載與整理；圖片/文字/審查由你在此對話中完成。

請完成：
1. 產出 [數量] 組 [素材類型]
2. 每組需對應以下賣點：[賣點列表]
3. 產出後直接在同一對話自檢，不需要我重新上傳圖片
4. 自檢標準：[清楚度/轉換力/情境/文字可讀性/投放適配]
5. 若不通過，請自行重做該組；全部通過後回覆：
   APPROVED FOR DOWNLOAD
   並列出每組名稱與對應賣點
```

Switch from Lite Mode to the full protocol when two computers may coordinate on the same task, the user needs durable progress recovery, local generation tools require multiple review loops, or the task becomes long-running.

Switch to Agent Mode when Codex should drive a multi-step workflow across tools and maintain explicit task state. Read `agent-loop.md` and `task-state.md` before using Agent Mode.

## Message Types

- `TASK`: user-owned task definition, success criteria, and constraints.
- `CLAIM`: a machine is taking a step and intends to avoid duplicate work.
- `STATUS`: progress update while work continues.
- `REQUEST`: needs input from the user, ChatGPT, or another machine.
- `RESULT`: artifact, evidence, prompt, screenshot, link, or review findings.
- `DONE`: final delivery or completed step.
- `BLOCKED`: cannot proceed without intervention.

## Claim Rules

Use the current machine label in every message. On Windows, prefer `$env:COMPUTERNAME`.

A `CLAIM` is active when it is the latest message for the same task/step and no later `DONE`, `REQUEST`, `RESULT` requesting handoff, or `BLOCKED` has appeared. If the active claim belongs to another machine, do not start the same step.

If a claim appears stale, post a `STATUS` explaining why it is being taken over, then post a new `CLAIM`. Use practical evidence such as a long inactive interval, the other machine asking for handoff, or the user explicitly asking this machine to continue.

## Block Format

```text
HANDOFF:
TYPE: CLAIM
TASK: product-image-v1
MACHINE: PC-A
TIME: 2026-05-13T14:05:00+08:00
BODY:
I am taking over prompt refinement and first image generation.
ARTIFACTS:
- none
NEXT:
Read current ChatGPT critique, prepare prompt, run ComfyUI.
END_HANDOFF
```

Keep `BODY` readable by humans. Keep paths and links under `ARTIFACTS`.

## Review Pattern

In Lite Mode, include review criteria in the single task instruction and ask ChatGPT to self-review its visible outputs before it returns `APPROVED FOR DOWNLOAD`.

For creative work, post a `RESULT` and ask ChatGPT to review against explicit criteria:

```text
Please review the attached result against:
1. Main subject matches the task.
2. Composition is centered and usable.
3. No broken text, extra limbs, distorted product parts, or obvious artifacts.
4. Output matches required size/style.
Return PASS or a concise fix list.
```

If ChatGPT returns fixes, post a `STATUS`, revise, and post a new `RESULT`.

If ChatGPT generated the images or videos in the same conversation, ask it to self-review those visible outputs directly. Do not upload the downloaded files back into the same conversation unless ChatGPT says it cannot inspect them.

## Completion Pattern

In Lite Mode, completion happens in Codex after ChatGPT returns `APPROVED FOR DOWNLOAD` and Codex has downloaded/organized the outputs. Do not add a `DONE` block to ChatGPT unless Standard Mode is active.

Use `DONE` only after acceptance checks pass. Include final artifact location and remaining caveats:

```text
HANDOFF:
TYPE: DONE
TASK: product-image-v1
MACHINE: PC-A
TIME: 2026-05-13T15:20:00+08:00
BODY:
Final image passed self-review and ChatGPT review.
ARTIFACTS:
- C:\Users\...\Downloads\product-image-v1\final.png
- Google Drive: https://...
NEXT:
none
END_HANDOFF
```

## Agent Mode State

In Agent Mode, pair `HANDOFF` messages with a `TASK_STATE` block. The handoff block tells collaborators what changed; the task state block tells the next agent exactly where to resume.

Use `scripts/new_task_state.ps1` when available. Keep state concise and omit secrets. If task state is stale or conflicts with visible instructions, refresh it or stop before acting.
