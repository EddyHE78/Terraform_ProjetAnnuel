output "vms" {
  description = "Instances déployées : nom -> ID, type et IP publique."
  value = {
    for vm in aws_instance.vm : vm.tags["Name"] => {
      instance_id   = vm.id
      instance_type = vm.instance_type
      public_ip     = vm.public_ip
      ssh           = "ssh ubuntu@${vm.public_ip}"
    }
  }
}
