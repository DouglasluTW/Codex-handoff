# ComfyUI Control Notes

## Discovery

Check the default API first:

```powershell
& python scripts/comfyui_bridge.py check --server http://127.0.0.1:8188
```

If it is not reachable, inspect likely install locations such as `Downloads`, `Desktop`, and project folders for `ComfyUI`, `main.py`, or `run_nvidia_gpu.bat`. Do not assume this machine has ComfyUI installed.

The bundled bridge refuses non-local ComfyUI servers by default. Use `--allow-remote` only when the user explicitly trusts the remote server and understands the workflow JSON will be sent there.

## Queueing A Workflow

Submit an exported ComfyUI API workflow JSON:

```powershell
& python scripts/comfyui_bridge.py queue --server http://127.0.0.1:8188 --workflow C:\path\workflow_api.json --wait
```

The JSON must be the API format accepted by ComfyUI `/prompt`, not the visual editor layout unless that local ComfyUI version supports it.

## Artifact Metadata

When posting results back to ChatGPT, include:

- local output path
- workflow JSON path
- prompt text and negative prompt
- model, LoRA, VAE, sampler, steps, CFG, seed, width, height, and frame count when known
- whether ChatGPT has already reviewed the output

## Installation Boundary

Codex may help install or start ComfyUI when the user asks. Stop before downloading large model weights unless the user has authorized the specific model/source or has provided local files.
