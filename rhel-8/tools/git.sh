#!/bin/bash
set -e -o pipefail
TIME=date\ +%d/%m/%Y-%H:%M:%S

print_message() {
    lightcyan='\033[1;36m'
    nocolor='\033[0m'
    echo -e "${lightcyan}[$(${TIME})]$1${nocolor}"
}

if [ $(id -u) -ne 0 ]; then 
    echo 1>&2 "ERROR: YOU ARE RUNNING AS ${USER} , YOU SHOULD BE ROOT"
    exit 1
fi

print_message "Installing Git"


if ! [ -x "$(command -v git)" ]; then
    dnf update -y
    dnf install -y git
    print_message "Sucessfully git installation"
else    
    print_message "Git is already installed!!!!"
     git --version || true
fi