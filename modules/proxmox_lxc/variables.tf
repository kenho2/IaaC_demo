variable "name" {
  description = "Container name"
  type        = string
}

variable "node_name" {
  description = "Target Proxmox node"
  type        = string
}

variable "vm_id" {
  description = "Optional stable container ID"
  type        = number
  default     = null
}

variable "description" {
  description = "Container description"
  type        = string
  default     = null
}

variable "tags" {
  description = "Container tags"
  type        = list(string)
  default     = []
}

variable "pool_id" {
  description = "Optional Proxmox pool"
  type        = string
  default     = null
}

variable "started" {
  description = "Start the container after creation"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Start the container on host boot"
  type        = bool
  default     = true
}

variable "protection" {
  description = "Protect the container from accidental removal"
  type        = bool
  default     = false
}

variable "unprivileged" {
  description = "Run the container as unprivileged"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "Container CPU configuration"
  type = object({
    architecture = optional(string)
    cores        = optional(number)
    limit        = optional(number)
    units        = optional(number)
  })
  default = null
}

variable "memory" {
  description = "Container memory configuration"
  type = object({
    dedicated = optional(number)
    swap      = optional(number)
  })
  default = null
}

variable "features" {
  description = "Container feature flags"
  type = object({
    nesting = optional(bool)
    fuse    = optional(bool)
    keyctl  = optional(bool)
    mount   = optional(list(string))
    mknod   = optional(bool)
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

variable "disk" {
  description = "Root filesystem disk"
  type = object({
    datastore_id = optional(string)
    size         = optional(number)
    mount_options = optional(list(string))
  })
  default = null
}

variable "mount_points" {
  description = "Additional mount points"
  type = list(object({
    volume        = string
    path          = string
    size          = optional(string)
    backup        = optional(bool)
    acl           = optional(bool)
    read_only     = optional(bool)
    quota         = optional(bool)
    shared        = optional(bool)
    mount_options = optional(list(string))
  }))
  default = []
}

variable "idmap" {
  description = "UID/GID mapping entries for unprivileged containers"
  type = list(object({
    type         = string
    container_id = number
    host_id      = number
    size         = number
  }))
  default = []
}

variable "network_interfaces" {
  description = "Container network interfaces"
  type = list(object({
    name        = string
    bridge      = optional(string)
    enabled     = optional(bool)
    firewall    = optional(bool)
    host_managed = optional(bool)
    mac_address = optional(string)
    mtu         = optional(number)
    rate_limit  = optional(number)
    vlan_id     = optional(number)
  }))
  default = []
}

variable "initialization" {
  description = "Container initialization configuration"
  type = object({
    datastore_id         = optional(string)
    ipv4_address         = optional(string)
    ipv4_gateway         = optional(string)
    ipv6_address         = optional(string)
    ipv6_gateway         = optional(string)
    username             = optional(string)
    password             = optional(string)
    ssh_keys             = optional(list(string), [])
    hostname             = optional(string)
    dns_servers          = optional(list(string), [])
    dns_domain           = optional(string)
    entrypoint           = optional(string)
    user_data_file_id    = optional(string)
    network_data_file_id = optional(string)
    meta_data_file_id    = optional(string)
    vendor_data_file_id   = optional(string)
  })
  default = null
}

variable "operating_system" {
  description = "LXC operating system configuration"
  type = object({
    template_file_id = string
    type             = string
  })
}

variable "clone" {
  description = "Clone configuration"
  type = object({
    node_name    = optional(string)
    vm_id        = number
    datastore_id = optional(string)
    full         = optional(bool)
  })
  default = null
}
