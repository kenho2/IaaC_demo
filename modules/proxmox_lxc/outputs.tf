output "id" {
  description = "Terraform resource identifier"
  value       = proxmox_virtual_environment_container.this.id
}

output "vm_id" {
  description = "Proxmox container ID"
  value       = proxmox_virtual_environment_container.this.vm_id
}

output "ipv4" {
  description = "IPv4 address map per network interface"
  value       = proxmox_virtual_environment_container.this.ipv4
}

output "ipv6" {
  description = "IPv6 address map per network interface"
  value       = proxmox_virtual_environment_container.this.ipv6
}
