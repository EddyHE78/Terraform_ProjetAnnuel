# Bootstrap à exécuter UNE SEULE FOIS en local, avec des identifiants AWS admin.
# Il crée ce dont GitHub Actions a besoin :
#   - le bucket S3 qui stocke les states Terraform (proxmox + aws)
#   - le fournisseur d'identité OIDC GitHub
#   - le rôle IAM que les workflows endossent (aucune clé d'accès dans GitHub)
#
# Le state de ce bootstrap reste en local (terraform.tfstate, ignoré par git) :
# garde-le précieusement ou importe les ressources si tu le perds.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "projet-annuel"
      ManagedBy = "terraform-bootstrap"
    }
  }
}
