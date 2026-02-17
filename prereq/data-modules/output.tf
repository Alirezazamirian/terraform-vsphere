output "ovf_template_export_items" {
  description = "Export parameters for templating base VM's OVF"

  value = {
    for k, v in data.vsphere_ovf_vm_template.base_ovf :
    k => {
      guest_id  = v.guest_id
      firmware  = v.firmware
      memory    = v.memory
      cpu       = v.num_cpus
    }
  }
}

output "entire_predefined_pools" {
  description = "ID of the Resource-pool to provision VMs on"
  value = {
    for k, pool in data.vsphere_resource_pool.entire_predefined_pools :
    k => {
      id = pool.id
    }
  }
}

output "default_pool" {
  description = "ID of the default Resource-pool to provision OVF as a templatable VM on"
  value = data.vsphere_resource_pool.default_pool
}

output "all_fetched_pools" {
  description = "All predefined and ESXI's default resource pools to expose"
  value = local.all_pools
}

output "datacenter" {
  description = "Name & ID of the DataCenter to provision VMs on"
  value = {
    name = data.vsphere_datacenter.datacenter.name
    id = data.vsphere_datacenter.datacenter.id
  }
}

output "network_ids" {
  value = { for k, v in data.vsphere_network.network : v.name => v.id }
}

output "content_library_item_ids" {
  value = { for k, v in data.vsphere_content_library_item.item : v.name => v.id }
}

output "datastore_ids" {
  value = { for k, v in data.vsphere_datastore.datastore : v.name => v.id }
}

output "content_libraries" {
  value = {
    for k, lib in data.vsphere_content_library.library :
    k => {
      id   = lib.id
      name = lib.name
    }
  }
}

output "base_vm_exports" {
  description = "Map of required VM details"
  value = {
    for k, vm in data.vsphere_virtual_machine.vm_specifications :
    k => {
      id = vm.id
      firmware = vm.firmware
      guest_id = vm.guest_id
    }
  }
}
