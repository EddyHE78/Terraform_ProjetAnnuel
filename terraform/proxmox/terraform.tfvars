# Paramètres de ton infra Proxmox (non sensibles). À ADAPTER.
# Les paramètres "à la demande" (nombre, taille, préfixe) viennent du workflow.

proxmox_node   = "proxmox-baremetal"
template_vm_id = 9000 # créé par scripts/proxmox/create-template.sh
vm_id_start    = 200
datastore_id   = "local" # stockage "dir" : disques en qcow2

# Réseau : vmbr1 = bridge interne VLAN-aware ("LAN CONSTRUX")
network_bridge = "vmbr1"
vlan_id        = null # À DÉFINIR : VLAN des VM déployées

# Adressage : network_cidr = "" -> DHCP (si le routeur du VLAN en fournit un)
# Sinon, statique : network_cidr = "10.x.x.0/24", ip_offset et gateway = routeur du VLAN
network_cidr = ""
ip_offset    = 100
gateway      = ""
