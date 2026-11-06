# --- Paramètres pilotés par le workflow (formulaire "Run workflow") ---------

variable "vm_count" {
  description = "Nombre de VM à déployer (0 = tout supprimer)."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 0 && var.vm_count <= 10
    error_message = "vm_count doit être compris entre 0 et 10."
  }
}

variable "vm_size" {
  description = "Gabarit des VM : small, medium ou large."
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large"], var.vm_size)
    error_message = "vm_size doit valoir small, medium ou large."
  }
}

variable "name_prefix" {
  description = "Préfixe du nom des VM (ex: web -> web-01, web-02…)."
  type        = string
  default     = "vm"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix : minuscules, chiffres et tirets uniquement (20 caractères max)."
  }
}

variable "ssh_public_key" {
  description = "Clé publique SSH injectée via cloud-init."
  type        = string
}

# --- Paramètres de l'infra Proxmox (terraform.tfvars) ----------------------

variable "proxmox_node" {
  description = "Nom du nœud Proxmox (hostname affiché dans l'interface)."
  type        = string
}

variable "template_vm_id" {
  description = "ID de la VM template cloud-init à cloner."
  type        = number
  default     = 9000
}

variable "vm_id_start" {
  description = "Premier VMID utilisé ; les VM prennent vm_id_start, +1, +2…"
  type        = number
  default     = 200
}

variable "datastore_id" {
  description = "Stockage des disques des VM (ex: local-lvm, local-zfs)."
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Bridge réseau des VM (sur Scaleway, souvent un bridge privé NATé comme vmbr1)."
  type        = string
  default     = "vmbr1"
}

variable "network_cidr" {
  description = "Réseau des VM pour l'adressage statique (ex: 10.10.10.0/24). Vide = DHCP."
  type        = string
  default     = ""
}

variable "ip_offset" {
  description = "Première adresse hôte attribuée dans network_cidr (ex: 100 -> 10.10.10.100)."
  type        = number
  default     = 100
}

variable "gateway" {
  description = "Passerelle des VM en adressage statique (souvent l'IP du host sur le bridge)."
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "Serveurs DNS injectés via cloud-init."
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}

variable "vm_user" {
  description = "Utilisateur créé par cloud-init."
  type        = string
  default     = "ubuntu"
}

variable "qemu_agent" {
  description = "Active le QEMU guest agent (le template doit l'avoir installé, sinon l'apply attend jusqu'au timeout)."
  type        = bool
  default     = true
}
