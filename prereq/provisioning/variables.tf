
variable "resource_pool_id" {
  description = "The main resource pool ID to deploy VM-Templates on"
  type = string
}

variable "datastore_id" {
  description = "The main DataStore ID to deploy templates on"
  type = string
}

variable "firmware" {
  description = "VM's template firmware"
  type        = string

  validation {
    condition     = contains(["efi", "bios"], lower(var.firmware))
    error_message = "firmware must be either 'efi' or 'bios' (case-insensitive)."
  }
}

variable "template_uuid" {
  description = "Source VM UUID to build new template from"
  type = string
}

variable "guest_id" {
  description = "Guest ID of the template's OS"
  type = string
}

variable "network" {
  description = "Network adaptors to attach the new template"
  type = object({
    name              = string
    ipv4              = string
    attached_adaptor  = string
    adapter_type      = string
    subnet_mask       = string
    wait_for_guest_net_timeout = number # The amount of time, in minutes, to wait for an available guest IP address on the virtual machine
    wait_for_guest_net_routable = bool # Controls whether or not the guest network waiter waits for a routable address
    wait_for_guest_ip_timeout = number # The amount of time, in minutes, to wait for an available guest IP address on the virtual machine
  })
}

variable "network_id" {
  description = "Default network ID of adapter type"
  type = string
}

variable "hostname" {
  description = "VM Template's hostname"
  type = string
}

variable "cpu" {
  description = "VM Template's CPU numbers"
  type        = number

  validation {
    condition     = var.cpu >= 1
    error_message = "CPU count must be 1 or greater."
  }
}

variable "memory" {
  description = "VM Template's memory space (MB)"
  type        = number

  validation {
    condition     = var.memory >= 1024
    error_message = "Memory must be 1024 MB or greater."
  }
}

variable "disk" {
  description = "A sample disk attached to template"
  type = object({
    label            = string
    size             = number # in GB
    eagerly_scrub    = bool
    thin_provisioned = bool
  })

  validation {
    condition = (
      var.disk.size == null || var.disk.size >= 50
    )
    error_message = "Disk size must be 50 GB or greater if set."
  }
}

variable "annotation" {
  description = "A breif description of template shown at content library notes"
  type = string
}

variable "dns_server_list" {
  description = "DNS server list for new template"
  type = list(string)
  nullable = true
  default = null
}

variable "default_ipv4_gateway" {
  description = "The IPV4 gateway to set on template as default route"
  type = string
  nullable = true
  default = null
}

variable "folder" {
  description = "Default folder to put new VMs as freezed template in, relative to the datacenter path (/<datacenter-name>/vm)"
  type = string
}

variable "general_vm_cloning_timeout" {
  description = "The timeout, in minutes, to wait for the cloning process to complete. Default: 30 minutes."
  type = number
  default = 60
}

# Setting the value to 0 or a negative value disables the waiter.
variable "general_customize_vm_timeout" {
  description = "The time, in minutes, that the provider waits for customization to complete before failing. Default is 10 minutes."
  type = number
  default = 30
}

variable "cloud_init" {
  description = "This variable contains all relevant cloud-init configurations"
  nullable = true

  type = object({
    users = optional(list(object({
      name          = string
      gecos         = optional(string)
      primary_group = string
      lock_passwd   = bool
      groups        = list(string)
      sudo          = string
      passwd        = string
      shell         = string
      ssh_authorized_keys = list(string)
    })), [])
    runcmd = optional(list(string), [])
    growpart_devices = list(string)
    fs_setup = optional(list(object({
      label = string
      filesystem = string
      device = string
    })), [])
    package_update = optional(bool, false)
    package_upgrade = optional(bool, false)
    disable_root = optional(bool, true)
    resize_rootfs = optional(bool, true)
    ssh_pwauth = optional(bool, false)
    timezone = string
    manage_resolv_conf = optional(object({
      domain = optional(string, "charging.local")
      nameservers = optional(list(string), ["192.168.20.1", "8.8.8.8"])
      options = optional(object({
        rotate = optional(bool, false)
        timeout = optional(number, 1)
      }))
      searchdomains = optional(list(string), ["siz-tel.local", "charging.local"])
      sortlist = optional(list(string))
    }), {})
    yum_repos = optional(list(object({
      name = string
      title = string
      gpgcheck = bool
      gpgkey = string
      enabled_metadata = optional(bool)
      baseurl = string
      skip_if_unavailable = optional(bool)
      priority = number
    })), [])
    bootcmd = optional(list(string), [])
  })

  default = {
    growpart_devices = [ "/dev/sda3" ]
    timezone = "Iran"
  }
}
