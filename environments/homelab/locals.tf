locals {
  proxmox_nodes = {
    for name, node in var.compute_nodes : name => node
    if lower(node.platform) == "proxmox"
  }

  proxmox_vms = {
    for name, node in local.proxmox_nodes : name => node
    if lower(node.kind) == "vm"
  }

  proxmox_vms_strict = {
    for name, node in local.proxmox_vms : name => node
    if !try(node.proxmox.ignore_legacy_metadata_drift, false)
  }

  proxmox_vms_legacy = {
    for name, node in local.proxmox_vms : name => node
    if try(node.proxmox.ignore_legacy_metadata_drift, false)
  }

  proxmox_lxcs = {
    for name, node in local.proxmox_nodes : name => node
    if lower(node.kind) == "lxc"
  }

  aws_nodes = {
    for name, node in var.compute_nodes : name => node
    if lower(node.platform) == "aws"
  }
}
