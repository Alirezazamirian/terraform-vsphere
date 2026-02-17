
# This output has been implemented for future use for another project if it probably happens
output "deployed_vms_attrs" {
  description = "Attributes of created VMs"

  value = {
    for k, m in module.provision_machines :
    k => m.created_vms_export_items
  }
}

