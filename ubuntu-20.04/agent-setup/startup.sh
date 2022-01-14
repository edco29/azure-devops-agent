#!/bin/bash
set -e -o pipefail

TIME=date\ +%d/%m/%Y-%H:%M:%S
OS_AGENT_USER="$1"
AZ_DEVOPS_PAT_FILE="$2"
AZ_DEVOPS_POOL_NAME="$3"
OS_AGENT_WORKSPACE="/opt/azdo"
AZ_DEVOPS_ORG_URL="https://dev.azure.com/$4"
AZ_DEVOPS_AGENT_NAME="$(hostname)"
USER=$(whoami)


if [  -z "$AZ_DEVOPS_ORG_URL" ]; then
    echo 1>&2 "ERROR: missing AZ_DEVOPS_ORG_URL environment variable"
    exit 1
fi

if [ -z "$AZ_DEVOPS_POOL_NAME" ]; then
    echo 1>&2 "ERROR: missing AZ_DEVOPS_POOL_NAME environment variable"
    exit 1
fi

if [ -z "$OS_AGENT_WORKSPACE" ]; then
    echo 1>&2 "ERROR: missing OS_AGENT_WORKSPACE environment variable"
    exit 1
fi

if [ -d "$OS_AGENT_WORKSPACE" ]; then
    echo 1>&2 "ERROR: Path ${OS_AGENT_WORKSPACE} already exits , check OS_AGENT_WORKSPACE environment variable "
    exit 1
fi


if [ -z "$OS_AGENT_USER" ]; then
    echo 1>&2 "ERROR: missing OS_AGENT_USER environment variable"
    exit 1
fi

if ! id  -u "$OS_AGENT_USER" &>/dev/null ; then
    echo 1>&2 "ERROR: User $OS_AGENT_USER does not exists"
    exit 1
fi

# enforce security
if [ -z "$AZ_DEVOPS_PAT_FILE" ]; then
    echo 1>&2 "ERROR: missing AZ_DEVOPS_PAT_FILE environment variable"
    exit 1
fi

if [ ! -f "$AZ_DEVOPS_PAT_FILE" ]; then
    echo 1>&2 "ERROR: File $AZ_DEVOPS_PAT_FILE does not exists"
    exit 1
fi

print_message() {
    lightcyan='\033[1;36m'
    nocolor='\033[0m'
    echo -e "${lightcyan}[$(${TIME})]$1${nocolor}"
}



if [ $(id -u) -eq 0 ]; then
    print_message "1. Pre-requirements validation"
    if ! [ -x "$(command -v jq)" ]; then
        print_message "1.1 jq is not installed.........Installing jq .!!!!"
        apt-get -y update
        apt-get install jq -y
        jq --version
    fi
else
    echo 1>&2 " ERROR: You are running as ${USER} , you should be root"
    exit 1
fi

print_message "2. Sucessfully Pre-requirements validation"

print_message "3. Getting Last version of azure pipeline agent"


AZ_AGENT_RESPONSE=$(curl -LsS \
    -u user:$(cat "$AZ_DEVOPS_PAT_FILE") \
    -H 'Accept:application/json;api-version=3.0-preview' \
    "$AZ_DEVOPS_ORG_URL/_apis/distributedtask/packages/agent?platform=linux-x64")

if echo "$AZ_AGENT_RESPONSE" | jq . >/dev/null 2>&1; then
    AZ_AGENTPACKAGE_URL=$(echo "$AZ_AGENT_RESPONSE" |
        jq -r '.value | map([.version.major,.version.minor,.version.patch,.downloadUrl]) | sort | .[length-1] | .[3]')
fi


if [ -z "$AZ_AGENTPACKAGE_URL" -o "$AZ_AGENTPACKAGE_URL" == "null" ]; then
    echo 1>&2 "ERROR: could not determine a matching Azure Pipelines agent - check that account '$AZ_DEVOPS_ORG_URL' is correct and the token is valid for that account"
    exit 1
fi

print_message "4. Downloading and installing Azure Pipelines agent from ${AZ_AGENTPACKAGE_URL}"

mkdir -p ${OS_AGENT_WORKSPACE} && cd ${OS_AGENT_WORKSPACE}
curl -LsS $AZ_AGENTPACKAGE_URL | tar -xz &
wait $!

print_message "5. Installing azure pipeline dependencies"

./bin/installdependencies.sh

source ./env.sh

print_message "6. Running Azure Pipelines agent as service"

chown -R ${OS_AGENT_USER} ${OS_AGENT_WORKSPACE}
chmod -R 755 ${OS_AGENT_WORKSPACE}
runuser -l ${OS_AGENT_USER} -c "/opt/azdo/config.sh --unattended --url ${AZ_DEVOPS_ORG_URL} --auth pat --token $(cat "$AZ_DEVOPS_PAT_FILE") --pool ${AZ_DEVOPS_POOL_NAME}  --agent ${AZ_DEVOPS_AGENT_NAME} --acceptTeeEula"


./svc.sh install ${OS_AGENT_USER}
./svc.sh start

print_message "7. Deleting AZ_DEVOPS_PAT_FILE"

rm -rf $AZ_DEVOPS_PAT_FILE