variable "aws_region" {
  description = "Région AWS du bucket de state (et région par défaut des déploiements)."
  type        = string
  default     = "eu-west-3" # Paris
}

variable "github_repository" {
  description = "Dépôt GitHub autorisé à endosser le rôle, au format owner/repo (sensible à la casse)."
  type        = string
  default     = "EddyHE78/Terraform_ProjetAnnuel"
}

variable "state_bucket_name" {
  description = "Nom du bucket S3 de state. Doit être unique au niveau mondial."
  type        = string
}

variable "create_oidc_provider" {
  description = "Mettre à false si le fournisseur OIDC token.actions.githubusercontent.com existe déjà dans le compte."
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Nom du rôle IAM endossé par GitHub Actions."
  type        = string
  default     = "github-actions-terraform"
}
