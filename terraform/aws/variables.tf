# --- Paramètres pilotés par le workflow --------------------------------------

variable "vm_count" {
  description = "Nombre d'instances EC2 (0 = supprimer les instances)."
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
  description = "Préfixe du nom des instances."
  type        = string
  default     = "vm"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix : minuscules, chiffres et tirets uniquement (20 caractères max)."
  }
}

variable "ssh_public_key" {
  description = "Clé publique SSH pour la key pair EC2."
  type        = string
}

# --- Paramètres de l'infra AWS (terraform.tfvars) ---------------------------

variable "aws_region" {
  description = "Région AWS."
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR du VPC dédié au projet."
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR du sous-réseau public."
  type        = string
  default     = "10.50.1.0/24"
}

variable "ssh_allowed_cidrs" {
  description = "Plages autorisées en SSH. Mets ton IP publique (x.x.x.x/32) plutôt que 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
