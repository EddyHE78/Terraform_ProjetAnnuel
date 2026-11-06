# L'URL et le token sont lus depuis les variables d'environnement, alimentées
# par les secrets GitHub :
#   PROXMOX_VE_ENDPOINT   ex: https://10.8.0.1:8006/  (IP joignable via le VPN)
#   PROXMOX_VE_API_TOKEN  ex: terraform@pve!github=xxxxxxxx-xxxx-...
#   PROXMOX_VE_INSECURE   true si certificat auto-signé (cas par défaut de Proxmox)
provider "proxmox" {}
