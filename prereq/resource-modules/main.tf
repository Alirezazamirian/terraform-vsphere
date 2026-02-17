terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

locals {
  # Check if resource pools exist
  resource_pools_exist = var.resource_pools != null && length(var.resource_pools) > 0
  # Check if content libraries exist
  content_libraries_exist = var.content_library_creation != null && length(var.content_library_creation) > 0
}

resource "vsphere_resource_pool" "resource_pool_creation" {
  for_each = var.resource_pools != null ? var.resource_pools : {}

  name = each.key
  parent_resource_pool_id = var.default_pool
  cpu_share_level = try(each.value.cpu_share_level, "normal")
  cpu_shares = try(each.value.cpu_shares, null)
  cpu_reservation = try(each.value.cpu_reservation, null)
  cpu_expandable = try(each.value.cpu_expandable, true)
  cpu_limit = try(each.value.cpu_limit, -1)
  memory_expandable = try(each.value.memory_expandable, true)
  memory_share_level = try(each.value.memory_share_level, "normal")
  memory_reservation = try(each.value.memory_reservation, null)
  scale_descendants_shares = try(each.value.scale_descendants_shares, "disabled")
  memory_limit = try(each.value.memory_limit, -1)
  memory_shares = try(each.value.memory_shares, null)
}

# Creates CL if the relevant variable exists
resource "vsphere_content_library" "content_library_creation" {
  depends_on = [ var.data_datastore_ids ]
  for_each = var.content_library_creation != null ? var.content_library_creation : {}
  
  name            = each.key
  description     = each.value.description
  storage_backing = [var.data_datastore_ids[each.value.storage_backing]]
}

# Merge new resource pools
locals {
  created_resource_pools = local.resource_pools_exist ? {
    for k, v in vsphere_resource_pool.resource_pool_creation :
    k => v.id
  } : {}

  all_pools = merge(
    var.all_fetched_pools,
    local.created_resource_pools
  )
}
