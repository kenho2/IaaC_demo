variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint"
  type        = string
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for local/self-signed Proxmox endpoints"
  type        = bool
  default     = true
}

variable "proxmox_api_token" {
  description = "Proxmox API token in user@realm!tokenid=secret format"
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_username" {
  description = "Proxmox username in user@realm format"
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_password" {
  description = "Proxmox password when using username/password authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_ssh_username" {
  description = "SSH username for provider-side node access when needed"
  type        = string
  default     = null
}

variable "proxmox_ssh_agent" {
  description = "Use the local SSH agent for Proxmox node access"
  type        = bool
  default     = true
}

variable "proxmox_ssh_private_key" {
  description = "Fallback SSH private key for Proxmox node access"
  type        = string
  default     = null
  sensitive   = true
}

variable "compute_nodes" {
  description = "Provider-agnostic compute definitions keyed by workload name"

  type = map(object({
    platform = string
    kind     = string
    name     = string
    tags     = optional(list(string), [])

    proxmox = optional(object({
      node_name = string
      vm_id     = optional(number)

      description                  = optional(string)
      pool_id                      = optional(string)
      started                      = optional(bool, true)
      start_on_boot                = optional(bool, true)
      protection                   = optional(bool, false)
      stop_on_destroy              = optional(bool, true)
      reboot_after_update          = optional(bool, true)
      unprivileged                 = optional(bool, true)
      ignore_legacy_metadata_drift = optional(bool, false)
      boot_order                   = optional(list(string))

      cdrom = optional(object({
        file_id   = string
        interface = optional(string)
      }))

      cpu = optional(object({
        cores        = optional(number)
        sockets      = optional(number)
        type         = optional(string)
        architecture = optional(string)
        limit        = optional(number)
        units        = optional(number)
        numa         = optional(bool)
      }))

      memory = optional(object({
        dedicated = optional(number)
        floating  = optional(number)
        swap      = optional(number)
      }))

      agent = optional(object({
        enabled              = optional(bool)
        timeout              = optional(string)
        trim                 = optional(bool)
        type                 = optional(string)
        wait_for_ip_disabled = optional(bool)
      }))

      startup = optional(object({
        order      = optional(number)
        up_delay   = optional(number)
        down_delay = optional(number)
      }))

      operating_system = optional(object({
        type             = optional(string)
        template_file_id = optional(string)
      }))

      disk = optional(object({
        datastore_id      = optional(string)
        interface         = optional(string)
        size              = optional(number)
        file_id           = optional(string)
        import_from       = optional(string)
        path_in_datastore = optional(string)
        cache             = optional(string)
        aio               = optional(string)
        iothread          = optional(bool)
        discard           = optional(string)
        replicate         = optional(bool)
        ssd               = optional(bool)
      }))

      disks = optional(list(object({
        datastore_id      = string
        interface         = string
        size              = optional(number)
        file_id           = optional(string)
        import_from       = optional(string)
        path_in_datastore = optional(string)
        cache             = optional(string)
        aio               = optional(string)
        iothread          = optional(bool)
        discard           = optional(string)
        replicate         = optional(bool)
        ssd               = optional(bool)
      })), [])

      network_devices = optional(list(object({
        bridge      = string
        model       = optional(string)
        firewall    = optional(bool)
        mac_address = optional(string)
        mtu         = optional(number)
        queues      = optional(number)
        rate_limit  = optional(number)
        vlan_id     = optional(number)
        trunks      = optional(string)
      })), [])

      initialization = optional(object({
        datastore_id         = optional(string)
        ipv4_address         = optional(string)
        ipv4_gateway         = optional(string)
        ipv6_address         = optional(string)
        ipv6_gateway         = optional(string)
        username             = optional(string)
        password             = optional(string)
        ssh_keys             = optional(list(string), [])
        upgrade              = optional(bool)
        user_data_file_id    = optional(string)
        network_data_file_id = optional(string)
        meta_data_file_id    = optional(string)
        vendor_data_file_id  = optional(string)
        hostname             = optional(string)
        dns_servers          = optional(list(string), [])
        dns_domain           = optional(string)
      }))

      clone = optional(object({
        node_name    = optional(string)
        vm_id        = number
        datastore_id = optional(string)
        full         = optional(bool)
        retries      = optional(number)
      }))

      features = optional(object({
        nesting = optional(bool)
        fuse    = optional(bool)
        keyctl  = optional(bool)
        mount   = optional(list(string))
        mknod   = optional(bool)
      }))

      mount_points = optional(list(object({
        volume        = string
        path          = string
        size          = optional(string)
        backup        = optional(bool)
        acl           = optional(bool)
        read_only     = optional(bool)
        quota         = optional(bool)
        shared        = optional(bool)
        mount_options = optional(list(string))
      })), [])

      idmap = optional(list(object({
        type         = string
        container_id = number
        host_id      = number
        size         = number
      })), [])

      network_interfaces = optional(list(object({
        name         = string
        bridge       = optional(string)
        enabled      = optional(bool)
        firewall     = optional(bool)
        host_managed = optional(bool)
        mac_address  = optional(string)
        mtu          = optional(number)
        rate_limit   = optional(number)
        vlan_id      = optional(number)
      })), [])
    }))

    aws = optional(object({
      region             = optional(string)
      instance_type      = optional(string)
      ami                = optional(string)
      subnet_id          = optional(string)
      security_group_ids = optional(list(string), [])
    }))
  }))

  validation {
    condition     = alltrue([for _, node in var.compute_nodes : contains(["proxmox", "aws"], lower(node.platform))])
    error_message = "platform must be one of: proxmox, aws"
  }
}
