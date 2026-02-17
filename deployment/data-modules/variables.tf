
variable "all_content_libraries" {
  description = "All Content Libraries exist at Vsphere including new/former ones which were added during the pause"
}

variable "former_content_library_item_ids" {
  description = "All former CL items which existed previously that fetched from run 1"
}

variable "vm_base_template" {
  description = "Each VM-Template created manually between 2 runs"
  type = any
}

variable "datacenter_id" {
  description = "Main DC ID to use it for fetching the Templated VMs for cloning"
}
