# Kubernetes CN Load Notes

This folder is a staging copy of the Docker CN and metrics components needed to
move only these services into Kubernetes:

- `5gc`
- `grafana`
- `telegraf`
- `influxdb`

It intentionally excludes Dockerized `gnb`, CU/DU split services, and any split
RAN deployment artifacts.

## Namespace

Use a lowercase namespace name. Kubernetes namespace names must be DNS labels, so
`5G-Core` is not valid. Use this working name:

```bash
kubectl create namespace 5g-core
```

## Images

The namespace needs these images:

| Component | Image name to use | Source |
| --- | --- | --- |
| Open5GS 5GC | `registry.local:5000/ocudu/open5gs-5gc:v2.7.6-kube` | `open5gs/Dockerfile`, target `open5gs` |
| Telegraf | `registry.local:5000/ocudu/telegraf:1.35.0-kube` | `telegraf/Dockerfile` |
| Grafana | `registry.local:5000/ocudu/grafana:12.0.2-kube` | `grafana/Dockerfile` |
| InfluxDB | `influxdb:3.1.0-core` | Upstream image, no local build |

Adjust the registry/tag names if the cluster uses a different image registry.

## Build And Push

Run these commands from this `kube-cn` directory:

```bash
docker build \
  -t registry.local:5000/ocudu/open5gs-5gc:v2.7.6-kube \
  --target open5gs \
  --build-arg OS_VERSION=22.04 \
  --build-arg OPEN5GS_VERSION=v2.7.6 \
  ./open5gs

docker build \
  -t registry.local:5000/ocudu/telegraf:1.35.0-kube \
  ./telegraf

docker build \
  -t registry.local:5000/ocudu/grafana:12.0.2-kube \
  --build-arg GF_VERSION=12.0.2 \
  --build-arg LOGO_URL=https://raw.githubusercontent.com/ocudu/OCUDU_Project_docs/main/docs/source/.imgs/logo.png \
  ./grafana

docker push registry.local:5000/ocudu/open5gs-5gc:v2.7.6-kube
docker push registry.local:5000/ocudu/telegraf:1.35.0-kube
docker push registry.local:5000/ocudu/grafana:12.0.2-kube
```

If using a single-node local cluster that can see the host Docker image store,
loading may be enough instead of pushing. Use the command supported by the local
cluster runtime, for example `kind load docker-image ...` or the cluster's
containerd import flow.


## End-To-End Helm Install

This folder now includes a Helm chart and installer wrapper similar in spirit to
the RIC deployment flow:

```text
chart/
RECIPE_EXAMPLE/example_recipe_5g_core.yaml
install
```

After the images are built and pushed to the local registry, install or upgrade
the full `5g-core` stack with:

```bash
./install -f RECIPE_EXAMPLE/example_recipe_5g_core.yaml
```

The install wrapper will:

- read the namespace and image/IP settings from the recipe file
- create the namespace if needed
- run `helm upgrade --install`
- wait for selected component pods to reach `Running`
- print pods and services in the namespace

To install only selected components, use `-c`:

```bash
./install -f RECIPE_EXAMPLE/example_recipe_5g_core.yaml -c "open5gs influxdb telegraf grafana"
```

The component list defaults to all components. Valid component names are:

```text
open5gs influxdb telegraf grafana
```

To inspect what would be applied without installing:

```bash
helm template 5g-core ./chart -n 5g-core -f RECIPE_EXAMPLE/example_recipe_5g_core.yaml
```

To lint the chart:

```bash
helm lint ./chart -f RECIPE_EXAMPLE/example_recipe_5g_core.yaml
```

## MetalLB IP Plan

MetalLB is cluster-wide. You do not need a separate MetalLB installation in the
`5g-core` namespace.

Reserve at least one stable LoadBalancer IP for Open5GS. The chosen IP must be free, inside the lab subnet, and included in a MetalLB `IPAddressPool`. The staging env currently uses `192.168.50.245` as the CN IP, but change it before deployment if that address is not free in your lab.

Check the currently configured MetalLB pools:

```bash
kubectl get ipaddresspools -A -o wide
```

Check which LoadBalancer IPs are already allocated:

```bash
kubectl get svc -A -o wide | awk 'NR==1 || $3=="LoadBalancer"'
```

