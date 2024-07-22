#!/usr/bin/env bash

ch6_install_minikube(){
    if ! command -v minikube &>/dev/null; then
        cd /tmp
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
        sudo dpkg -i minikube_latest_amd64.deb
        cd $HOME
    fi
}

ch6_install_docker_client(){
    if ! command -v docker &>/dev/null; then
        sudo apt install -y docker-ce-cli

        echo "eval $(minikube -p minikube docker-env)" >> ~/.zshrc || \
        echo "eval $(minikube -p minikube docker-env)" >> ~/.bashrc
    fi
}

# OPTIONAL
ch7_install_kubectl(){
    if ! command -v kubectl &>/dev/null; then
        cd /tmp
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        cd $HOME
    fi
}

# OPTIONAL...
ch7_install_kubectl_as_deb(){
    if ! command -v kubectl &>/dev/null; then
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
        
        # sudo mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

        # OJO: versión 30... o no
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

        sudo apt-get update
        sudo apt-get install -y kubectl
    fi
}

ch8_install_go(){
    sudo rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
    
    if echo $PATH | grep -qv /usr/local/go/bin; then
        echo -e "\nexport PATH=$PATH:/usr/local/go/bin" ~/.zshrc || \
        echo -e "\nexport PATH=$PATH:/usr/local/go/bin" ~/.bashrc
    fi
}

ch8_install_skaffold(){
    if ! command -v skaffold; then
        cd /tmp
        curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
        sudo install skaffold /usr/local/bin/
        cd $HOME
    fi
}

ch8_install_container_structure_test(){
    if ! command -v container-structure-test &>/dev/null; then
        curl -LO https://github.com/GoogleContainerTools/container-structure-test/releases/latest/download/container-structure-test-linux-amd64
        chmod +x container-structure-test-linux-amd64
        sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
    fi
}


# ---

if true; then

fi