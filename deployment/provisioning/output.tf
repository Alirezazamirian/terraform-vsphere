
output "created_vms_export_items" {
  description = "Atributes of created VMs from base-setup module in case of futute use or the extendability of project"
  value = {
    for k, vm in vsphere_virtual_machine.base-setup :
    k => {
        # The VM UUID
        id = vm.id
        # The vmx file path inside relevant ESXI's filesystem
        vmx_path = vm.vmx_path
        # The state of power which only includes 'on', 'off', or 'suspended'
        power_state = vm.power_state
        # The current list of IP addresses on this machine
        guest_ip_addresses = vm.guest_ip_addresses
        num_cpus = vm.num_cpus
        memory = vm.memory
        firmware = vm.firmware
        guest_id = vm.guest_id
        datastore_id = vm.datastore_id
        folder = vm.folder
        vmware_tools_status = vm.vmware_tools_status
    }
  }
}
