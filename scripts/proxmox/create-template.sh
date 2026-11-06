#!/usr/bin/env bash
# Crée un template cloud-init Ubuntu 24.04 sur le nœud Proxmox.
# À lancer en root SUR le host Proxmox :  bash create-template.sh
# Variables surchargeables : TEMPLATE_ID, STORAGE, BRIDGE
set -euo pipefail

TEMPLATE_ID="${TEMPLATE_ID:-9000}"
STORAGE="${STORAGE:-local}"
BRIDGE="${BRIDGE:-vmbr1}"
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE="/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img"

if qm status "$TEMPLATE_ID" >/dev/null 2>&1; then
  echo "La VM $TEMPLATE_ID existe déjà, abandon." >&2
  exit 1
fi

# Le stockage doit accepter les disques de VM (contenu "images").
if ! pvesm status --content images | awk 'NR>1 {print $1}' | grep -qx "$STORAGE"; then
  echo "Le stockage '$STORAGE' n'accepte pas les disques de VM (contenu 'images')." >&2
  echo "Ajoute-le dans Datacenter > Storage > $STORAGE > Content, ou en CLI :" >&2
  echo "  pvesm set $STORAGE --content <contenu actuel>,images" >&2
  echo "(contenu actuel : grep -A4 \": $STORAGE\$\" /etc/pve/storage.cfg)" >&2
  exit 1
fi

# Stockage de type fichier (dir, nfs, cifs…) : disques en qcow2.
STORAGE_TYPE="$(pvesm status --storage "$STORAGE" | awk 'NR==2 {print $2}')"
case "$STORAGE_TYPE" in
  dir | nfs | cifs | glusterfs | cephfs | btrfs) DISK_OPTS=",format=qcow2" ;;
  *) DISK_OPTS="" ;;
esac

apt-get update -qq
apt-get install -y -qq libguestfs-tools wget

mkdir -p "$(dirname "$IMAGE")"
wget -q --show-progress -O "$IMAGE" "$IMAGE_URL"

# Installe le QEMU guest agent dans l'image (Terraform s'en sert pour lire l'IP).
virt-customize -a "$IMAGE" --install qemu-guest-agent --truncate /etc/machine-id

qm create "$TEMPLATE_ID" \
  --name ubuntu-2404-cloudinit \
  --memory 1024 --cores 1 --cpu x86-64-v2-AES \
  --net0 "virtio,bridge=${BRIDGE}" \
  --scsihw virtio-scsi-single \
  --ostype l26

qm set "$TEMPLATE_ID" --scsi0 "${STORAGE}:0,import-from=${IMAGE},discard=on${DISK_OPTS}"
qm set "$TEMPLATE_ID" --ide2 "${STORAGE}:cloudinit"
qm set "$TEMPLATE_ID" --boot order=scsi0
qm set "$TEMPLATE_ID" --serial0 socket --vga serial0
qm set "$TEMPLATE_ID" --agent enabled=1

qm template "$TEMPLATE_ID"
echo "Template $TEMPLATE_ID prêt."
