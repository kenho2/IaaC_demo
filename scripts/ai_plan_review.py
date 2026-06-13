#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path


SYSTEM_PROMPT = """You are a Terraform security and integrity reviewer.
Evaluate the supplied Terraform plan JSON for:
1. security risks,
2. resource drift,
3. structural integrity,
4. any signs of unsafe or unintended changes.

Return strict JSON only with this shape:
{
  "approve": true|false,
  "risk_level": "low"|"medium"|"high",
  "summary": "short sentence",
  "findings": ["..."],
  "drift_signals": ["..."],
  "structural_issues": ["..."]
}

Fail closed if the plan is ambiguous, destructive, or structurally inconsistent.
"""


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Review a Terraform plan JSON payload with a local OpenAI-compatible endpoint.")
    parser.add_argument("--plan-json", required=True, help="Path to terraform show -json output")
    parser.add_argument("--endpoint", default="http://localhost:1234/v1", help="OpenAI-compatible base endpoint")
    parser.add_argument("--model", default="local-model", help="Model name exposed by the local endpoint")
    return parser.parse_args()


def _load_plan(plan_path: Path) -> dict:
    with plan_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _build_request(plan: dict, model: str) -> bytes:
    user_payload = json.dumps(plan, separators=(",", ":"), sort_keys=True)
    request_body = {
        "model": model,
        "temperature": 0,
        "max_tokens": 1200,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_payload},
        ],
    }
    return json.dumps(request_body).encode("utf-8")


def _compact_plan(plan: dict) -> dict:
    """Reduce payload size for local model endpoints that reject very large requests."""
    resource_changes = []
    for item in plan.get("resource_changes", []):
        change = item.get("change", {})
        resource_changes.append(
            {
                "address": item.get("address"),
                "mode": item.get("mode"),
                "type": item.get("type"),
                "name": item.get("name"),
                "actions": change.get("actions", []),
                "before_sensitive": change.get("before_sensitive", {}),
                "after_unknown": change.get("after_unknown", {}),
            }
        )

    return {
        "format_version": plan.get("format_version"),
        "terraform_version": plan.get("terraform_version"),
        "planned_values_present": bool(plan.get("planned_values")),
        "resource_changes": resource_changes,
        "output_changes": plan.get("output_changes", {}),
    }


def _post(endpoint: str, body: bytes) -> dict:
    request = urllib.request.Request(
        f"{endpoint.rstrip('/')}/chat/completions",
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=300) as response:
        return json.loads(response.read().decode("utf-8"))


def _extract_content(response: dict) -> str:
    choices = response.get("choices") or []
    if not choices:
        raise ValueError("AI response did not contain any choices")
    message = choices[0].get("message") or {}
    content = message.get("content")
    if not isinstance(content, str) or not content.strip():
        raise ValueError("AI response did not contain message content")
    return content.strip()


def _strip_code_fences(text: str) -> str:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.split("\n", 1)[1] if "\n" in cleaned else ""
        if cleaned.endswith("```"):
            cleaned = cleaned[:-3]
    return cleaned.strip()


def _parse_verdict(text: str) -> dict:
    candidate = _strip_code_fences(text)
    return json.loads(candidate)


def main() -> int:
    args = _parse_args()
    plan_path = Path(args.plan_json)

    if not plan_path.exists():
        print(f"Plan JSON not found: {plan_path}", file=sys.stderr)
        return 2

    try:
        plan = _load_plan(plan_path)
        body = _build_request(plan, args.model)
        try:
            response = _post(args.endpoint, body)
        except urllib.error.HTTPError as exc:
            # LM Studio commonly returns HTTP 400 when request bodies exceed
            # practical context limits. Retry with a compact plan projection.
            if exc.code != 400:
                raise
            compact_body = _build_request(_compact_plan(plan), args.model)
            response = _post(args.endpoint, compact_body)
        content = _extract_content(response)
        verdict = _parse_verdict(content)
    except urllib.error.HTTPError as exc:
        details = ""
        try:
            details = exc.read().decode("utf-8", errors="replace")
        except Exception:
            details = ""
        suffix = f" | response: {details}" if details else ""
        print(f"AI review request failed: HTTP {exc.code}{suffix}", file=sys.stderr)
        return 3
    except urllib.error.URLError as exc:
        print(f"AI review request failed: {exc}", file=sys.stderr)
        return 3
    except (json.JSONDecodeError, ValueError) as exc:
        print(f"AI review produced invalid output: {exc}", file=sys.stderr)
        return 4

    print(json.dumps(verdict, indent=2, sort_keys=True))

    if not verdict.get("approve", False):
        print("AI review rejected the plan", file=sys.stderr)
        return 5

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
