
terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

# Fetches each VM's template name for re-create them unique to fetch the CL item data
locals {
  unique_cl_items = {
    for tpl in distinct([
      for v in values(var.vm_base_template) : v.template
    ]) :
    tpl.name => {
      template_name = tpl.name
      library_name  = tpl.library_name
    }
  }
}

# New Content Library items created manually between 2 runs(Just VM-Templates)
data "vsphere_content_library_item" "item" {
  for_each = local.unique_cl_items

  name       = each.value.template_name
  type       = "vm-template"
  library_id = var.all_content_libraries[each.value.library_name].id
}

# Merges all resolved CL items either existing or new ones 
locals {
  resolved_all_cli_ids = merge(
    try(var.former_content_library_item_ids, {}),
    data.vsphere_content_library_item.item
  )
}

# Fetches Templated VMs for cloning in case of missing templates in CL
data "vsphere_virtual_machine" "templated_machines" {
  for_each = local.unique_cl_items

  name = each.value.template_name
  datacenter_id = var.datacenter_id
}
