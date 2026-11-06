terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # State stocké sur Scaleway Object Storage (compatible S3), bucket en fr-par.
  # Le bucket et les clés API Scaleway sont passés par le workflow
  # (terraform init -backend-config=...). Pas de verrou natif : le workflow
  # sérialise les runs par stack (concurrency), ce qui suffit ici.
  backend "s3" {
    key    = "aws/terraform.tfstate"
    region = "fr-par"

    endpoints = {
      s3 = "https://s3.fr-par.scw.cloud"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