Pick an IP that appears in a MetalLB pool but is not already listed as an `EXTERNAL-IP` for another LoadBalancer service.

One IP is enough for the core service because the same LoadBalancer service can
expose:

```text
38412/SCTP   N2 / NGAP
2152/UDP     N3 / GTP-U
9999/TCP     Open5GS subscriber WebUI
```

Grafana can be `ClusterIP` and accessed with port-forwarding:

```bash
kubectl port-forward -n 5g-core svc/grafana 3400:3000 --address 0.0.0.0
```

If Grafana needs permanent lab-network access without port-forwarding, reserve a second free MetalLB IP. Do not reuse any IP already assigned to another LoadBalancer service, such as an existing ORAN/Kong proxy IP.

## Kubernetes Runtime Shape

Recommended services:

| Component | Kubernetes type | External exposure |
| --- | --- | --- |
| `open5gs-5gc` | `LoadBalancer` | Required for N2/N3 and optionally WebUI |
| `grafana` | `ClusterIP` or `LoadBalancer` | Port-forward is acceptable |
| `influxdb` | `ClusterIP` | Internal only |
| `telegraf` | No external service required | Internal metrics writer |

The Helm chart creates these workload objects:

```text
Deployment/open5gs-5gc
Deployment/influxdb
Deployment/telegraf
Deployment/grafana
PersistentVolumeClaim/influxdb-storage
PersistentVolumeClaim/grafana-storage
ConfigMap/open5gs-env
ConfigMap/metrics-env
Service/open5gs-5gc
Service/influxdb
Service/grafana
```

## Important Open5GS IP Handling

Do not bake lab IP addresses into images. Keep images generic and pass IPs as
Kubernetes env vars or ConfigMaps.

The current Docker config uses:

```env
OPEN5GS_IP=192.168.50.103
UPF_ADVERTISE_IP=192.168.50.103
```

For Kubernetes with a MetalLB service, the pod does not own the MetalLB external
IP. The chart therefore sets:

```env
OPEN5GS_IP=<pod IP from Kubernetes Downward API>
UPF_ADVERTISE_IP=<OPEN5GS_METALLB_IP>
```

`OPEN5GS_IP` is used as the bind address in `open5gs-5gc.yml`. In Kubernetes it
must not be `0.0.0.0`, because UPF would bind all UDP/2152 addresses and collide
with the internal SMF loopback listener on `127.0.0.4:2152`. The pod IP keeps the
bind local to the pod network while the Service forwards external N2/N3 traffic
from the MetalLB IP.

If the Open5GS config is later split into clearer bind and advertise variables,
the conceptual shape should be:

```yaml
amf:
  ngap:
    server:
      - address: ${OPEN5GS_BIND_IP}

upf:
  gtpu:
    server:
      - address: ${OPEN5GS_BIND_IP}
        advertise: ${OPEN5GS_ADVERTISE_IP}
```

The external gNB should then use:

```text
AMF address: <OPEN5GS_METALLB_IP>
N2 port:     38412/SCTP
N3 address:  <OPEN5GS_METALLB_IP>
N3 port:     2152/UDP
```

## Telegraf Metrics Source

The Kubernetes staging `metrics.env` uses:

```env
WS_URL=192.168.50.38:8001
```

This assumes the native gNB host is `192.168.50.38` and the gNB metrics server
is listening on `0.0.0.0:8001`. Clients connect to the real host IP, not to
`0.0.0.0`.

For other deployments, set `WS_URL` based on where the native gNB metrics
websocket runs:

```text
Same node host gNB: <node-ip>:8001
Remote gNB:         <gnb-ip>:8001
Kubernetes gNB:     <service-name>.<namespace>:8001
```

For the current native/remote gNB model, use the gNB host IP directly.

The InfluxDB URL is namespace-resolvable through Kubernetes DNS:

```env
INFLUXDB3_EXTERNAL_URL=http://influxdb.5g-core.svc.cluster.local:8081
```

If all metrics pods stay in the same namespace, `http://influxdb:8081` would
also resolve. The fully qualified service name is used here to make the namespace
dependency explicit.

## Running Kubernetes CN And Docker CN Together

Running both at the same time is possible only if their externally visible IPs
or ports do not overlap.

The Kubernetes CN should use its MetalLB IP, for example:

```text
192.168.50.245:38412/SCTP
192.168.50.245:2152/UDP
192.168.50.245:9999/TCP
```

