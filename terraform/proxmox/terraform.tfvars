# Paramètres de ton infra Proxmox (non sensibles).
# Les paramètres "à la demande" (nombre, taille, préfixe) viennent du workflow.

proxmox_node   = "proxmox-baremetal"
template_vm_id = 9000    # ubuntu-2404-cloudinit (scripts/proxmox/create-template.sh)
vm_id_start    = 200     # VMID 200, 201, ... (hors des VM existantes 100-113)
datastore_id   = "local" # stockage "dir" : disques en qcow2

# Réseau : vmbr1 = bridge interne VLAN-aware ("LAN CONSTRUX"), routé par OPNsense
network_bridge = "vmbr1"
vlan_id        = 100

# VLAN 100 sans DHCP : adressage statique
network_cidr = "192.168.100.0/24"
ip_offset    = 200               # -> 192.168.100.200, .201, ... (jusqu'à .209 pour 10 VM)
gateway      = "192.168.100.254" # OPNsense
