
output "all_cl_item_ids" {
  value = { for k, v in data.vsphere_content_library_item.item : v.name => v.id }
}

# Export items from VMs
output "templated_machines" {
  description = "This attr is exposed from Templated VM which handled manually in pause, in case of empty result from CL items type 'vm-template'"
  value = {
    for k, vm in data.vsphere_virtual_machine.templated_machines :
    k => {
      id = vm.id
    }
  }
}
