output "proxmox_vm_ids" {
  description = "Map of Proxmox VM IDs keyed by workload name"
  value = merge(
    { for name, mod in module.proxmox_vms : name => mod.vm_id },
    { for name, mod in module.proxmox_vms_strict : name => mod.vm_id },
  )
}

output "proxmox_vm_ipv4_addresses" {
  description = "Map of Proxmox VM IPv4 addresses keyed by workload name"
  value = merge(
    { for name, mod in module.proxmox_vms : name => mod.ipv4_addresses },
    { for name, mod in module.proxmox_vms_strict : name => mod.ipv4_addresses },
  )
}

output "proxmox_lxc_ids" {
  description = "Map of Proxmox LXC IDs keyed by workload name"
  value       = { for name, mod in module.proxmox_lxcs : name => mod.vm_id }
}

output "proxmox_lxc_ipv4" {
  description = "Map of Proxmox LXC IPv4 addresses keyed by workload name"
  value       = { for name, mod in module.proxmox_lxcs : name => mod.ipv4 }
}
