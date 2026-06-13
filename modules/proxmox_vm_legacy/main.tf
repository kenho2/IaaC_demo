resource "proxmox_virtual_environment_vm" "this" {
  name                = var.name
  node_name           = var.node_name
  vm_id               = var.vm_id
  description         = var.description
  tags                = sort(var.tags)
  pool_id             = var.pool_id
  started             = var.started
  on_boot             = var.on_boot
  protection          = var.protection
  stop_on_destroy     = var.stop_on_destroy
  reboot_after_update = var.reboot_after_update
  boot_order          = var.boot_order

  dynamic "cdrom" {
    for_each = var.cdrom == null ? [] : [var.cdrom]

    content {
      file_id   = cdrom.value.file_id
      interface = try(cdrom.value.interface, null)
    }
  }

  dynamic "clone" {
    for_each = var.clone == null ? [] : [var.clone]

    content {
      node_name   = try(clone.value.node_name, null)
      vm_id       = clone.value.vm_id
      datastore_id = try(clone.value.datastore_id, null)
      full        = try(clone.value.full, null)
      retries     = try(clone.value.retries, null)
    }
  }

  dynamic "agent" {
    for_each = var.agent == null ? [] : [var.agent]

    content {
      enabled = try(agent.value.enabled, true)
      timeout = try(agent.value.timeout, null)
      trim    = try(agent.value.trim, null)
      type    = try(agent.value.type, null)

      dynamic "wait_for_ip" {
        for_each = try(agent.value.wait_for_ip_disabled, null) == null ? [] : [agent.value.wait_for_ip_disabled]

        content {
          disabled = wait_for_ip.value
        }
      }
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

  dynamic "cpu" {
    for_each = var.cpu == null ? [] : [var.cpu]

    content {
      cores        = try(cpu.value.cores, null)
      sockets      = try(cpu.value.sockets, null)
      type         = try(cpu.value.type, null)
      architecture = try(cpu.value.architecture, null)
      limit        = try(cpu.value.limit, null)
      units        = try(cpu.value.units, null)
      numa         = try(cpu.value.numa, null)
    }
  }

  dynamic "memory" {
    for_each = var.memory == null ? [] : [var.memory]

    content {
      dedicated = memory.value.dedicated
      floating  = try(memory.value.floating, null)
    }
  }

  dynamic "disk" {
    for_each = concat(var.disk == null ? [] : [var.disk], var.disks)

    content {
      datastore_id     = try(disk.value.datastore_id, null)
      interface        = disk.value.interface
      size             = try(disk.value.size, null)
      file_id          = try(disk.value.file_id, null)
      import_from      = try(disk.value.import_from, null)
      path_in_datastore = try(disk.value.path_in_datastore, null)
      cache            = try(disk.value.cache, null)
      aio              = try(disk.value.aio, null)
      iothread         = try(disk.value.iothread, null)
      discard          = try(disk.value.discard, null)
      replicate        = try(disk.value.replicate, null)
      ssd              = try(disk.value.ssd, null)
    }
  }

  dynamic "network_device" {
    for_each = var.network_devices

    content {
      bridge      = network_device.value.bridge
      model       = try(network_device.value.model, null)
      firewall    = try(network_device.value.firewall, null)
      mac_address = try(network_device.value.mac_address, null)
      mtu         = try(network_device.value.mtu, null)
      queues      = try(network_device.value.queues, null)
      rate_limit  = try(network_device.value.rate_limit, null)
      vlan_id     = try(network_device.value.vlan_id, null)
      trunks      = try(network_device.value.trunks, null)
    }
  }

  dynamic "initialization" {
    for_each = var.initialization == null ? [] : [var.initialization]

    content {
      datastore_id       = try(initialization.value.datastore_id, null)
      user_data_file_id  = try(initialization.value.user_data_file_id, null)
      network_data_file_id = try(initialization.value.network_data_file_id, null)
      meta_data_file_id  = try(initialization.value.meta_data_file_id, null)
      vendor_data_file_id = try(initialization.value.vendor_data_file_id, null)
      upgrade            = try(initialization.value.upgrade, null)

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
          try(initialization.value.username, null) != null ||
          length(try(initialization.value.ssh_keys, [])) > 0 ||
          try(initialization.value.password, null) != null
        ) ? [initialization.value] : []

        content {
          username = try(user_account.value.username, null)
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

  dynamic "operating_system" {
    for_each = var.operating_system == null ? [] : [var.operating_system]

    content {
      type = try(operating_system.value.type, null)
    }
  }

  lifecycle {
    ignore_changes = [
      boot_order,
      cdrom,
      initialization,
    ]
  }
}
