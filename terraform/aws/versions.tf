terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Configuration partielle : bucket et région passés par le workflow.
  backend "s3" {
    key          = "aws/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
