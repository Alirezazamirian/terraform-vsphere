terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

# Main independent data fetchers
locals {
  # This extracts all unique library names so we don't fetch the same library twice
  unique_library_names = toset([
    for item in var.vsphere_content_library_items : item.library_name
  ])
}

# Merge all predefined, and default resource pools
locals {
  default_pool = {
    "default_pool" = data.vsphere_resource_pool.default_pool.id
  }

  entire_predefined_pools = {
    for k, v in data.vsphere_resource_pool.entire_predefined_pools :
    k => v.id
  }

  all_pools = merge(
    local.default_pool,
    local.entire_predefined_pools
  )
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter_name
}

data "vsphere_content_library" "library" {
  for_each = local.unique_library_names
  name     = each.value
}

# There is only one computer cluster for Charging, Thus there is no need make it flexible
data "vsphere_compute_cluster" "cluster" {
  depends_on = [ data.vsphere_datacenter.datacenter ]

  name          = var.vsphere_compute_cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Dynamically finds all hosts included in a variable
data "vsphere_host" "host" {
  depends_on = [ data.vsphere_datacenter.datacenter ]

  for_each      = toset(var.hosts)
  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Static Resource-pool for deplying multiple VM with multiple destination resource pools
data "vsphere_resource_pool" "entire_predefined_pools" {
  for_each = toset(var.entire_predefined_pools)
  depends_on = [ data.vsphere_datacenter.datacenter ]

  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default_pool" {
  depends_on = [ data.vsphere_datacenter.datacenter ]

  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Static Network adaptor(for dev/staging setup!)
data "vsphere_network" "network" {
  depends_on = [ data.vsphere_datacenter.datacenter ]
  for_each = toset(var.vsphere_network_names)

  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Multiple DataStore data fetching
data "vsphere_datastore" "datastore" {
  for_each = toset(var.datastore_list)
  depends_on = [ data.vsphere_datacenter.datacenter ]

  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Library items(OVF, OVA, Templates)
data "vsphere_content_library_item" "item" {
  for_each = var.vsphere_content_library_items != null ? var.vsphere_content_library_items : {}
  
  name       = each.value.name
  type       = each.value.type
  library_id = data.vsphere_content_library.library[each.value.library_name].id
}

# Acceptable only if OVF file is on remote, or local(host who running Terraform) storage
data "vsphere_ovf_vm_template" "base_ovf" {
  depends_on = [ data.vsphere_resource_pool.default_pool, data.vsphere_host.host ]
  for_each = coalesce(var.base_ovf_file, {})

  name = each.value.name
  resource_pool_id = data.vsphere_resource_pool.default_pool.id
  host_system_id = data.vsphere_host.host[each.value.host].id
  local_ovf_path = each.value.local_ovf_path
  remote_ovf_url = each.value.remote_ovf_url
}

# Fecthes data from VM's name
data "vsphere_virtual_machine" "vm_specifications" {
  for_each = toset(var.vm_specification_items)
  depends_on = [ data.vsphere_datacenter.datacenter ]
  
  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
