#!/bin/bash
set -e -o pipefail
TIME=date\ +%d/%m/%Y-%H:%M:%S
HELM_VERSION=v3.7.2

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

print_message "Installing helm........!!"

if ! [ -x "$(command -v helm)" ]; then
    print_message "Downloading helm from  https://get.helm.sh/helm-${HELM_VERSION}-linux-${OS_ARCH}.tar.gz"
    curl -o helm-${HELM_VERSION}-linux-${OS_ARCH}.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-${OS_ARCH}.tar.gz
    tar zxvf helm-${HELM_VERSION}-linux-${OS_ARCH}.tar.gz
    install -o root -g root -m 0755 linux-${OS_ARCH}/helm /usr/local/bin/helm
    rm -rf linux-${OS_ARCH}
    rm -f helm-${HELM_VERSION}-linux-${OS_ARCH}.tar.gz
    print_message "Sucessfully helm installation"
else    
    print_message "Helm is already installed!!!!"
     helm version || true
fi
