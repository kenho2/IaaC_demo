resource "proxmox_virtual_environment_container" "this" {
  description   = var.description
  node_name     = var.node_name
  vm_id         = var.vm_id
  tags          = sort(var.tags)
  pool_id       = var.pool_id
  started       = var.started
  start_on_boot = var.start_on_boot
  protection    = var.protection
  unprivileged  = var.unprivileged

  dynamic "clone" {
    for_each = var.clone == null ? [] : [var.clone]

    content {
      node_name    = try(clone.value.node_name, null)
      vm_id        = clone.value.vm_id
      datastore_id = try(clone.value.datastore_id, null)
      full         = try(clone.value.full, null)
    }
  }

  dynamic "cpu" {
    for_each = var.cpu == null ? [] : [var.cpu]

    content {
      architecture = try(cpu.value.architecture, null)
      cores        = try(cpu.value.cores, null)
      limit        = try(cpu.value.limit, null)
      units        = try(cpu.value.units, null)
    }
  }

  dynamic "memory" {
    for_each = var.memory == null ? [] : [var.memory]

    content {
      dedicated = memory.value.dedicated
      swap      = try(memory.value.swap, null)
    }
  }

  dynamic "features" {
    for_each = var.features == null ? [] : [var.features]

    content {
      nesting = try(features.value.nesting, null)
      fuse    = try(features.value.fuse, null)
      keyctl  = try(features.value.keyctl, null)
      mount   = try(features.value.mount, null)
      mknod   = try(features.value.mknod, null)
    }
  }

  dynamic "startup" {
    for_each = var.startup == null ? [] : [var.startup]

    content {
      order      = startup.value.order
      up_delay   = try(startup.value.up_delay, null)
      down_delay = try(startup.value.down_delay, null)
    }
  }

  dynamic "disk" {
    for_each = var.disk == null ? [] : [var.disk]

    content {
      datastore_id  = try(disk.value.datastore_id, null)
      size          = try(disk.value.size, null)
      mount_options = try(disk.value.mount_options, null)
    }
  }

  dynamic "mount_point" {
    for_each = var.mount_points

    content {
      volume        = mount_point.value.volume
      path          = mount_point.value.path
      size          = try(mount_point.value.size, null)
      backup        = try(mount_point.value.backup, null)
      acl           = try(mount_point.value.acl, null)
      read_only     = try(mount_point.value.read_only, null)
      quota         = try(mount_point.value.quota, null)
      shared        = try(mount_point.value.shared, null)
      mount_options = try(mount_point.value.mount_options, null)
    }
  }

  dynamic "idmap" {
    for_each = var.idmap

    content {
      type         = idmap.value.type
      container_id = idmap.value.container_id
      host_id      = idmap.value.host_id
      size         = idmap.value.size
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces

    content {
      name         = network_interface.value.name
      bridge       = try(network_interface.value.bridge, null)
      enabled      = try(network_interface.value.enabled, null)
      firewall     = try(network_interface.value.firewall, null)
      host_managed = try(network_interface.value.host_managed, null)
      mac_address  = try(network_interface.value.mac_address, null)
      mtu          = try(network_interface.value.mtu, null)
      rate_limit   = try(network_interface.value.rate_limit, null)
      vlan_id      = try(network_interface.value.vlan_id, null)
    }
  }

  dynamic "initialization" {
    for_each = var.initialization == null ? [] : [var.initialization]

    content {
      hostname   = try(initialization.value.hostname, null)
      entrypoint = try(initialization.value.entrypoint, null)

      dynamic "ip_config" {
        for_each = (
          try(initialization.value.ipv4_address, null) != null ||
          try(initialization.value.ipv6_address, null) != null
        ) ? [initialization.value] : []

        content {
          dynamic "ipv4" {
            for_each = try(ip_config.value.ipv4_address, null) == null ? [] : [ip_config.value]

            content {
              address = ipv4.value.ipv4_address
              gateway = try(ipv4.value.ipv4_gateway, null)
            }
          }

          dynamic "ipv6" {
            for_each = try(ip_config.value.ipv6_address, null) == null ? [] : [ip_config.value]

            content {
              address = ipv6.value.ipv6_address
              gateway = try(ipv6.value.ipv6_gateway, null)
            }
          }
        }
      }

      dynamic "user_account" {
        for_each = (
          try(initialization.value.password, null) != null ||
          length(try(initialization.value.ssh_keys, [])) > 0
        ) ? [initialization.value] : []

        content {
          password = try(user_account.value.password, null)
          keys     = try(user_account.value.ssh_keys, [])
        }
      }

      dynamic "dns" {
        for_each = (
          length(try(initialization.value.dns_servers, [])) > 0 ||
          try(initialization.value.dns_domain, null) != null
        ) ? [initialization.value] : []

        content {
          servers = try(dns.value.dns_servers, [])
          domain  = try(dns.value.dns_domain, null)
        }
      }
    }
  }

  operating_system {
    template_file_id = var.operating_system.template_file_id
    type             = var.operating_system.type
  }

  lifecycle {
    ignore_changes = [
      clone,
      disk,
      features,
      initialization,
      network_interface,
      operating_system,
      timeout_clone,
      timeout_create,
      timeout_delete,
      timeout_start,
      timeout_update,
      vm_id,
    ]
  }
}



