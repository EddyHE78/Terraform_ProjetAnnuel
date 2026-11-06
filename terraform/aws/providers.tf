# Les identifiants viennent de l'OIDC GitHub (aws-actions/configure-aws-credentials).
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "projet-annuel"
      ManagedBy = "terraform"
      Source    = "github-actions"
    }
  }
}
