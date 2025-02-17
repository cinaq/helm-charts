#!/usr/bin/env bash

set -e -o pipefail

export GENERAL_CLIENT_NAME="${GENERAL_CLIENT_NAME:-client}"
export BASE_DOMAIN="${BASE_DOMAIN:-lowops.cinaq.com}"
export EMAIL_DOMAIN="${EMAIL_DOMAIN:-cinaq.com}"
export PLATFORM_VERSION="${PLATFORM_VERSION:-v4.0.0-alpha15}"
export CONTAINER_IMAGE="${CONTAINER_IMAGE:-docker.io/cinaq/low-ops-ansible-roles:0-ci-v4-0-0-alpha15}"
export PLATFORM_PRIVATE_REGISTRY_USER="${PLATFORM_PRIVATE_REGISTRY_USER:-user}"
export PLATFORM_PRIVATE_REGISTRY_TOKEN="${PLATFORM_PRIVATE_REGISTRY_TOKEN:-token}"
export CHART_VERSION="${CHART_VERSION:-0.1.6}"
export KIND_CLUSTER_VERSION="${KIND_CLUSTER_VERSION:-v1.30.8}"

function set_limits() {
    echo ">>> Setting limits"
    sudo tee -a /etc/security/limits.conf > /dev/null << 'EOF'
*               soft    nofile           1048570
*               hard    nofile           1048576
EOF

    # Apply the new limits to the current session
    ulimit -n 1048576

    # Apply the new limits system-wide
    sudo sysctl -w fs.file-max=1048576
    # Verify the new limits
    echo "Current file descriptor limits:"
    ulimit -n
    echo "System-wide file descriptor limits:"
    sysctl fs.file-max
}

function set_sysctl() {
    echo ">>> Setting sysctl"
    sudo tee -a /etc/sysctl.conf > /dev/null << 'EOF'
fs.inotify.max_user_watches=100000
fs.inotify.max_user_instances=100000
EOF
    sudo sysctl -p
    # Verify the changes
    echo "Current inotify settings:"
    sudo sysctl fs.inotify.max_user_watches
    sudo sysctl fs.inotify.max_user_instances
}

function install_docker() {

    echo ">>> Installing docker"
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    # shellcheck disable=SC1091
    sudo echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # wait for docker to start
    sleep 10
    sudo systemctl enable docker
    sudo systemctl start docker
    # check if docker is running
    if ! sudo docker ps > /dev/null 2>&1; then
        echo "Docker is not running"
        exit 1
    fi
}

function install_dependencies() {

    mkdir -p bin

    echo ">>> Installing dependencies"

    if [ ! -f bin/kind ]; then
        echo "Installing kind"
        wget -q -O bin/kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
        chmod +x bin/kind
        sudo cp bin/kind /usr/local/bin/kind
    fi

    if [ ! -f bin/kubectl ]; then
        echo "Installing kubectl" 
        wget -q -O bin/kubectl "https://dl.k8s.io/release/v1.32.1/bin/linux/amd64/kubectl"
        chmod +x bin/kubectl
        sudo cp bin/kubectl /usr/local/bin/kubectl
    fi

    if [ ! -f bin/helm ]; then
        echo "Installing helm"
        sudo wget -q -O /tmp/helm.tar.gz https://get.helm.sh/helm-v3.9.0-rc.1-linux-amd64.tar.gz
        sudo tar xzf /tmp/helm.tar.gz -C /tmp
        sudo mv /tmp/linux-amd64/helm bin/helm
        sudo chmod +x bin/helm
        sudo cp bin/helm /usr/local/bin/helm
    fi

    if [ ! -f bin/k9s ]; then
        echo "Installing k9s"
        sudo wget -q -O /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
        sudo tar xzf /tmp/k9s.tar.gz -C /tmp
        sudo mv /tmp/k9s bin/
        sudo chmod +x bin/k9s
        sudo cp bin/k9s /usr/local/bin/k9s
    fi

    if [ ! -f bin/jq ]; then
        echo "Installing jq"
        wget -q -O bin/jq "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64"
        sudo chmod +x bin/jq
        sudo cp bin/jq /usr/local/bin/jq
    fi

    if [ ! -f bin/yq ]; then
        echo "Installing yq"
        wget -q -O bin/yq https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64
        sudo chmod +x bin/yq
        sudo cp bin/yq /usr/local/bin/yq
    fi

    # check if dependencies are installed
    if ! kind --version > /dev/null 2>&1; then
        echo "kind is not installed"
        exit 1
    fi


    if ! kubectl version --client=true > /dev/null 2>&1; then
        echo "kubectl is not installed"
        exit 1
    fi
    if ! helm version > /dev/null 2>&1; then
        echo "helm is not installed"
        exit 1
    fi

    if ! k9s version > /dev/null 2>&1; then
        echo "k9s is not installed"
        exit 1
    fi

    if ! jq --version > /dev/null 2>&1; then
        echo "jq is not installed"
        exit 1
    fi

    if ! yq --version > /dev/null 2>&1; then
        echo "yq is not installed"
        exit 1
    fi
}

function create_kind_config() {
    echo ">>> Creating kind config"
    cat > kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
networking:
  apiServerPort: 6443
  apiServerAddress: 0.0.0.0
EOF
}

