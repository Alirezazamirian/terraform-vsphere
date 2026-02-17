
# This variable has to be created manually
variable "vsphere_compute_cluster_name" {
  description = "Predefined Cluster name created manually at Vsphere portal"
  type = string
}

# This variable has to be created manually
variable "vsphere_datacenter_name" {
  description = "Predefined DataCenter name created manually at Vsphere portal"
  type = string
}

# This variable has to be joined and created manually
variable "hosts" {
  description = "ESXI hosts' IP joined at Vsphere portal manually"
  type = list(string)
}

# This variable has to be created manually
variable "entire_predefined_pools" {
  description = "Resource Pool names for putting VMs in individually, created manually at Vsphere portal"
  type = list(string)
  nullable = true
}

# This variable has to be created manually
variable "vsphere_network_names" {
  description = "Network Adaptors' name, created manually at Vsphere portal"
  type = list(string)
}

# This variable has to be created manually
variable "vsphere_content_library_items" {
  description = "All required OVF/OVA or VM templates with their content library created manually at Vsphere portal"
  nullable = true
  validation {
    condition = alltrue([
      for v in values(var.vsphere_content_library_items) :
      contains(["ovf", "vm-template", "iso"], v.type)
    ])
    error_message = "Content library item type must be ovf, vm-template, or iso."
  }
  type = map(object({
    name         = string
    description  = optional(string)
    type         = string
    library_name = string
  }))
}

variable "vm_specification_items" {
  description = "All usable VMs for provisioning another VMs from"
  type = list(string)
}

# This variable has to be created manually
variable "datastore_list" {
  description = "Existing DataStore indexes to find their info, reated manually at Vsphere portal"
  type = list(string)
}

variable "base_ovf_file" {
  description = "Fetch OVFs from the hosts to provision base VM"
  nullable    = true

  type = map(object({
    name           = string
    host           = string
    local_ovf_path = optional(string)
    remote_ovf_url = optional(string)
  }))

  validation {
    condition = (
      var.base_ovf_file == null ||
      alltrue([
        for k, v in var.base_ovf_file :
        (
          (v.local_ovf_path != null ? 1 : 0) +
          (v.remote_ovf_url != null ? 1 : 0)
        ) == 1
      ])
    )
    error_message = "Exactly one of local_ovf_path or remote_ovf_url must be set for each base_ovf_file entry."
  }
}