The Docker host-network CN currently uses the Docker host lab IP:

```text
192.168.50.103:38412/SCTP
192.168.50.103:2152/UDP
192.168.50.103:9999/TCP
```

Those two can coexist because the IPs differ. They would conflict if both try to
bind or advertise the same lab IP and port tuple.

For same-host testing, point each gNB instance at exactly one CN endpoint:

```text
Docker CN AMF:     192.168.50.103
Kubernetes CN AMF: 192.168.50.245
```


## Hardcoded IPs And URLs

These are the concrete addresses currently present in the Kubernetes staging files.

| Value | Where | Meaning | Change when |
| --- | --- | --- | --- |
| `192.168.50.38:8001` | `metrics.env` `WS_URL` | Native gNB metrics WebSocket endpoint. Telegraf connects here and subscribes to JSON metrics. | The metrics-producing gNB moves to another host or port. |
| `192.168.50.245` | `RECIPE_EXAMPLE/example_recipe_5g_core.yaml` `open5gs.loadBalancerIP` and `open5gs.upfAdvertiseIP` | Staging placeholder for the Kubernetes Open5GS MetalLB IP. gNBs should use whichever CN IP is chosen here for N2/N3. | The address is not free, not in the lab subnet, or not in the MetalLB pool. |
| Pod IP | `chart/templates/open5gs.yaml` `OPEN5GS_IP` from `status.podIP` | Runtime Open5GS bind address inside Kubernetes. The chart injects this automatically. | Normally do not hardcode it. |
| `0.0.0.0` | `metrics.env` `INFLUXDB3_HTTP_BIND_ADDR`, Grafana port-forward service | Bind/listen address inside a pod/container or on the node for port-forwarding. It is not a remote destination. | Only if a component requires binding to a specific pod/node IP. |
| `127.0.0.1` | `open5gs.env` `MONGODB_IP`, `metrics.env` `INFLUXDB3_HOST_URL` | Localhost inside the same container/pod. MongoDB is inside the Open5GS container; the InfluxDB healthcheck uses its own local HTTP endpoint. | MongoDB is split into a separate pod, or the InfluxDB healthcheck is moved outside the InfluxDB pod. |
| `http://influxdb.5g-core.svc.cluster.local:8081` | `metrics.env` `INFLUXDB3_EXTERNAL_URL` | Kubernetes DNS name for the InfluxDB service in namespace `5g-core`. Used by Telegraf and Grafana. | Namespace or InfluxDB service name changes. |
| `https://raw.githubusercontent.com/ocudu/OCUDU_Project_docs/main/docs/source/.imgs/logo.png` | `metrics.env` `GF_LOGO_URL`, build docs | Grafana logo downloaded at image build time. | Offline builds or a different logo source is required. |
| `8.8.8.8`, `8.8.4.4` | `open5gs/open5gs-5gc.yml` | DNS servers handed to UE sessions by Open5GS SMF. | UE traffic should use lab/internal DNS instead. |
| `10.45.0.0/24`, `10.45.0.0/16`, `10.45.1.2`, `10.45.1.3` | Open5GS env/scripts/subscriber DB | UE tunnel/subscriber address space. Not Kubernetes service addressing. | UE pool or static subscriber IPs change. |
| `127.0.0.2`-`127.0.0.22` | `open5gs/open5gs-5gc.yml` | Internal Open5GS NF loopback addresses inside the all-in-one container. | Only if refactoring Open5GS NFs into separate pods. |

Reference-only values that remain in copied docs/comments or Compose reference files:

| Value | Meaning |
| --- | --- |
| `192.168.50.103` | Docker host-network CN endpoint used by the current Docker Compose setup, not the Kubernetes CN. |
| Existing ORAN/Kong LoadBalancer IPs | Any already allocated LoadBalancer IP must stay reserved for its current service. Do not reuse it for `5g-core`. |
| `10.53.1.2`, `10.53.1.3` | Old Docker bridge CN/gNB addresses from Compose references. Do not use for Kubernetes. |
| `172.19.1.x` | Docker Compose metrics bridge addresses. Do not use for Kubernetes. |
| `host.docker.internal`, `gnb:8001` | Docker-specific examples in comments/reference files. Do not use for Kubernetes. |

## Coexistence With Docker Compose CN

