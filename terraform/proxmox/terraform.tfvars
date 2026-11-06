# Paramètres de ton infra Proxmox (non sensibles). À ADAPTER.
# Les paramètres "à la demande" (nombre, taille, préfixe) viennent du workflow.

proxmox_node   = "proxmox-baremetal"
template_vm_id = 9000 # créé par scripts/proxmox/create-template.sh
vm_id_start    = 200
datastore_id   = "local" # stockage "dir" : disques en qcow2
network_bridge = "vmbr1" # bridge privé NATé des VM

# Adressage statique (laisser network_cidr = "" pour du DHCP)
network_cidr = "10.10.10.0/24"
ip_offset    = 100          # -> 10.10.10.100, .101, ...
gateway      = "10.10.10.1" # IP du host Proxmox sur vmbr1
