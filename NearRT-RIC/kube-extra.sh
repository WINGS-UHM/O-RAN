#!/usr/bin/env bash
set -euo pipefail

# ========= USER SETTINGS =========
# Where to write outputs (token, kubeconfig, marker file)
OUTDIR="${OUTDIR:-$HOME/k8s-extra}"
sudo apt install docker.io -y
# Which user to add to docker group (optional)
DOCKER_USER="${DOCKER_USER:-$USER}"
ADD_DOCKER_GROUP="${ADD_DOCKER_GROUP:-1}"   # set to 1 if you want this

# Run a local docker registry (optional)
DO_LOCAL_REGISTRY="${DO_LOCAL_REGISTRY:-1}" # set to 1 to enable
REGISTRY_BIND_IP="${REGISTRY_BIND_IP:-127.0.0.1}"  # use your LAN IP on real host if desired
REGISTRY_PORT="${REGISTRY_PORT:-5000}"

# NFS provisioner (optional)
DO_NFS_PROVISIONER="${DO_NFS_PROVISIONER:-1}"      # set to 1 to enable
NFS_SERVER_IP="${NFS_SERVER_IP:-10.0.2.15}"                 # required if DO_NFS_PROVISIONER=1
NFS_EXPORT_PATH="${NFS_EXPORT_PATH:-/export/k8s}"   # your export
NFS_MOUNT_OPTIONS="${NFS_MOUNT_OPTIONS:-nfsvers=3}"

# ========= INTERNALS =========
DONE_MARKER="$OUTDIR/kubernetes-extra-done"
mkdir -p "$OUTDIR"

log() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing command: $1"; exit 1; }
}

if [[ -f "$DONE_MARKER" ]]; then
  log "Already done: $DONE_MARKER exists"
  exit 0
fi

log "Preflight"
need_cmd kubectl
need_cmd sudo
need_cmd systemctl

# Ensure kubeconfig exists for current user
if [[ ! -f "$HOME/.kube/config" ]]; then
  echo "ERROR: $HOME/.kube/config not found. Run your Kubespray install first and set kubectl config."
  exit 1
fi

# ========= 1) systemd kubectl proxy on localhost =========
log "Installing systemd service for kubectl proxy (localhost:8888)"

sudo tee /etc/systemd/system/kube-local-proxy.service >/dev/null <<'EOF'
[Unit]
Description=Kubernetes Local Proxy Service (kubectl proxy)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=always
User=root
Environment=KUBECONFIG=/root/.kube/config
ExecStart=/usr/bin/kubectl proxy \
  --accept-hosts='.*' \
  --accept-paths='^/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/.*' \
  --address=127.0.0.1 \
  --port=8888
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
EOF

# Ensure root has kubeconfig too (so systemd service can read it)
sudo mkdir -p /root/.kube
sudo cp -f "$HOME/.kube/config" /root/.kube/config
sudo chmod 600 /root/.kube/config
sudo chown root -R /root/.kube/config

sudo systemctl daemon-reload
sudo systemctl enable --now kube-local-proxy.service

# ========= 2) Admin token creation =========
log "Creating admin ServiceAccount + ClusterRoleBinding and exporting token"

kubectl create serviceaccount admin -n default >/dev/null 2>&1 || true
kubectl create clusterrolebinding cluster-default-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:admin >/dev/null 2>&1 || true

# Handle newer k8s where secrets are not auto-created
hassecret="$(kubectl get serviceaccount admin -n default -o 'jsonpath={.secrets}' 2>/dev/null || true)"

secretid=""
if [[ -n "$hassecret" ]]; then
  secretid="$(kubectl get serviceaccount admin -n default -o 'go-template={{(index .secrets 0).name}}')"
else
  kubectl -n default apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: admin-secret
  annotations:
    kubernetes.io/service-account.name: admin
type: kubernetes.io/service-account-token
EOF
  secretid="admin-secret"
fi

token=""
for _ in {1..10}; do
  token="$(kubectl get secrets "$secretid" -o 'go-template={{.data.token}}' 2>/dev/null | base64 -d || true)"
  [[ -n "$token" ]] && break
  sleep 3
done

if [[ -z "$token" ]]; then
  echo "ERROR: failed to get admin token from secret: $secretid"
  exit 1
fi

printf "%s" "$token" > "$OUTDIR/admin-token.txt"
chmod 644 "$OUTDIR/admin-token.txt"

# ========= 3) Export kubeconfig =========
log "Exporting kubeconfig to $OUTDIR/kubeconfig"
sudo cp -f "$HOME/.kube/config" "$OUTDIR/kubeconfig"
chmod 644 "$OUTDIR/kubeconfig"

# ========= 4) Optional: add user to docker group =========
if [[ "$ADD_DOCKER_GROUP" == "1" ]]; then
  log "Adding $DOCKER_USER to docker group"
  sudo usermod -aG docker "$DOCKER_USER" || true
  log "Note: re-login required for docker group membership to take effect"