Loading the Kubernetes CN images into the cluster does not conflict with a Docker
Compose CN by itself. Images are just stored artifacts.

Running both CN instances at the same time is also possible if their external
endpoints are different:

```text
Docker CN:      192.168.50.103:38412/SCTP, 2152/UDP, 9999/TCP
Kubernetes CN:  192.168.50.245:38412/SCTP, 2152/UDP, 9999/TCP
```

They will conflict if either of these is true:

- both are configured to use the same lab IP and same ports
- the Kubernetes CN is run with `hostNetwork: true` on the Docker host and binds the same host IP/ports
- both advertise the same CN IP to the same gNB at the same time

The staging plan avoids that by keeping Docker on the Docker host IP and Kubernetes on a separate MetalLB IP.

## First Deployment Validation

After manifests are applied:

```bash
kubectl get pods -n 5g-core -o wide
kubectl get svc -n 5g-core -o wide
kubectl logs -n 5g-core deploy/open5gs-5gc --tail=120
```

Verify Open5GS external service ports:

```bash
kubectl get svc -n 5g-core open5gs-5gc -o wide
```

Expected service ports:

```text
9999/TCP
38412/SCTP
2152/UDP
```

From a lab host, test visibility:

```bash
nc -vz <OPEN5GS_METALLB_IP> 9999
```

For N2/N3 packet inspection, capture on the gNB host or Kubernetes node:

```bash
sudo tcpdump -ni any 'sctp port 38412 or udp port 2152'
```

## Current Files Copied Into This Folder

```text
open5gs/
grafana/
telegraf/
open5gs.env
metrics.env
docker-compose.reference.yml
docker-compose.ui.reference.yml
```

The Compose files are references only. Do not apply them to Kubernetes directly.

## Runtime Operations

### Update gNB Metrics Source

Yes, `WS_URL` can be changed at runtime if the metrics-producing gNB moves to a different host. The image does not need to be rebuilt. Because this stack is Helm-managed, prefer updating the Helm release value and restarting Telegraf from the new ConfigMap value:

```bash
helm upgrade --install 5g-core ./chart \
  -n 5g-core \
  -f RECIPE_EXAMPLE/example_recipe_5g_core.yaml \
  --reuse-values \
  --set metrics.wsUrl=192.168.50.39:8001

kubectl rollout restart -n 5g-core deployment/telegraf
kubectl rollout status -n 5g-core deployment/telegraf
```

For a permanent change, also edit `RECIPE_EXAMPLE/example_recipe_5g_core.yaml` and update:

```yaml
metrics:
  wsUrl: 192.168.50.39:8001
```

After restart, verify Telegraf is running and check logs:

```bash
kubectl get pods -n 5g-core -l app.kubernetes.io/component=telegraf -o wide
kubectl logs -n 5g-core deployment/telegraf --tail=120
```

Connectivity test from the Telegraf pod:

```bash
kubectl exec -n 5g-core deployment/telegraf -- sh -c 'python3 - <<PY
import socket
s = socket.create_connection(("192.168.50.39", 8001), 5)
print("connected")
s.close()
PY'
```

Replace `192.168.50.39` with the new gNB host IP.

### Restart CN Namespace Workloads

Restart all expected CN namespace deployments:

```bash
kubectl rollout restart -n 5g-core deployment/open5gs-5gc
kubectl rollout restart -n 5g-core deployment/influxdb
kubectl rollout restart -n 5g-core deployment/telegraf
kubectl rollout restart -n 5g-core deployment/grafana
```

Wait for them to come back:

```bash
kubectl rollout status -n 5g-core deployment/open5gs-5gc
kubectl rollout status -n 5g-core deployment/influxdb
kubectl rollout status -n 5g-core deployment/telegraf
kubectl rollout status -n 5g-core deployment/grafana
```

Or restart every deployment in the namespace at once:

```bash
kubectl rollout restart -n 5g-core deployment
kubectl get pods -n 5g-core -o wide
```

Check services and logs:

```bash
kubectl get svc -n 5g-core -o wide
kubectl logs -n 5g-core deployment/open5gs-5gc --tail=120
kubectl logs -n 5g-core deployment/telegraf --tail=120
kubectl logs -n 5g-core deployment/grafana --tail=120
```

### Delete CN Workloads But Keep Namespace

