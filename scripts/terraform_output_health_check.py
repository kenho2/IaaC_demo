#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import subprocess
import sys
import urllib.request
from pathlib import Path


def load_outputs(working_directory: str) -> dict:
    result = subprocess.run(
        [
            "terraform",
            f"-chdir={working_directory}",
            "output",
            "-json",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def load_endpoint(working_directory: str) -> str:
    tfvars_path = Path(working_directory) / "terraform.tfvars"
    for line in tfvars_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("proxmox_endpoint"):
            return line.split("=", 1)[1].strip().strip('"')
    raise RuntimeError("Could not find proxmox_endpoint in terraform.tfvars")


def load_token() -> str:
    token = os.environ.get("TF_VAR_proxmox_api_token") or os.environ.get("PROXMOX_VE_API_TOKEN")
    if not token:
        raise RuntimeError("Set TF_VAR_proxmox_api_token or PROXMOX_VE_API_TOKEN before running the health check")
    return token


def fetch_cluster_resources(endpoint: str, token: str) -> list[dict]:
    request = urllib.request.Request(
        endpoint.rstrip("/") + "/api2/json/cluster/resources",
        headers={"Authorization": f"PVEAPIToken={token}"},
        method="GET",
    )
    context = None
    if endpoint.startswith("https://"):
        import ssl

        context = ssl._create_unverified_context()

    with urllib.request.urlopen(request, context=context, timeout=30) as response:
        payload = json.loads(response.read().decode("utf-8"))
    return payload["data"]


def require_running_resources(outputs: dict, resources: list[dict]) -> list[str]:
    failures: list[str] = []
    vm_ids = outputs.get("proxmox_vm_ids", {}).get("value", {})
    lxc_ids = outputs.get("proxmox_lxc_ids", {}).get("value", {})

    resource_index = {int(resource["vmid"]): resource for resource in resources if "vmid" in resource}

    for name, vmid in vm_ids.items():
        resource = resource_index.get(int(vmid))
        if resource is None:
            failures.append(f"VM {name} with id {vmid} was not found in Proxmox cluster resources")
            continue
        if resource.get("status") != "running":
            failures.append(f"VM {name} with id {vmid} is not running")

    for name, vmid in lxc_ids.items():
        resource = resource_index.get(int(vmid))
        if resource is None:
            failures.append(f"LXC {name} with id {vmid} was not found in Proxmox cluster resources")
            continue
        if resource.get("status") != "running":
            failures.append(f"LXC {name} with id {vmid} is not running")

    return failures


def main() -> int:
    working_directory = sys.argv[1] if len(sys.argv) > 1 else str(Path("environments/homelab"))
    outputs = load_outputs(working_directory)
    endpoint = load_endpoint(working_directory)
    token = load_token()
    resources = fetch_cluster_resources(endpoint, token)
    failures = require_running_resources(outputs, resources)

    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    print("Terraform output health checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
