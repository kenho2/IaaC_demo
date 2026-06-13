# AWS EC2 Placeholder

This directory is reserved for a future AWS module that can consume the same top-level `compute_nodes` schema used by the Proxmox homelab.

The intent is to keep the control plane contract stable while adding cloud-specific implementations later:

- `platform = "proxmox"` maps to the current Proxmox modules.
- `platform = "aws"` can later map to an EC2 module without forcing a rewrite of the root stack or pipeline.