For Helm-managed installs, delete the release with:

```bash
helm uninstall 5g-core -n 5g-core
```

If deleting manually by resource type:

```bash
kubectl delete deployment -n 5g-core open5gs-5gc influxdb telegraf grafana --ignore-not-found
kubectl delete service -n 5g-core open5gs-5gc influxdb grafana --ignore-not-found
kubectl delete configmap -n 5g-core open5gs-env metrics-env --ignore-not-found
kubectl delete pvc -n 5g-core influxdb-storage grafana-storage --ignore-not-found
```

Be careful with PVC deletion: deleting PVCs removes persisted Grafana/InfluxDB data depending on the storage class reclaim policy.

### Delete Everything Including Namespace

This removes all resources in the CN namespace:

```bash
kubectl delete namespace 5g-core
```

Verify removal:

```bash
kubectl get namespace 5g-core
```

If the namespace gets stuck terminating, inspect remaining finalizers/resources:

```bash
kubectl get all,pvc,configmap,secret,serviceaccount,role,rolebinding -n 5g-core
kubectl describe namespace 5g-core
```

## Persistent Grafana Port-Forward With systemd

This staging folder includes one systemd unit template for Grafana:

```text
systemd/5g-core-grafana-portforward.service
```

It exposes Grafana from the Kubernetes `5g-core` namespace through the host:

```text
Grafana: host port 3400 -> svc/grafana:3000
```

Grafana uses host port `3400` to avoid clashing with Docker Compose Grafana,
which commonly uses host port `3300`. The unit uses `--address 0.0.0.0`, so
other hosts on the lab network can reach Grafana through the Kubernetes node IP,
assuming the host firewall allows that port.

The Open5GS WebUI does not need a port-forward when the Kubernetes
`open5gs-5gc` LoadBalancer exposes `9999/TCP`. Access it directly through the
MetalLB IP:

```text
Open5GS WebUI: http://<OPEN5GS_METALLB_IP>:9999
```

For the current staging env this is `http://192.168.50.245:9999`; update the address if you choose a different CN MetalLB IP.

Install the Grafana port-forward service:

```bash
sudo cp systemd/5g-core-grafana-portforward.service /etc/systemd/system/
sudo systemctl daemon-reload
```

Enable and start it:

```bash
sudo systemctl enable --now 5g-core-grafana-portforward.service
```

Check status:

```bash
systemctl status 5g-core-grafana-portforward.service
```

Follow logs:

```bash
journalctl -u 5g-core-grafana-portforward.service -f
```

Access from another lab host using the Kubernetes node IP:

```text
Grafana: http://<K8S_NODE_IP>:3400
```

If the service fails, first verify the target Kubernetes service exists:

```bash
kubectl get svc -n 5g-core grafana -o wide
```

Stop and disable it:

```bash
sudo systemctl disable --now 5g-core-grafana-portforward.service
```

Remove it from the system:

```bash
sudo rm /etc/systemd/system/5g-core-grafana-portforward.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

Port-forwarding is suitable for Grafana because it is a TCP web application. Do
not use `kubectl port-forward` for N2/N3 traffic; Open5GS N2/N3 should use the
MetalLB service IP because those paths use SCTP and UDP.

## Troubleshooting Notes

### Open5GS cannot open `open5gs-5gc.yml`

If Open5GS logs this:

```text
FATAL: cannot open file `open5gs-5gc.yml`
```

then the container entrypoint was probably bypassed. The Open5GS image entrypoint
runs `open5gs_entrypoint.sh`, which generates `open5gs-5gc.yml` from
`open5gs-5gc.yml.in` before starting `5gc`.

In Kubernetes, do not override the image entrypoint with `command`. Use `args`
for the Open5GS process arguments:

```yaml
args: ["5gc", "-c", "open5gs-5gc.yml"]
```

The Helm chart is set up this way.

### InfluxDB panics about `/var/lib/influxdb3-plugins/.venv/bin/activate`

If InfluxDB logs this:

```text
unable to initialize python environment: Activation script not found at "/var/lib/influxdb3-plugins/.venv/bin/activate"
```

then InfluxDB was started with a plugin directory that does not contain the
expected Python virtual environment. The Kubernetes chart does not enable
`--plugin-dir` because this stack does not need InfluxDB 3 processing plugins for
basic Telegraf writes and Grafana reads.
