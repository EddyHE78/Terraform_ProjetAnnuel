output "vms" {
  description = "VM déployées : nom -> VMID et IP."
  value = {
    for i, vm in proxmox_virtual_environment_vm.vm : vm.name => {
      vm_id = vm.vm_id
      ip = local.static_ip ? cidrhost(var.network_cidr, var.ip_offset + i) : try(
        [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0],
        "inconnue (agent QEMU absent ?)"
      )
    }
  }
}
