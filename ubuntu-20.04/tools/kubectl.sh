#!/bin/bash
set -e -o pipefail
TIME=date\ +%d/%m/%Y-%H:%M:%S
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

initArch() {
  OS_ARCH=$(uname -m)
  case $OS_ARCH in
    armv5*) OS_ARCH="armv5";;
    armv6*) OS_ARCH="armv6";;
    armv7*) OS_ARCH="arm";;
    aarch64) OS_ARCH="arm64";;
    x86) OS_ARCH="386";;
    x86_64) OS_ARCH="amd64";;
    i686) OS_ARCH="386";;
    i386) OS_ARCH="386";;
  esac
}


print_message() {
    lightcyan='\033[1;36m'
    nocolor='\033[0m'
    echo -e "${lightcyan}[$(${TIME})]$1${nocolor}"
}

if [ $(id -u) -ne 0 ]; then 
    echo 1>&2 "ERROR: YOU ARE RUNNING AS ${USER} , YOU SHOULD BE ROOT"
    exit 1
fi

initArch

print_message "Installing Kubectl"

if ! [ -x "$(command -v kubectl)" ]; then
    print_message "Downloading kubectl from  https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${OS_ARCH}/kubectl"
    curl -SLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${OS_ARCH}/kubectl"
    curl -SLO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${OS_ARCH}/kubectl.sha256"
    echo "$(<kubectl.sha256) kubectl" | sha256sum --check
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    print_message "Sucessfully kubectl installation"
else    
    print_message "Kubectl is already installed!!!!!"
     kubectl version --short || true
fi