function create_cluster() {
    local kind_cluster_version="${KIND_CLUSTER_VERSION}"
    create_kind_config
    echo ">>> Creating cluster"
    if kubectl get nodes > /dev/null 2>&1; then
        echo "cluster is running"
    else
        kind create cluster --name low-ops --config kind-config.yaml --image "kindest/node:${kind_cluster_version}" -v 1
        kind get kubeconfig --name low-ops > kubeconfig.yaml
    fi
    # check if cluster is created
    if ! kubectl get nodes > /dev/null 2>&1; then
        echo "cluster is not running"
        exit 1
    fi
}

function create_haproxy_config() {
    echo ">>> Creating haproxy config"
    cat > haproxy.cfg << 'EOF'
global
    log stdout format raw local0 info

defaults
    log global
    retries 2
    option dontlognull
    timeout connect 10000
    timeout server 600000
    timeout client 600000

frontend http_frontend
    bind *:80 
    default_backend http_backend

frontend https_frontend
    bind *:443 
    default_backend https_backend

backend https_backend
    server nginx-ingress 172.18.255.200:443 check send-proxy

backend http_backend
    server nginx-ingress 172.18.255.200:80 check send-proxy
EOF
}

function haproxy() {
    echo ">>> Installing haproxy"
    if sudo docker ps -a --format '{{.Names}}' | grep -q '^haproxy$'; then
        sudo docker stop haproxy
        sudo docker rm haproxy || true
    else
        echo "Container 'haproxy' does not exist."
    fi
    sudo docker run -d \
    --restart unless-stopped \
    --name haproxy \
    --network=kind \
    -v "$(pwd)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro" \
    -p 443:443 \
    -p 80:80 \
    haproxytech/haproxy-alpine:2.4

    # check if haproxy is running
    if ! sudo docker ps | grep haproxy > /dev/null 2>&1; then
        echo "haproxy is not running"
        exit 1
    fi
}

function install_metallb() {

    local start_network="172.18.255.200"
    local end_network="172.18.255.250"

    echo ">>> Installing metallb"
    helm repo add "bitnami" "https://charts.bitnami.com/bitnami"
    helm repo update

    helm upgrade -i -n metallb --create-namespace metallb bitnami/metallb \
        --version 3.0.12 \
        --set "configInline.address-pools[0].name=default" \
        --set "configInline.address-pools[0].protocol=layer2" \
        --set "configInline.address-pools[0].addresses[0]=${start_network}-${end_network}" \
        --set "speaker.secretValue=stronk-key"
    
    # check if metallb is installed
    if ! helm status -n metallb metallb > /dev/null 2>&1; then
        echo "metallb is not installed"
        exit 1
    fi
}

function install_platform() {
    local namespace="lowops-devops"
    local chart_values_file="values.yaml"
    local platform_version="${PLATFORM_VERSION}"
    local general_client_name="${GENERAL_CLIENT_NAME}"
    local chart_version="${CHART_VERSION}"
    local base_domain="${BASE_DOMAIN}"
    local email_domain="${EMAIL_DOMAIN}"
    local container_image="${CONTAINER_IMAGE}"
    local platform_private_registry_user="${PLATFORM_PRIVATE_REGISTRY_USER}"
    local platform_private_registry_token="${PLATFORM_PRIVATE_REGISTRY_TOKEN}"

    helm repo add cinaq \
    "https://cinaq.github.io/helm-charts"
    helm repo update

    HELM_CMD="helm upgrade -i lowops-platform cinaq/lowops-platform --create-namespace -n $namespace"
    HELM_CMD="$HELM_CMD --set lowops.image.containerImage=$container_image"
    HELM_CMD="$HELM_CMD --set lowops.config.common.enable_letsencrypt=true"
    HELM_CMD="$HELM_CMD --set lowops.config.common.enable_nginx_proxy_protocol=true"
    HELM_CMD="$HELM_CMD --set lowops.config.common.platform_version=$platform_version"
    HELM_CMD="$HELM_CMD --set lowops.config.common.general_client_name=$general_client_name"
    HELM_CMD="$HELM_CMD --set lowops.config.common.platform_type=free"
    HELM_CMD="$HELM_CMD --set lowops.config.common.foundation_type=generic"
    HELM_CMD="$HELM_CMD --set lowops.config.common.low_ops_env=dev"
    HELM_CMD="$HELM_CMD --set lowops.config.common.base_domain=$base_domain"
    HELM_CMD="$HELM_CMD --set lowops.config.common.email_domain=$email_domain"
    HELM_CMD="$HELM_CMD --set lowops.config.common.platform_private_registry_user=$platform_private_registry_user"
    HELM_CMD="$HELM_CMD --set lowops.config.common.platform_private_registry_token=$platform_private_registry_token"
    if [ -f "$chart_values_file" ]; then
        HELM_CMD="$HELM_CMD -f $chart_values_file"
    fi
    if [ -n "$chart_version" ]; then
        HELM_CMD="$HELM_CMD --version=$chart_version"
    fi
    echo "$HELM_CMD"
    eval "$HELM_CMD"
}

function main() {
    set_limits
    set_sysctl
    install_docker
    install_dependencies
    create_cluster
    create_haproxy_config
    haproxy
    install_metallb
    install_platform
}

main