fi

# ========= 5) Optional: local insecure registry =========
if [[ "$DO_LOCAL_REGISTRY" == "1" ]]; then
  need_cmd docker
  log "Starting local docker registry on ${REGISTRY_BIND_IP}:${REGISTRY_PORT}"
  if ! sudo docker ps -a --format '{{.Names}}' | grep -qx 'local-registry'; then
    sudo docker create --restart=always \
      -p "${REGISTRY_BIND_IP}:${REGISTRY_PORT}:5000" \
      --name local-registry registry:2
  fi
  sudo docker start local-registry
fi

# ========= 6) Optional: NFS subdir external provisioner =========
if [[ "$DO_NFS_PROVISIONER" == "1" ]]; then
  need_cmd helm
  
    if helm -n default status nfs-subdir-external-provisioner >/dev/null 2>&1; then
    if helm -n default status nfs-subdir-external-provisioner | grep -q "STATUS: failed"; then
      log "Previous nfs-subdir-external-provisioner release is failed; uninstalling for clean retry"
      helm -n default uninstall nfs-subdir-external-provisioner || true
    fi
  fi
  log "Ensuring NFS client tools are installed (nfs-common)"
  sudo apt-get update -y
  sudo apt-get install -y nfs-kernel-server nfs-common
   # Create export directory
  sudo mkdir -p "$NFS_EXPORT_PATH"
  sudo chown nobody:nogroup "$NFS_EXPORT_PATH"
  sudo chmod 777 "$NFS_EXPORT_PATH"

  # Add export rule if not already present
  if ! grep -q "$NFS_EXPORT_PATH" /etc/exports; then
    echo "$NFS_EXPORT_PATH *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
  fi

  sudo exportfs -ra
  sudo systemctl enable --now nfs-kernel-server
  if [[ -z "$NFS_SERVER_IP" ]]; then
    echo "ERROR: DO_NFS_PROVISIONER=1 but NFS_SERVER_IP is empty"
    exit 1
  fi

  log "Installing nfs-subdir-external-provisioner (default StorageClass)"
  helm repo add nfs-subdir-external-provisioner \
    https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/ >/dev/null 2>&1 || true
  helm repo update >/dev/null

  cat > "$OUTDIR/nfs-provisioner-values.yaml" <<EOF
nfs:
  server: "$NFS_SERVER_IP"
  path: "$NFS_EXPORT_PATH"
  mountOptions:
    - "$NFS_MOUNT_OPTIONS"
storageClass:
  defaultClass: true
EOF

  helm upgrade --install nfs-subdir-external-provisioner \
    nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    -f "$OUTDIR/nfs-provisioner-values.yaml" --wait --timeout 5m
fi

cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs
provisioner: cluster.local/nfs-subdir-external-provisioner
parameters:
  archiveOnDelete: "false"
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOF

###############################################################################
# Headlamp (Kubernetes UI) - minimal install
###############################################################################
log "Installing Headlamp (minimal)"

# Preconditions
# command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl not found"; exit 1; }
# command -v helm   >/dev/null 2>&1 || { echo "ERROR: helm not found"; exit 1; }

# Use current kubeconfig (the script already copies/exported one, but ensure kubectl works)
# kubectl version --short >/dev/null 2>&1 || {
  #echo "ERROR: kubectl cannot reach the cluster. Check kubeconfig."
  #exit 1
#}

# Add repo (idempotent)
if ! helm repo list | awk '{print $1}' | grep -qx headlamp; then
  helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
fi
helm repo update

# Namespace
kubectl get ns headlamp >/dev/null 2>&1 || kubectl create ns headlamp

# Install/upgrade Headlamp
helm upgrade --install headlamp headlamp/headlamp \
  --namespace headlamp

# Wait for ready
kubectl rollout status deploy/headlamp -n headlamp --timeout=180s || true

# Print access instructions
cat <<EOF

Headlamp installed.

Access (recommended):
  kubectl -n headlamp port-forward svc/headlamp 8080:80

Then open:
  http://127.0.0.1:8080

Login token:
  $( [ -f "$HOME/k8s-extra/admin-token.txt" ] && cat "$HOME/k8s-extra/admin-token.txt" || echo "Use an admin token (admin-token.txt not found)" )

EOF



# ========= 7) sysctl tuning =========
log "Applying inotify sysctl tuning"
sudo tee /etc/sysctl.d/99-kube.conf >/dev/null <<'EOF'
fs.inotify.max_user_instances=1024
fs.inotify.max_user_watches=1000448
EOF
sudo sysctl -p /etc/sysctl.d/99-kube.conf >/dev/null

touch "$DONE_MARKER"
log "Done. Outputs:"
log "  Token:     $OUTDIR/admin-token.txt"
log "  Kubeconfig: $OUTDIR/kubeconfig"

