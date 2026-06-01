---
name: chatgpt-handoff
description: Coordinate active ChatGPT web conversations through Chrome as a handoff bridge between Codex, ChatGPT, local files, Google Drive, and local generation tools such as ComfyUI. Use when the user wants Codex to take over an in-progress ChatGPT discussion, read or write the ChatGPT webpage, continue multi-step creative or research work, coordinate two computers through the same ChatGPT conversation, review generated artifacts, or run a browser-mediated workflow to completion while stopping before irreversible actions.
---

# ChatGPT Handoff

## Core Rule

Treat the visible ChatGPT conversation as the shared task channel. Codex may read it, post structured updates, ask ChatGPT for critique, use local tools, and iterate until the requested artifact is done. Stop before irreversible actions: payment, public posting, deleting important files, changing account settings, or submitting forms that cannot be undone. Email is executable when the Email Rule below is satisfied.

Use Lite Mode for single-machine, single-task handoffs unless the user asks for multi-machine coordination, long-running recovery, or the task needs detailed cross-step traceability. Use Standard Mode when two computers may work on the same ChatGPT conversation, when the user will be away for a long time, or when local generation/tool work needs durable status handoff.

## Startup

1. Use the `chrome:Chrome` skill before controlling the user's Chrome browser.
2. Claim the already-open ChatGPT tab when possible. Prefer the current visible ChatGPT conversation over opening a new one.
3. Read the latest visible conversation state and identify the newest `TASK`, unfinished `REQUEST`, or user instruction.
4. Choose Lite Mode or Standard Mode before posting to ChatGPT.
5. In Standard Mode, determine this machine label from the environment if possible (`COMPUTERNAME` on Windows).
6. In Standard Mode, inspect the latest handoff blocks. If another machine has a current `CLAIM` for the same step and has not posted `DONE`, `REQUEST`, or a stale timeout note, do not duplicate the work. Post a short `STATUS` or ask the user only if the conflict cannot be resolved from the conversation.
7. Before work starts, do a role precheck. Identify who generates the artifact, who reviews it, what Codex is allowed to do, hard stop points, and completion criteria. Ask only when these are ambiguous and materially affect the workflow.
8. In Standard Mode, post a `CLAIM` block before doing substantial work. Use `scripts/new_handoff_message.ps1` when available.
9. When waiting for ChatGPT after a prompt, review request, or generation request, follow the ChatGPT status check rule below.

## Role Precheck

- If the user says ChatGPT should generate, Codex must not replace that with local HTML/CSS, built-in image generation, ComfyUI, or other local generation. Codex only prompts, researches, transports, downloads, renames, packages, and reports.
- If the user says ComfyUI should generate, Codex may control ComfyUI but should use ChatGPT for prompt planning or review when requested.
- If the generator is not specified, infer from the active ChatGPT conversation and user wording. If multiple generators are plausible, ask before generating.
- Keep one thread focused on one task. Use the visible ChatGPT conversation and current Codex thread as the primary state; do not create a separate workflow database unless the user asks.

## Lite Mode

Lite Mode is the low-token path for one computer, one ChatGPT conversation, and one clear task. It keeps the ChatGPT thread clean and relies on the current Codex thread plus the visible ChatGPT conversation for state.

Use this pattern:

1. Read the existing ChatGPT conversation and the user's current instruction.
2. Do only the minimum outside research or local inspection needed to make the next ChatGPT request useful.
3. Post one compact instruction to ChatGPT that includes the current task, generator/reviewer roles, acceptance checks, and final approval phrase.
4. Do not post `CLAIM`, periodic `STATUS`, or full `HANDOFF` blocks unless the user explicitly says another machine is involved or the task becomes long-running.
5. Record a checkpoint from the latest visible ChatGPT state: response text, generation/review status, visible artifacts, and timestamp.
6. Check ChatGPT status every 10 minutes while waiting. If the visible state has not changed since the previous checkpoint, stop the handoff locally and report that ChatGPT did not update; do not keep polling or post more prompts unless the user asks to continue.
7. If ChatGPT updates but generates too few artifacts, skips self-review, or omits the approval phrase, post one short corrective request, refresh the checkpoint, and apply the same 10-minute no-update stop rule.
8. After ChatGPT returns the approval phrase, download and organize the artifacts locally. Create a zip or contact sheet only when useful for review or delivery.
9. Report locally with the output folder, filenames, ChatGPT self-review conclusion, and any missing items.

Default Lite prompt:

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

