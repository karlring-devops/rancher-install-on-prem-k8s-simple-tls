# rancher-install-on-prem-k8s-simple-tls
Setup Rancher on existing on-prem k8s cluster - simple TLS

Requires existing Kubernetes Cluster, if no cluster:

* install Vagrant locally
* Use my repo to setup on-prem basic cluster (https://github.com/karlring-devops/cluster-vagrant-kubernetes-nfs)
   - set nodes to (1x) Master, (2x) nodes
   - CPU (2x) and MEM(4096 Gib) for each
* run: setup script from this repo.
* Kubernetes Dashboard (if you want): https://github.com/karlring-devops/kubernetes-dashboard
* Kubernetes simple tools (if you want): https://github.com/karlring-devops/.kprofile


Reference: https://rancher.com/docs/rancher/v2.0-v2.4/en/installation/install-rancher-on-k8s/
