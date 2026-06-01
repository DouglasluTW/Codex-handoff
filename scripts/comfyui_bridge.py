#!/usr/bin/env python3
import argparse
import json
import ipaddress
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid


def request_json(method, url, payload=None, timeout=15):
    data = None
    headers = {}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        raw = resp.read().decode("utf-8")
        if not raw:
            return {}
        return json.loads(raw)


def is_local_server(server):
    parsed = urllib.parse.urlparse(server)
    host = parsed.hostname
    if host in {"localhost", "127.0.0.1", "::1"}:
        return True
    try:
        address = ipaddress.ip_address(host or "")
    except ValueError:
        return False
    return address.is_loopback


def enforce_local_server(server, allow_remote):
    if allow_remote or is_local_server(server):
        return
    raise SystemExit(
        "Refusing to contact a non-local ComfyUI server. "
        "Use --allow-remote only when the server and workflow destination are trusted."
    )


def check(server):
    try:
        stats = request_json("GET", server.rstrip("/") + "/system_stats")
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
        print(json.dumps({"ok": False, "server": server, "error": str(exc)}, ensure_ascii=False))
        return 1
    print(json.dumps({"ok": True, "server": server, "system_stats": stats}, ensure_ascii=False, indent=2))
    return 0


def queue(server, workflow_path, wait, interval, timeout):
    with open(workflow_path, "r", encoding="utf-8") as fh:
        prompt = json.load(fh)

    client_id = str(uuid.uuid4())
    payload = {"prompt": prompt, "client_id": client_id}
    result = request_json("POST", server.rstrip("/") + "/prompt", payload)
    prompt_id = result.get("prompt_id")
    print(json.dumps({"queued": True, "server": server, "prompt_id": prompt_id, "client_id": client_id}, indent=2))

    if not wait or not prompt_id:
        return 0

    deadline = time.time() + timeout
    history_url = server.rstrip("/") + "/history/" + urllib.parse.quote(prompt_id)
    while time.time() < deadline:
        history = request_json("GET", history_url)
        if prompt_id in history:
            print(json.dumps({"done": True, "prompt_id": prompt_id, "history": history[prompt_id]}, ensure_ascii=False, indent=2))
            return 0
        time.sleep(interval)

    print(json.dumps({"done": False, "prompt_id": prompt_id, "error": "Timed out waiting for history"}, indent=2))
    return 2


def main(argv):
    parser = argparse.ArgumentParser(description="Minimal ComfyUI API bridge for the chatgpt-handoff skill.")
    parser.add_argument("--server", default="http://127.0.0.1:8188", help="ComfyUI server URL")
    parser.add_argument("--allow-remote", action="store_true", help="Permit a non-local ComfyUI server")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("check", help="Check whether ComfyUI is reachable")

    queue_parser = sub.add_parser("queue", help="Queue a ComfyUI API workflow JSON")
    queue_parser.add_argument("--workflow", required=True, help="Path to ComfyUI API workflow JSON")
    queue_parser.add_argument("--wait", action="store_true", help="Poll history until the prompt completes")
    queue_parser.add_argument("--interval", type=float, default=2.0, help="Polling interval in seconds")
    queue_parser.add_argument("--timeout", type=float, default=1800.0, help="Maximum wait time in seconds")

    args = parser.parse_args(argv)
    enforce_local_server(args.server, args.allow_remote)
    if args.cmd == "check":
        return check(args.server)
    if args.cmd == "queue":
        return queue(args.server, args.workflow, args.wait, args.interval, args.timeout)
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
