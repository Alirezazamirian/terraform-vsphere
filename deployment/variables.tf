
variable "vsphere_user" {
  default = ""
}

variable "vsphere_user_pass" {
  default = ""
}

variable "vsphere_server" {
  default = ""
}

# Each VM specifications alongside whole parameters
variable "vm_template" {
  description = "Template definition for a single VM"
  type = map(object({
    node_count = number
    datastore = string
    folder_path = string
    template = object({
      name = string
      library_name = string
    })
    cpu         = number
    memory     = number # in MB
    hostnames         = list(string)
    guest_id_from_vm = string
    default_ipv4_gateway = string
    dns_server_list = list(string)
    resource_pool = string
    networks  = list(object({
      name              = string
      ipv4s              = list(string)
      attached_adaptor  = string
      adapter_type      = string
      subnet_mask       = string
    }))
    disks = list(object({
      label           = string
      size            = number # in GB
      eagerly_scrub   = bool
      thin_provisioned = bool
    }))
    cloud_init = any
  }))
}
