terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

# This module creates VM-Template with existing VM at vsphere portal 
resource "vsphere_virtual_machine" "base-template" {

  name             = var.hostname
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  folder = var.folder

  num_cpus = var.cpu
  memory   = var.memory
  guest_id = var.guest_id
  firmware = var.firmware
  annotation = var.annotation

  network_interface {
      network_id   = var.network_id
      adapter_type = try(var.network.adapter_type, null)
  }
  wait_for_guest_ip_timeout = var.network.wait_for_guest_ip_timeout
  wait_for_guest_net_routable = var.network.wait_for_guest_net_routable
  wait_for_guest_net_timeout = var.network.wait_for_guest_net_timeout

  disk {
      label            = var.disk.label
      size             = var.disk.size
      thin_provisioned = var.disk.thin_provisioned
      eagerly_scrub    = var.disk.eagerly_scrub
  }

  clone {
    timeout = var.general_vm_cloning_timeout
    template_uuid = var.template_uuid
    customize {
      linux_options {
        host_name = var.hostname
        domain    = ""
      }
      dns_server_list = try(var.dns_server_list, null)
      network_interface {
          ipv4_address = try(var.network.ipv4, null)
          ipv4_netmask = try(var.network.subnet_mask, null)
        }
      ipv4_gateway = try(var.default_ipv4_gateway, null)
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
