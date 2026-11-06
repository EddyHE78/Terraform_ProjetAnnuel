terraform {
  required_version = ">= 1.10.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }

  # Configuration partielle : bucket et région sont passés par le workflow
  # (terraform init -backend-config=...). Le state Proxmox est stocké sur S3.
  backend "s3" {
    key          = "proxmox/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
