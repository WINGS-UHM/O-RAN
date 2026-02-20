#!/usr/bin/env bash
set -euo pipefail

# =========================
# Single-node Kubespray + Calico + MetalLB (VM isolated test)
# VirtualBox NAT typical:
#   iface: enp0s3
#   node ip: 10.0.2.15
# MetalLB pool here is only for shows-up-inside-VM testing.
# =========================
# =========================
# Helpers
# =========================
log() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1"; exit 1; }
}

# --- EDIT THESE IF NEEDED ---
NODE_NAME="${NODE_NAME:-node1}"
NODE_IP="${NODE_IP:-192.168.50.103}"
ANSIBLE_USER="${ANSIBLE_USER:-admin}"
CALICO_IFACE="${CALICO_IFACE:-eno1}"
METALLB_POOL="${METALLB_POOL:-192.168.50.245-192.168.50.246}"

# if ! command -v docker >/dev/null 2>&1; then
#   echo "Docker not found — installing..."
#   sudo apt update
#   sudo apt install -y docker.io
#   sudo systemctl enable --now docker
# else
#   echo "Docker already installed — skipping."
# fi
# Which user to add to docker group (optional)
DOCKER_USER="${DOCKER_USER:-$USER}"
ADD_DOCKER_GROUP="${ADD_DOCKER_GROUP:-1}"   # set to 1 if you want this
if [[ "$ADD_DOCKER_GROUP" == "1" ]]; then
  log "Adding $DOCKER_USER to docker group"
  sudo usermod -aG docker "$DOCKER_USER" || true
  log "Note: re-login required for docker group membership to take effect"
fi

# Kubespray location and version
KUBESPRAY_DIR="${KUBESPRAY_DIR:-$HOME/kubespray}"
KUBESPRAY_BRANCH="${KUBESPRAY_BRANCH:-release-2.26}"
CONTAINERMANAGER="docker"

# Where to store generated inventory
INVDIR="${INVDIR:-$HOME/inventories/kubernetes-single}"


# =========================
# Preflight
# =========================
log "Preflight checks"
need_cmd python3
need_cmd git
need_cmd sudo

if ! ip -4 addr show | grep -q "inet ${NODE_IP}/"; then
  echo "ERROR: NODE_IP ${NODE_IP} not found on this machine."
  echo "Run: ip -4 a"
  exit 1
fi

if ! ip link show "${CALICO_IFACE}" >/dev/null 2>&1; then
  echo "ERROR: CALICO_IFACE ${CALICO_IFACE} does not exist."
  echo "Run: ip link"
  exit 1
fi

# =========================
# SSH Client/Server Setup (internal key: ric-ssh)
# =========================
log "Installing OpenSSH client/server"
sudo apt update
sudo apt install -y openssh-client openssh-server

log "Enabling and starting ssh service"
sudo systemctl enable ssh
sudo systemctl restart ssh

SSH_KEY="$HOME/.ssh/ric-ssh"

log "Generating internal SSH key (ric-ssh) if not present"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "${SSH_KEY}" ]; then
  ssh-keygen -t ed25519 -f "${SSH_KEY}" -C "ric-ansible-key" -N ""
fi

log "Installing public key for ${ANSIBLE_USER}"
PUB_KEY_CONTENT="$(cat ${SSH_KEY}.pub)"

sudo -u "${ANSIBLE_USER}" mkdir -p "/home/${ANSIBLE_USER}/.ssh"
sudo -u "${ANSIBLE_USER}" touch "/home/${ANSIBLE_USER}/.ssh/authorized_keys"

if ! sudo grep -q "${PUB_KEY_CONTENT}" "/home/${ANSIBLE_USER}/.ssh/authorized_keys"; then
  echo "${PUB_KEY_CONTENT}" | sudo tee -a "/home/${ANSIBLE_USER}/.ssh/authorized_keys" >/dev/null
fi

sudo chown -R "${ANSIBLE_USER}:${ANSIBLE_USER}" "/home/${ANSIBLE_USER}/.ssh"
sudo chmod 700 "/home/${ANSIBLE_USER}/.ssh"
sudo chmod 600 "/home/${ANSIBLE_USER}/.ssh/authorized_keys"

log "SSH preflight complete. Testing local SSH login..."
ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" "${ANSIBLE_USER}@${NODE_IP}" "echo SSH OK"


# Disable swap now (Kubespray also does it, but do it upfront to avoid kubelet surprises)
log "Disabling swap (runtime)"
sudo swapoff -a || true

# Ensure /etc/hosts has node name resolvable (useful in minimal VMs)
if ! grep -qE "^\s*${NODE_IP}\s+${NODE_NAME}(\s|$)" /etc/hosts; then
  log "Adding ${NODE_NAME} to /etc/hosts for local resolution"
  echo "${NODE_IP} ${NODE_NAME}" | sudo tee -a /etc/hosts >/dev/null
fi

