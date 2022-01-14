#!/bin/bash
set -e -o pipefail
TIME=date\ +%d/%m/%Y-%H:%M:%S
OS_AGENT_USER="$1"
USER=$(whoami)


print_message() {
    lightcyan='\033[1;36m'
    nocolor='\033[0m'
    echo -e "${lightcyan}[$(${TIME})]$1${nocolor}"
}

if [ $(id -u) -ne 0 ]; then 
    echo 1>&2 "ERROR: YOU ARE RUNNING AS ${USER} , YOU SHOULD BE ROOT"
    exit 1
fi


print_message "Validating user => $OS_AGENT_USER"


if [ -z "$OS_AGENT_USER" ]; then
    echo 1>&2 "ERROR: Missing OS_AGENT_USER environment variable"
    exit 1
fi

if ! id  -u "$OS_AGENT_USER" &>/dev/null ; then
    echo 1>&2 "ERROR: User $OS_AGENT_USER does not exists"
    exit 1
fi


print_message "User $OS_AGENT_USER exists"

print_message "Validating Docker Installation"

if  ! [ -x "$(command -v docker)" ]; then
    print_message "Docker is not installed .... Installing docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    print_message "Enable docker service"
    systemctl enable docker
    systemctl status docker
    print_message "Adding user ${OS_AGENT_USER} to docker group"
    usermod -aG docker ${OS_AGENT_USER}
    print_message "Sucessfully Docker setup"
else    
    print_message "Docker is already installed!!!!!"
    print_message "Adding user ${OS_AGENT_USER} to docker group"
    usermod -aG docker ${OS_AGENT_USER}
    docker --version || true
fi
