module "proxmox_vms" {
  source   = "../../modules/proxmox_vm_legacy"
  for_each = local.proxmox_vms_legacy

  name                = each.value.name
  node_name           = each.value.proxmox.node_name
  vm_id               = try(each.value.proxmox.vm_id, null)
  description         = try(each.value.proxmox.description, null)
  tags                = each.value.tags
  pool_id             = try(each.value.proxmox.pool_id, null)
  started             = try(each.value.proxmox.started, true)
  on_boot             = try(each.value.proxmox.start_on_boot, true)
  protection          = try(each.value.proxmox.protection, false)
  stop_on_destroy     = try(each.value.proxmox.stop_on_destroy, true)
  reboot_after_update = try(each.value.proxmox.reboot_after_update, true)
  boot_order          = try(each.value.proxmox.boot_order, null)
  cdrom               = try(each.value.proxmox.cdrom, null)

  cpu              = try(each.value.proxmox.cpu, null)
  memory           = try(each.value.proxmox.memory, null)
  agent            = try(each.value.proxmox.agent, null)
  startup          = try(each.value.proxmox.startup, null)
  operating_system = try(each.value.proxmox.operating_system, null)
  disk             = try(each.value.proxmox.disk, null)
  disks            = try(each.value.proxmox.disks, [])
  network_devices  = try(each.value.proxmox.network_devices, [])
  initialization   = try(each.value.proxmox.initialization, null)
  clone            = try(each.value.proxmox.clone, null)
}

module "proxmox_vms_strict" {
  source   = "../../modules/proxmox_vm"
  for_each = local.proxmox_vms_strict

  name                = each.value.name
  node_name           = each.value.proxmox.node_name
  vm_id               = try(each.value.proxmox.vm_id, null)
  description         = try(each.value.proxmox.description, null)
  tags                = each.value.tags
  pool_id             = try(each.value.proxmox.pool_id, null)
  started             = try(each.value.proxmox.started, true)
  on_boot             = try(each.value.proxmox.start_on_boot, true)
  protection          = try(each.value.proxmox.protection, false)
  stop_on_destroy     = try(each.value.proxmox.stop_on_destroy, true)
  reboot_after_update = try(each.value.proxmox.reboot_after_update, true)
  boot_order          = try(each.value.proxmox.boot_order, null)
  cdrom               = try(each.value.proxmox.cdrom, null)

  cpu              = try(each.value.proxmox.cpu, null)
  memory           = try(each.value.proxmox.memory, null)
  agent            = try(each.value.proxmox.agent, null)
  startup          = try(each.value.proxmox.startup, null)
  operating_system = try(each.value.proxmox.operating_system, null)
  disk             = try(each.value.proxmox.disk, null)
  disks            = try(each.value.proxmox.disks, [])
  network_devices  = try(each.value.proxmox.network_devices, [])
  initialization   = try(each.value.proxmox.initialization, null)
  clone            = try(each.value.proxmox.clone, null)
}

module "proxmox_lxcs" {
  source   = "../../modules/proxmox_lxc"
  for_each = local.proxmox_lxcs

  name          = each.value.name
  node_name     = each.value.proxmox.node_name
  vm_id         = try(each.value.proxmox.vm_id, null)
  description   = try(each.value.proxmox.description, null)
  tags          = each.value.tags
  pool_id       = try(each.value.proxmox.pool_id, null)
  started       = try(each.value.proxmox.started, true)
  start_on_boot = try(each.value.proxmox.start_on_boot, true)
  protection    = try(each.value.proxmox.protection, false)
  unprivileged  = try(each.value.proxmox.unprivileged, true)

  cpu                = try(each.value.proxmox.cpu, null)
  memory             = try(each.value.proxmox.memory, null)
  features           = try(each.value.proxmox.features, null)
  startup            = try(each.value.proxmox.startup, null)
  disk               = try(each.value.proxmox.disk, null)
  mount_points       = try(each.value.proxmox.mount_points, [])
  idmap              = try(each.value.proxmox.idmap, [])
  network_interfaces = try(each.value.proxmox.network_interfaces, [])
  initialization     = try(each.value.proxmox.initialization, null)
  operating_system   = try(each.value.proxmox.operating_system, null)
  clone              = try(each.value.proxmox.clone, null)
}
