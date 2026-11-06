#!/usr/bin/env bash
# Crée l'utilisateur terraform@pve et un token d'API pour GitHub Actions.
# À lancer en root SUR le host Proxmox :  bash create-api-token.sh
# Le secret du token n'est affiché QU'UNE FOIS : copie-le dans le secret
# GitHub PROXMOX_API_TOKEN au format  terraform@pve!github=<secret>
set -euo pipefail

USER_ID="terraform@pve"
TOKEN_ID="github"

pveum user add "$USER_ID" --comment "Terraform via GitHub Actions" 2>/dev/null \
  || echo "Utilisateur $USER_ID déjà présent."

# Rôles intégrés (compatibles Proxmox VE 8 et 9) :
#   PVEVMAdmin       : gestion complète des VM (clone, config, power…)
#   PVEDatastoreUser : allocation d'espace disque (disques, cloud-init)
#   PVESDNUser       : utilisation des bridges réseau
#   PVEAuditor       : lecture des nœuds / ressources
pveum acl modify / --users "$USER_ID" --roles PVEVMAdmin,PVEDatastoreUser,PVESDNUser,PVEAuditor

# --privsep 0 : le token hérite des droits de l'utilisateur.
pveum user token add "$USER_ID" "$TOKEN_ID" --privsep 0
