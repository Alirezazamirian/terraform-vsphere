
variable "vsphere_user" {
  default = ""
}

variable "vsphere_user_pass" {
  default = ""
}

variable "vsphere_server" {
  default = ""
}

variable "general_dns_address" {
  description = "General DNS address that is attached on each VM"
  type = list(string)
  default = [ "192.168.20.1", "8.8.8.8" ]
}

variable "content_libraries" {
  description = "Following Content Libraries are going to be created through Vsphere"
}

# Each VM specifications alongside whole parameters
# variable "vm_template" {
#   description = "Template definition for a single VM"
#   type = map(object({
#     node_count = number
#     datastore = string
#     folder_path = string
#     template_name    = string
#     cpu         = number
#     memory     = number # in MB
#     hostnames         = list(string)
#     guest_id_from_vm = string
#     default_ipv4_gateway = string
#     dns_server_list = list(string)
#     resource_pool = string
#     networks  = list(object({
#       name              = string
#       ipv4s              = list(string)
#       attached_adaptor  = string
#       adapter_type      = string
#       subnet_mask       = string
#     }))
#     disks = list(object({
#       label           = string
#       size            = number # in GB
#       eagerly_scrub   = bool
#       thin_provisioned = bool
#     }))
#     cloud_init = any
#   }))
# }

# Template specifications to get created from manually defined OVFs at Vsphere web portal
variable "vm_base_template" {
  description = "Base VM Template for provisioning other VMs from"
  nullable = true

  type = map(object({
    datastore = string
    base_vm_name = string
    library_name = string
    folder_path = string #  Comes with DataCenter path as /<datacenter-name>/vm/
    annotation = string # same as description
    type = string # used for cl_item
    cpu = number
    memory = number
    network  = object({
      name              = string
      ipv4              = string
      attached_adaptor  = string
      adapter_type      = string
      subnet_mask       = string
      wait_for_guest_net_timeout = number
      wait_for_guest_net_routable = bool
      wait_for_guest_ip_timeout = number
    })
    disk = object({
      label           = string
      size            = number # in GB
      eagerly_scrub   = bool
      thin_provisioned = bool
    })
    cloud_init = any
  }))
}

# variable "folder_creation" {
#   description = "Creates folder required for VMs/Templates, if this section is filled, then the folders will be created at path /<datacenter-name>/<type>/name"
# }

# Resource Pools definitions to create under default manually created compute cluster
variable "resource_pools" {
  description = "Resource pools to accommodate VMs in"
}

variable "datastore_list" {
  description = "All available DataStores' name to fetch info(Used at data-modules)"
}

variable "base_ovf_file" {
  description = "All desired OVFs name to fetch their info(Used at data-modules)"
}

variable "vm_specification_items" {
  description = "All VMs' specifications to fetch their info(Used at data-modules)"
}

variable "hosts" {
  description = "All available hosts located at existing Vsphere portal(Used at data-modules)"
}

variable "vsphere_datacenter_name" {
  description = "Current single DataCenter existing at Vsphere portal(Used at data-modules)"
}

variable "vsphere_compute_cluster_name" {
  description = "Current single Cluster name existing at Vsphere portal(Used at data-modules)"
}

variable "entire_predefined_pools" {
  description = "Entire Resource Pools(Used at data-modules)"
}

variable "vsphere_network_names" {
  description = "All available network group names existing at Vsphere portal(Used at data-modules)"
}

variable "vsphere_content_library_items" {
  description = "All available content libraries with their items existing at Vsphere portal(Used at data-modules)"
  nullable = true
}

variable "general_vm_cloning_timeout" {
  description = "The timeout, in minutes, to wait for the cloning process to complete. Default: 30 minutes.(Used at provisioning module)"
}

# Setting the value to 0 or a negative value disables the waiter.
variable "general_customize_vm_timeout" {
  description = "The time, in minutes, that the provider waits for customization to complete before failing. Default is 10 minutes.(Used at provisioning module)"
}
