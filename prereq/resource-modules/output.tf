
output "new_resource_pool_ids" {
  value = {
    for k, v in vsphere_resource_pool.resource_pool_creation :
    k => {
        id = v.id
    }
  }
}

output "all_pools" {
  description = "All existing resource pools alongside with new created ones"
  value = local.all_pools
}

output "new_created_content_libraries" {
  description = "All created Content Libraries"
  value = { for k, v in vsphere_content_library.content_library_creation : v.name => v.id }
}
