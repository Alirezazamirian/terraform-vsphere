
terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_user_pass
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl  = true
  api_timeout          = 2700
  vim_keep_alive = 240
}

data "terraform_remote_state" "prereq" {
  backend = "local"

  config = {
    path = "${path.module}/../prereq/terraform.tfstate"
  }
}

locals {
  prereq = data.terraform_remote_state.prereq.outputs.prereq
}

# Makes each VM's folder arg unique for creation
locals {
  vm_unique_folders = {
    for folder in toset([
      for _, vm in var.vm_template : vm.folder_path
    ]) :
    folder => {
      name = folder
      type = "vm"
    }
  }
}

resource "vsphere_folder" "vm_folders" {
  for_each = local.vm_unique_folders

  path          = each.value.name
  type          = each.value.type
  datacenter_id = local.prereq.datacenter.id
}

module "prerequisites_data" {
  source = "./data-modules"

  all_content_libraries = local.prereq.all_content_libraries
  former_content_library_item_ids = local.prereq.former_content_library_item_ids
  # vm_base_template = local.prereq.vm_base_template
  vm_base_template = var.vm_template
  datacenter_id = local.prereq.datacenter.id
}

module "provision_machines" {
  for_each = var.vm_template != null ? var.vm_template : {}
  depends_on = [
    data.terraform_remote_state.prereq,
    module.prerequisites_data,
    vsphere_folder.vm_folders
  ]
  source = "./provisioning"

  node_count    = each.value.node_count
  hostnames     = each.value.hostnames
  cpu           = each.value.cpu
  memory        = each.value.memory
  template_uuid = try(
    module.prerequisites_data.all_cl_item_ids[each.value.template.name],
    module.prerequisites_data.templated_machines[each.value.template.name].id
  )
  resource_pool_id = local.prereq.all_pools[each.value.resource_pool]
  datastore_id     = local.prereq.datastore_ids[each.value.datastore]
  folder = each.value.folder_path
  networks = each.value.networks
  network_id_map = local.prereq.network_ids
  disks = each.value.disks
  firmware = local.prereq.base_vm_exports[each.value.guest_id_from_vm].firmware
  guest_id = local.prereq.base_vm_exports[each.value.guest_id_from_vm].guest_id
  dns_server_list = each.value.dns_server_list
  default_ipv4_gateway = each.value.default_ipv4_gateway
  cloud_init = each.value.cloud_init
}