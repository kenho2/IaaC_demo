variable "name" {
  description = "Virtual machine name"
  type        = string
}

variable "node_name" {
  description = "Target Proxmox node"
  type        = string
}

variable "vm_id" {
  description = "Optional stable VM ID"
  type        = number
  default     = null
}

variable "description" {
  description = "VM description"
  type        = string
  default     = null
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = []
}

variable "pool_id" {
  description = "Optional Proxmox pool"
  type        = string
  default     = null
}

variable "started" {
  description = "Start the VM after creation"
  type        = bool
  default     = true
}

variable "on_boot" {
  description = "Start the VM on host boot"
  type        = bool
  default     = true
}

variable "protection" {
  description = "Protect the VM from accidental removal"
  type        = bool
  default     = false
}

variable "stop_on_destroy" {
  description = "Stop rather than shutdown on destroy"
  type        = bool
  default     = true
}

variable "reboot_after_update" {
  description = "Allow provider-driven reboot during updates"
  type        = bool
  default     = true
}

variable "boot_order" {
  description = "Optional explicit boot device order, for example [\"ide2\", \"scsi0\", \"net0\"]."
  type        = list(string)
  default     = null
}

variable "cpu" {
  description = "CPU configuration"
  type = object({
    cores        = optional(number)
    sockets      = optional(number)
    type         = optional(string)
    architecture = optional(string)
    limit        = optional(number)
    units        = optional(number)
    numa         = optional(bool)
  })
  default = null
}

variable "memory" {
  description = "Memory configuration"
  type = object({
    dedicated = optional(number)
    floating  = optional(number)
  })
  default = null
}

variable "agent" {
  description = "QEMU agent configuration"
  type = object({
    enabled = optional(bool)
    timeout = optional(string)
    trim    = optional(bool)
    type    = optional(string)
    wait_for_ip_disabled = optional(bool)
  })
  default = null
}

variable "startup" {
  description = "Startup order and delays"
  type = object({
    order      = optional(number)
    up_delay   = optional(number)
    down_delay = optional(number)
  })
  default = null
}

variable "operating_system" {
  description = "Operating system configuration"
  type = object({
    type            = optional(string)
    template_file_id = optional(string)
  })
  default = null
}

variable "disk" {
  description = "Primary boot disk"
  type = object({
    datastore_id     = optional(string)
    interface        = optional(string)
    size             = optional(number)
    file_id          = optional(string)
    import_from      = optional(string)
    path_in_datastore = optional(string)
    cache            = optional(string)
    aio              = optional(string)
    iothread         = optional(bool)
    discard          = optional(string)
    replicate        = optional(bool)
    ssd              = optional(bool)
  })
  default = null
}

variable "cdrom" {
  description = "Optional CD-ROM attachment, typically an installer ISO."
  type = object({
    file_id   = string
    interface = optional(string)
  })
  default = null
}

variable "disks" {
  description = "Additional disks"
  type = list(object({
    datastore_id     = string
    interface        = string
    size             = optional(number)
    file_id          = optional(string)
    import_from      = optional(string)
    path_in_datastore = optional(string)
    cache            = optional(string)
    aio              = optional(string)
    iothread         = optional(bool)
    discard          = optional(string)
    replicate        = optional(bool)
    ssd              = optional(bool)
  }))
  default = []
}

variable "network_devices" {
  description = "Network devices"
  type = list(object({
    bridge      = string
    model       = optional(string)
    firewall    = optional(bool)
    mac_address = optional(string)
    mtu         = optional(number)
    queues      = optional(number)
    rate_limit  = optional(number)
    vlan_id     = optional(number)
    trunks      = optional(string)
  }))
  default = []
}

variable "initialization" {
  description = "Cloud-init configuration"
  type = object({
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
    vendor_data_file_id   = optional(string)
    hostname             = optional(string)
    dns_servers          = optional(list(string), [])
    dns_domain           = optional(string)
  })
  default = null
}

variable "clone" {
  description = "Clone configuration"
  type = object({
    node_name    = optional(string)
    vm_id        = number
    datastore_id = optional(string)
    full         = optional(bool)
    retries      = optional(number)
  })
  default = null
}

