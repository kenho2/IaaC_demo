output "id" {
  description = "Terraform resource identifier"
  value       = proxmox_virtual_environment_vm.this.id
}

output "vm_id" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "ipv4_addresses" {
  description = "IPv4 addresses from the QEMU guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}

output "ipv6_addresses" {
  description = "IPv6 addresses from the QEMU guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv6_addresses
}

output "mac_addresses" {
  description = "MAC addresses known to the QEMU guest agent"
  value       = proxmox_virtual_environment_vm.this.mac_addresses
}