## Handoff Loop

Use this Standard Mode loop only when Lite Mode is not enough.

Repeat until completion:

1. Read the ChatGPT conversation and any linked pages or files needed for the current step.
2. Convert vague goals into concrete acceptance checks. For image or video work, include visual self-review plus ChatGPT critique.
3. Do local work with the best available tools: file operations, browser research, Google Drive for large artifacts, and ComfyUI for generation when relevant.
4. Post `STATUS` after meaningful progress or before a long-running local step.
5. Post `RESULT` with artifact paths, Google Drive links, screenshots, prompt text, model/workflow notes, and known defects.
6. Ask ChatGPT to review using explicit criteria. If ChatGPT generated the artifact in the same conversation, ask it to self-review the visible generated artifacts directly; do not re-upload the same files unless ChatGPT cannot see them. If it finds issues, ask it to regenerate only failed versions.
7. Post `DONE` only when the artifact passes the requested acceptance checks or when a hard stop requires user approval.

## ChatGPT Status Check

When waiting for ChatGPT in either mode:

1. Save the latest visible conversation state as the checkpoint.
2. Re-check the visible ChatGPT tab every 10 minutes.
3. Treat new assistant text, changed generation/review status, new artifacts, an approval phrase, or a visible error as an update.
4. If there is no update compared with the previous checkpoint, stop automatically and report the no-update stop locally. In Standard Mode, post `BLOCKED` only when another machine needs to see the stop reason; in Lite Mode, keep the ChatGPT thread clean.
5. Do not continue periodic checks after a no-update stop unless the user explicitly asks to resume.

## Email Rule

Gmail actions are executable when the user asks for email sending or draft creation. Do not ask for a second confirmation when all Gmail-required fields are already specified.

- Recipient, subject, body, CC, BCC, and attachment notes must stay blank when the user did not specify them.
- Do not add greetings, summaries, explanations, or attachment descriptions on the user's behalf.
- Attachments may be included only when the user specifies the file, folder, output artifact, or equivalent delivery item.
- If a required send field is missing, stop and ask for that exact field only. Otherwise send or draft exactly as specified.

## Message Protocol

Use Lite Mode without the full block format for single-machine work. Use the following Standard Mode format only for multi-machine coordination, long-running handoffs, or when a durable audit trail is needed.

Use one fenced block per coordination message so both computers can parse it by eye:

```text
HANDOFF:
TYPE: CLAIM|STATUS|REQUEST|RESULT|DONE|BLOCKED
TASK: short task id or title
MACHINE: machine label
TIME: local ISO timestamp
BODY:
plain language update
ARTIFACTS:
- local path, uploaded attachment, or Google Drive link
NEXT:
next intended action or "none"
END_HANDOFF
```

For exact rules and examples, read `references/protocol.md`.

## Artifact Exchange

- Upload small images, reference screenshots, and prompt samples directly to ChatGPT when the UI supports it.
- Put large images, videos, model outputs, and reusable workflow files in Google Drive, then paste the link and version note into ChatGPT.
- Keep local outputs in a task-named folder under the working directory unless the user specified a destination.
- Include enough metadata for another computer to continue: source URLs, prompt text, seed, model names, workflow JSON path, output path, and review result.

## ComfyUI

When the task requires local image/video generation:

1. Read `references/comfyui.md`.
2. Check whether ComfyUI is reachable, usually `http://127.0.0.1:8188`, with `scripts/comfyui_bridge.py check`.
3. If it is running, submit workflow JSON with `scripts/comfyui_bridge.py queue`.
4. If it is missing, inspect the local machine for an existing ComfyUI install before proposing install or setup. Do not download large models unless the user has already authorized that specific model/source.
5. Ask ChatGPT to critique outputs, then revise prompts/workflows until the acceptance checks pass.

## Failure Handling

- If Chrome access fails, follow the Chrome skill recovery steps. Do not scrape Chrome profile data, cookies, local storage, or passwords.
- If ChatGPT cannot upload or inspect a file, use Google Drive and paste a link.
- If two machines conflict, the latest valid `CLAIM` wins unless it is clearly stale. Post `BLOCKED` with the reason instead of overwriting work.
- If a task reaches a hard stop, post `REQUEST` with the exact decision needed and stop.

## Bundled Helpers

- `scripts/new_handoff_message.ps1`: print a standardized handoff block for ChatGPT.
- `scripts/comfyui_bridge.py`: check ComfyUI, queue workflow JSON, and poll prompt history.