# =========================
# Python venv + dependencies
# =========================
log "Setting up Python venv + Ansible dependencies"
sudo apt update
sudo apt install -y python3-venv python3-pip sshpass rsync jq

python3 -m venv "$HOME/venv-kubespray"
# shellcheck disable=SC1090
source "$HOME/venv-kubespray/bin/activate"
pip install -U pip
# Kubespray requirements will pin correct ansible versions
pip install ruamel.yaml jinja2 netaddr

# =========================
# Clone Kubespray
# =========================
if [ ! -d "$KUBESPRAY_DIR/.git" ]; then
  log "Cloning Kubespray into $KUBESPRAY_DIR"
  git clone https://github.com/kubernetes-sigs/kubespray.git "$KUBESPRAY_DIR"
fi

log "Checking out Kubespray branch ${KUBESPRAY_BRANCH}"
cd "$KUBESPRAY_DIR"
git fetch --all --tags
git checkout "${KUBESPRAY_BRANCH}"

log "Installing Kubespray Python requirements"
pip install -r requirements.txt

# =========================
# Build inventory.ini (single node)
# =========================
log "Creating inventory at $INVDIR"
mkdir -p "$INVDIR"
cp -a "$KUBESPRAY_DIR/inventory/sample/group_vars" "$INVDIR/"
mkdir -p "$INVDIR/host_vars"

INV="$INVDIR/inventory.ini"
cat > "$INV" <<EOF
[all]
${NODE_NAME} ansible_host=${NODE_IP} ip=${NODE_IP} access_ip=${NODE_IP}

[kube_control_plane]
${NODE_NAME}

[etcd]
${NODE_NAME}

[kube_node]
${NODE_NAME}

[k8s-cluster:children]
kube_control_plane
kube_node
EOF

touch "$INVDIR/host_vars/${NODE_NAME}.yml"

# =========================
# Overrides (minimal, stable)
# =========================
log "Writing overrides.yml"
OVERRIDES="$INVDIR/overrides.yml"
cat > "$OVERRIDES" <<EOF
override_system_hostname: false
docker_dns_servers_strict: false
kubectl_localhost: true
kubeconfig_localhost: true
container_manager: ${CONTAINERMANAGER}
docker_storage_options: -s overlay2
disable_swap: true
ansible_user: ${ANSIBLE_USER}
ansible_ssh_private_key_file: ~/.ssh/ric-ssh

# Single-node: allow scheduling on control plane
remove_node_taints: true

# CNI
kube_network_plugin: calico
calico_ip_auto_method: "interface=${CALICO_IFACE}"

# MetalLB layer2 requires this
kube_proxy_strict_arp: true

# Useful addons
helm_enabled: true
metrics_server_enabled: true

# MetalLB (isolated VM test: reachable mainly from inside VM)
metallb_enabled: true
metallb_protocol: layer2
metallb_config:
  address_pools:
    primary:
      ip_range:
        - "${METALLB_POOL}"
      auto_assign: true
EOF

# =========================
# Run Kubespray
# =========================
log "Running Kubespray (this can take a while)"
ansible-playbook -i "$INV" cluster.yml -e @"$OVERRIDES" -b -v -K

# =========================
# Configure kubectl for current user
# =========================
log "Configuring kubectl for current user"
mkdir -p "$HOME/.kube"
if [ -f "$INVDIR/artifacts/admin.conf" ]; then
  sudo cp -f "/etc/kubernetes//admin.conf" "$HOME/.kube/config"
  sudo chmod 600 "$HOME/.kube/config"
  sudo chown $USER -R "$HOME/.kube/config"
else
  echo "WARNING: admin.conf not found at $INVDIR/artifacts/admin.conf"
fi

# =========================
# Post checks
# =========================
log "Post checks"
sudo chown root:$USER /etc/kubernetes/admin.conf
sudo chmod 640 /etc/kubernetes/admin.conf
need_cmd kubectl

kubectl get nodes -o wide
kubectl get pods -A | head -n 80

log "MetalLB status"
kubectl get pods -n metallb-system || true

log "Creating a simple LoadBalancer test service"
kubectl create deploy echo --image=hashicorp/http-echo -- /http-echo -text="ok" || true
kubectl expose deploy echo --port 5678 --type LoadBalancer || true

log "Waiting for EXTERNAL-IP assignment"
kubectl get svc echo -w &

# Wait up to ~60s for an external IP
for i in {1..60}; do
  EXT_IP="$(kubectl get svc echo -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  if [ -n "${EXT_IP}" ]; then
    log "Assigned EXTERNAL-IP: ${EXT_IP}"
    log "Testing from inside VM: curl http://${EXT_IP}:5678"
    curl -sS "http://${EXT_IP}:5678" || true
    exit 0
  fi
  sleep 1
done

echo "WARNING: EXTERNAL-IP was not assigned within 60 seconds."
echo "Check:"
echo "  kubectl describe svc echo"
echo "  kubectl logs -n metallb-system deploy/controller"
echo "  kubectl logs -n metallb-system daemonset/speaker"
exit 0
