locals {
  sizes = {
    small  = { cores = 1, memory = 1024, disk = 10 }
    medium = { cores = 2, memory = 2048, disk = 20 }
    large  = { cores = 4, memory = 4096, disk = 40 }
  }
  size = local.sizes[var.vm_size]

  static_ip     = var.network_cidr != ""
  prefix_length = local.static_ip ? split("/", var.network_cidr)[1] : ""
}

resource "proxmox_virtual_environment_vm" "vm" {
  count = var.vm_count

  name        = format("%s-%02d", var.name_prefix, count.index + 1)
  description = "Déployée par Terraform via GitHub Actions"
  tags        = ["terraform", "github-actions", var.vm_size]
  node_name   = var.proxmox_node
  vm_id       = var.vm_id_start + count.index
  on_boot     = true

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = var.qemu_agent
  }

  cpu {
    cores = local.size.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = local.size.memory
  }

  # Redimensionne le disque hérité du template.
  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = local.size.disk
  }

  network_device {
    bridge  = var.network_bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = local.static_ip ? "${cidrhost(var.network_cidr, var.ip_offset + count.index)}/${local.prefix_length}" : "dhcp"
        gateway = local.static_ip ? var.gateway : null
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.vm_user
      keys     = [trimspace(var.ssh_public_key)]
    }
  }
}
