# k3s Cluster

> **Type**: Lightweight Kubernetes (k3s)  
> **Category**: Helpful Tools / Lab Orchestration  
> **Role**: Sandbox for learning Kubernetes, running test workloads, and staging future services

---

## 🧩 Overview

A minimal k3s cluster running inside Proxmox on its own NAT-ed overlay network (`192.168.50.0/24`).  
Installed with the official one-liner (`curl -sfL https://get.k3s.io | sh -`) and currently unmodified beyond the default flannel CNI.

|                | Count | OS / Size             | IP Example        |
|----------------|-------|-----------------------|-------------------|
| **Server**     | 1     | Ubuntu 24.04, 2 vCPU, 2 GB RAM | `192.168.50.131` |
| **Workers**    | 2     | Ubuntu 24.04, 2 vCPU, 2 GB RAM | `192.168.50.132–133` |

All VMs live on **Proxmox** and attach to **`vmbr50`** (software bridge).  
Outbound traffic is masqueraded to the main LAN (`192.168.8.0/24`) by host-level iptables rules.

---

## ⚙️ Installation Details

| Item                    | Value                                  |
|-------------------------|----------------------------------------|
| k3s version             | Latest stable (installed via script)   |
| Install method          | `curl | sh` from **get.k3s.io**        |
| CNI                     | **flannel** (default)                  |
| Datastore               | embedded etcd (default single-node)    |
| Ingress                 | *Not installed* (Traefik disabled)     |
| Load balancer           | None yet                               |
| Node join token         | Stored at `/var/lib/rancher/k3s/server/node-token` on the server |

> To add workers you ran something like:  
> ```bash
> curl -sfL https://get.k3s.io | \
>   K3S_URL="https://192.168.50.131:6443" \
>   K3S_TOKEN="$(cat /path/to/node-token)" \
>   sh -
> ```

---

## 🌐 Networking

| Layer                 | Range / Interface          | Notes                                |
|-----------------------|----------------------------|--------------------------------------|
| k3s Pod CIDR          | Auto (flannel)             | encapsulated VXLAN                   |
| Service CIDR          | `10.43.0.0/16` (default)   | cluster-internal services            |
| Host bridge           | `vmbr50` → `192.168.50.0/24`| Each VM has static IP in that subnet |
| NAT to LAN            | iptables MASQUERADE        | Allows Pods/Nodes to reach internet  |

---

## 🔧 Current State

* No ingress controller, storage class, or Helm workloads yet.  
* Ideal blank slate for experimenting with:
  * **ingress-nginx** or **Traefik 3**  
  * **MetalLB** for LoadBalancer IPs  
  * **cert-manager** for automatic TLS  
  * **Longhorn** or **OpenEBS** for persistent volumes  
  * **ArgoCD / Flux** for GitOps

---

## 📜 Useful Commands

```bash
# Get cluster info
kubectl cluster-info

# List nodes with resources
kubectl get nodes -o wide

# Check flannel VXLAN interface on a node
ip -d link show flannel.1

# View k3s service logs
sudo journalctl -u k3s -f
```
kubeconfig is available on the server at /etc/rancher/k3s/k3s.yaml; copy it to your workstation (~/.kube/config) and change the server IP to 192.168.50.131.


## 🗃️ Backup & Snapshots
k3s includes automatic etcd snapshots under /var/lib/rancher/k3s/server/db/snapshots.
Consider exporting these to the Proxmox host or external storage on a schedule.
