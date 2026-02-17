
output "prereq" {
  description = "All data needed by the deployment project"
  value = {

    # From data-modules
    datacenter               = module.prerequisites_data.datacenter
    network_ids              = module.prerequisites_data.network_ids
    datastore_ids            = module.prerequisites_data.datastore_ids
    former_content_library_item_ids = module.prerequisites_data.content_library_item_ids
    former_fetched_pools        = module.prerequisites_data.all_fetched_pools
    base_vm_exports          = module.prerequisites_data.base_vm_exports

    # From resource-modules
    all_pools                = module.prerequisites_resources.all_pools
    vm_base_template         = var.vm_base_template

    # From both
    all_content_libraries    = local.all_content_libraries

    # From the base templates
    template_creation = {
      for k, m in module.template_creation : k => {
        id   = m.id
        name = m.name
      }
    }
  }
}
