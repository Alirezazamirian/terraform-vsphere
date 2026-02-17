# Valued at Vsphere portal manually
variable "default_pool" {
  description = "default computer cluster fetched from data modules"
}

# Valued at root variables.tf as empty, filled at terraform.tfvars
variable "content_library_creation" {
  description = "Following Content Libraries are going to be created through Vsphere(Defined as 'content_libraries' at root variables.tf)"
  nullable = true
  type = map(object({
    storage_backing = string  # Name of the relevant DataStore
    description = string
  }))
}

# Valued at data-modules because of manually valued at Vsphere portal
variable "data_datastore_ids" {
  description = "Info about main DataStores ID that this CL is going to be deployed on"
}

# Valued at root variables.tf as empty, filled at terraform.tfvars
variable "resource_pools" {
  description = "Resource_pool items to get created for VMs' resource limitations and accelerations"
  nullable = true
  type = map(object({
    cpu_share_level = optional(string)
    cpu_shares    = optional(number)
    cpu_reservation = optional(number) # in MHz(out of 92 GHz)
    cpu_expandable = optional(bool)
    cpu_limit = optional(number) # in MHz(out of 92 GHz)
    memory_share_level = optional(string)
    memory_shares = optional(number)
    memory_reservation = optional(number) # in MB(out of 300 GB)
    memory_expandable = optional(bool)
    memory_limit = optional(number) # in MB(out of 300 GB)
    scale_descendants_shares = optional(string) # can be one of "disabled" or "scaleCpuAndMemoryShares"
    tags = optional(string)
  }))
}

# Valued automatically at data-modules
variable "all_fetched_pools" {
  description = "All fetched pools either created manually or existed formerly from data-modules"
  type = any
}
