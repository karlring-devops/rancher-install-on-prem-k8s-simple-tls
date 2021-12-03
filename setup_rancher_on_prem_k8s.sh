# /***********************************************************************************************
# /-- RANCHER SETUP LOCAL CLUSTER 
# /-- source : https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/
# /***********************************************************************************************
#!/bin/bash

function helm_install(){ 
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
}

function setup_local_kubeconf(){
    mkdir -p /home/$USER/.kube
    sudo cp -f /etc/kubernetes/admin.conf /home/$USER/.kube/config
    sudo chown $USER:$USER /home/$USER/.kube/config
    chmod 600 /home/$USER/.kube/config
    echo "[Created]: /home/$USER/.kube/config"
}

function rancher_create_cattle_system(){
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
    kubectl create namespace cattle-system
}

function rancher_setup_jetpack(){
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --create-namespace \
      --version v1.5.1
}

function rancher_install_deployment(){
    helm install rancher rancher-latest/rancher \
      --namespace cattle-system \
      --set hostname=rancher.my.org \
      --set replicas=3
      kubectl -n cattle-system rollout status deploy/rancher
}


function rancher_set_nodeport(){
    kubectl get service rancher -n cattle-system -o yaml | tee rancher-service-clusterip.yaml 
    sed -e 's/type: ClusterIP/type: NodePort/g' rancher-service-clusterip.yaml > rancher-service-nodeport.yaml
    kubectl apply -f rancher-service-nodeport.yaml
    kubectl get svc rancher -n cattle-system -o yaml
}

function rancher_get_login_ui(){
    RANCHER_PASSWORD=`kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'`
        # zxzxwbskw8h7cgl2ttk5pjd2dbmn5mmxdgqbz5dn9vgxhf9lf5jmh5
    RANCHER_NODE_PORT=`kubectl get svc -n cattle-system | grep NodePort | awk '{print $5}'|cut -d':' -f3|cut -d'/' -f1`
    RANCHER_IPADDRESS=`kubectl get nodes -o wide | grep master | awk '{print $6}'`
    RANCHER_URL="https://${RANCHER_IPADDRESS}:${RANCHER_NODE_PORT}"
    echo "[Rancher Url]: -> ${RANCHER_URL}"
    echo "[Initial Psw]: -> ${RANCHER_PASSWORD}"
    echo "[Rancher UID]: -> admin"
    echo "[New Passw  ]: -> 8FR6M67WlH8YN9aE"
}

function rancher_get_demo(){
    RANCHER_DEMO_URL=`https://rancher.my.org/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')`
    echo "[Rancher Url]: -> ${RANCHER_DEMO_URL}"
}


__main__(){
    [ ! `which helm` ] && helm_install
    setup_local_kubeconf
    rancher_create_cattle_system
    rancher_setup_jetpack
    rancher_install_deployment
    rancher_set_nodeport
    rancher_get_login_ui
    rancher_get_demo
}

__main__
