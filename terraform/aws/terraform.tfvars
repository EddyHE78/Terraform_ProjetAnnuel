# Paramètres de l'infra AWS (non sensibles). À ADAPTER.
# Les paramètres "à la demande" (nombre, taille, préfixe) viennent du workflow.
# La région est passée par le workflow (variable GitHub AWS_REGION).

vpc_cidr           = "10.50.0.0/16"
public_subnet_cidr = "10.50.1.0/24"

# Remplace par ton IP publique en /32 pour limiter l'accès SSH.
ssh_allowed_cidrs = ["0.0.0.0/0"]
