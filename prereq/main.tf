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

module "prerequisites_data" {
  source = "./data-modules"

  datastore_list = var.datastore_list
  vsphere_datacenter_name = var.vsphere_datacenter_name
  vsphere_network_names = var.vsphere_network_names
  vsphere_compute_cluster_name = var.vsphere_compute_cluster_name
  vsphere_content_library_items = var.vsphere_content_library_items
  vm_specification_items = var.vm_specification_items
  hosts = var.hosts
  entire_predefined_pools = var.entire_predefined_pools
  base_ovf_file = var.base_ovf_file
}

# Makes folder arg unique for entire VM-Templates
locals {
  template_unique_folders = {
    for folder in toset([
      for _, vm in var.vm_base_template : vm.folder_path
    ]) :
    folder => {
      name = folder
      type = "vm"
    }
  }
}

resource "vsphere_folder" "template_folders" {
  for_each = local.template_unique_folders

  path          = each.value.name
  type          = each.value.type
  datacenter_id = module.prerequisites_data.datacenter.id
}

module "template_creation" {
  for_each = var.vm_base_template != null ? var.vm_base_template : {}
  depends_on = [ module.prerequisites_data, vsphere_folder.template_folders ]
  source = "./provisioning"

  hostname = each.key
  cpu = each.value.cpu
  memory = each.value.memory
  annotation = each.value.annotation
  firmware = module.prerequisites_data.base_vm_exports[each.value.base_vm_name].firmware
  network = each.value.network
  network_id = module.prerequisites_data.network_ids[each.value.network.attached_adaptor]
  cloud_init = each.value.cloud_init
  disk = each.value.disk
  template_uuid    = module.prerequisites_data.base_vm_exports[each.value.base_vm_name].id
  resource_pool_id = module.prerequisites_data.default_pool.id
  datastore_id     = module.prerequisites_data.datastore_ids[each.value.datastore]
  folder = each.value.folder_path
  guest_id = module.prerequisites_data.base_vm_exports[each.value.base_vm_name].guest_id
  general_vm_cloning_timeout = var.general_vm_cloning_timeout
  general_customize_vm_timeout = var.general_customize_vm_timeout
}

module "prerequisites_resources" {
  depends_on = [ module.prerequisites_data, module.template_creation ]
  source = "./resource-modules"

  resource_pools = try(var.resource_pools, null)
  default_pool = module.prerequisites_data.default_pool.id
  data_datastore_ids = module.prerequisites_data.datastore_ids
  content_library_creation = try(var.content_libraries, null)
  all_fetched_pools = module.prerequisites_data.all_fetched_pools
}

# Merging all existing/new content libraries from resources & data modules
locals {
  all_content_libraries = merge(
    try(module.prerequisites_resources.new_created_content_libraries, {}),
    try(module.prerequisites_data.content_libraries, {})
  )
}
