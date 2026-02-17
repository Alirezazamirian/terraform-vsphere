terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

locals {
  vm_nics = {
    for i in range(var.node_count) : i => [
      for n in var.networks : {
        ipv4         = n.ipv4s[i]
        netmask      = n.subnet_mask
        adapter_type = n.adapter_type
        network_id   = var.network_id_map[n.attached_adaptor]
      }
    ]
  }
}

resource "vsphere_virtual_machine" "base-setup" {
  count            = var.node_count
  name             = var.hostnames[count.index]
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  folder = var.folder

  num_cpus = var.cpu
  memory   = var.memory
  guest_id = var.guest_id
  firmware = var.firmware

  dynamic "network_interface" {
    for_each = local.vm_nics[count.index]
    content {
      network_id   = network_interface.value.network_id
      adapter_type = network_interface.value.adapter_type
    }
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      label            = disk.value.label
      size             = disk.value.size
      thin_provisioned = disk.value.thin_provisioned
      eagerly_scrub    = disk.value.eagerly_scrub
      unit_number      = disk.key 
    }
  }

  clone {
    timeout = var.general_vm_cloning_timeout
    template_uuid = var.template_uuid
    customize {
      linux_options {
        host_name = var.hostnames[count.index]
        domain    = ""
      }
      dns_server_list = var.dns_server_list
      dynamic "network_interface" {
        for_each = local.vm_nics[count.index]
        content {
          ipv4_address = network_interface.value.ipv4
          ipv4_netmask = network_interface.value.netmask
        }
      }
      ipv4_gateway = var.default_ipv4_gateway
      timeout = var.general_customize_vm_timeout
    }
  }
  extra_config = {
    "guestinfo.userdata" = base64encode(
      templatefile("${path.module}/cloud-init.tftpl", {
        cloud_init = var.cloud_init
      })
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}
