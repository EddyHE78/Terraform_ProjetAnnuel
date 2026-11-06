# Terraform_ProjetAnnuel

Projet annuel : déploiement de VM à la demande sur **Proxmox** (bare metal Scaleway) et/ou **AWS**, avec Terraform exécuté par **GitHub Actions** (runners GitHub-hosted).

```
GitHub Actions (runner GitHub-hosted)
  ├── OIDC ─────────────► AWS : rôle IAM ─► state S3 + EC2
  └── VPN (WireGuard ou Tailscale) ─► API Proxmox (Scaleway) ─► VM clonées depuis un template cloud-init
```

## Arborescence

| Chemin | Rôle |
|---|---|
| `.github/workflows/deploy.yml` | Workflow manuel : cible, action (plan/apply/destroy), nombre et taille de VM |
| `.github/workflows/terraform-ci.yml` | `fmt` + `validate` sur chaque PR / push vers `dev` |
| `bootstrap/aws/` | À lancer **une fois** en local : bucket S3 de state, OIDC GitHub, rôle IAM |
| `terraform/proxmox/` | VM Proxmox (provider `bpg/proxmox`) |
| `terraform/aws/` | VPC + instances EC2 Ubuntu 24.04 |
| `scripts/proxmox/` | Création du template cloud-init et du token d'API Proxmox |

Gabarits (`vm_size`) :

| Taille | Proxmox | AWS |
|---|---|---|
| small | 1 vCPU / 1 Go / 10 Go | t3.micro |
| medium | 2 vCPU / 2 Go / 20 Go | t3.small |
| large | 4 vCPU / 4 Go / 40 Go | t3.medium |

## Mise en place (une seule fois)

### 1. AWS : bootstrap

En local, avec des identifiants AWS administrateur :

```bash
cd bootstrap/aws
terraform init
terraform apply -var="state_bucket_name=tfstate-projet-annuel-<suffixe-unique>"
```

Récupère les sorties `aws_role_arn`, `tf_state_bucket` et `aws_region` pour l'étape 4.
Si le fournisseur OIDC GitHub existe déjà dans ton compte, ajoute `-var="create_oidc_provider=false"`.

### 2. Proxmox : template et token

Sur le host Proxmox, en root :

```bash
# Template Ubuntu 24.04 cloud-init (VMID 9000) avec qemu-guest-agent
STORAGE=local-lvm BRIDGE=vmbr1 bash scripts/proxmox/create-template.sh

# Utilisateur terraform@pve + token "github" (le secret s'affiche une seule fois)
bash scripts/proxmox/create-api-token.sh
```

Ensuite, adapte `terraform/proxmox/terraform.tfvars` : nom du nœud, stockage, bridge, réseau et passerelle des VM.

### 3. Accès réseau à Proxmox depuis GitHub

Le runner GitHub est sur Internet. Il rejoint ton infra par VPN le temps du job : on n'expose **pas** le port 8006.

**Option A : WireGuard (défaut, tu l'utilises déjà)**

1. Génère une paire de clés dédiée à la CI : `wg genkey | tee ci.key | wg pubkey > ci.pub`.
2. Ajoute un peer sur ton serveur WireGuard :
   ```ini
   [Peer]
   # github-actions
   PublicKey = <contenu de ci.pub>
   AllowedIPs = 10.8.0.50/32
   ```
3. Crée le secret GitHub `WG_CONFIG` avec la config client :
   ```ini
   [Interface]
   PrivateKey = <contenu de ci.key>
   Address = 10.8.0.50/32

   [Peer]
   PublicKey = <clé publique du serveur>
   Endpoint = <IP publique Scaleway>:51820
   AllowedIPs = 10.8.0.0/24, 10.10.10.0/24
   PersistentKeepalive = 25
   ```
   ⚠️ Mets dans `AllowedIPs` **uniquement les réseaux privés**, jamais `0.0.0.0/0` : sinon tout le trafic du runner part dans le tunnel et le job casse. N'ajoute **pas** de ligne `DNS =`, car `resolvconf` n'est pas installé sur le runner.

**Option B : Tailscale**

Installe Tailscale sur le host Proxmox. Dans la console Tailscale, crée un tag `tag:ci` et un client OAuth (scope *auth_keys*). Renseigne ensuite les secrets `TS_OAUTH_CLIENT_ID` et `TS_OAUTH_SECRET`, et la variable `VPN_TYPE=tailscale`.

Dans les deux cas, `PROXMOX_ENDPOINT` doit pointer vers l'IP **privée** du host vue à travers le VPN (ex : `https://10.8.0.1:8006/`).

### 4. Secrets et variables GitHub

*Settings → Secrets and variables → Actions*

| Type | Nom | Valeur |
|---|---|---|
| Variable | `AWS_ROLE_ARN` | sortie `aws_role_arn` du bootstrap |
| Variable | `TF_STATE_BUCKET` | sortie `tf_state_bucket` |
| Variable | `AWS_REGION` | `eu-west-3` (optionnel) |
| Variable | `SSH_PUBLIC_KEY` | ta clé publique (`ssh-ed25519 AAAA…`) |
| Variable | `VPN_TYPE` | `wireguard` (défaut) ou `tailscale` |
| Variable | `PROXMOX_INSECURE` | `true` (défaut, certificat auto-signé) ou `false` |
| Secret | `PROXMOX_ENDPOINT` | `https://10.8.0.1:8006/` |
| Secret | `PROXMOX_API_TOKEN` | `terraform@pve!github=<secret>` |
| Secret | `WG_CONFIG` | config WireGuard client (option A) |
| Secret | `TS_OAUTH_CLIENT_ID` / `TS_OAUTH_SECRET` | option B |

### 5. Branches

| Branche | Rôle |
|---|---|
| `main` | Branche principale (par défaut), stable. Mise à jour uniquement par merge `dev → main`, à la main. |
| `dev` | Branche de travail : tous les changements arrivent ici. |

- Branche par défaut : *Settings → General → Default branch → `main`*.
- Conseillé : protéger `main` (*Settings → Branches*) en exigeant une PR et le check `Terraform CI` vert.
- Le bouton *Run workflow* n'apparaît qu'une fois `deploy.yml` présent sur `main`. Ensuite, le sélecteur de branche du formulaire permet de lancer la version de `dev` pour tester.

## Utilisation

*Actions → Déployer des VM → Run workflow*, puis choisis :

- **target** : `proxmox`, `aws` ou `both`
- **action** : `plan` (aperçu seul), `apply` ou `destroy`
- **vm_count**, **vm_size**, **name_prefix**

Le résumé du run affiche le plan et le tableau des VM (nom, ID, IP). Les sorties JSON sont publiées en artefact `outputs-<stack>`.
Relancer avec un `vm_count` plus petit supprime les VM en trop. `destroy` supprime tout ce que gère la stack.

## Pistes pour la suite

- **Dashboard** : une page qui déclenche `deploy.yml` via l'API GitHub (`POST /repos/{owner}/{repo}/actions/workflows/deploy.yml/dispatches`) et lit les artefacts `outputs-*`.
- **Validation manuelle** : un *environment* GitHub avec reviewers obligatoires avant `apply`/`destroy`.
- **Post-install** : Ansible lancé après l'apply pour configurer les VM.
- Commiter les fichiers `.terraform.lock.hcl` pour figer les versions des providers.
