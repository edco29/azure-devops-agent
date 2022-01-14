# 1. Instalation de herramientas bases.

Ejecutar los siguientes scripts:

 1. docker.sh $OS_AGENT_USER => Pasar como parametro el usuario del sistema operativo que sera agregado al grupo docker y posteriormente sera ejecutor de los servicios del agente de azure pipelines.
 2. git.sh
 3. helm.sh
 4. kubectl.sh


# 2. Instalation y configuracion del agente de azure devops

 Ejecutar el siguiente script:
 
 ./startup.sh $OS_AGENT_USER $AZ_DEVOPS_PAT_FILE $AZ_DEVOPS_POOL_NAME $AZ_DEVOPS_ORGANIZATION_NAME
 
- OS_AGENT_USER: 			    Usuario del sistema operativo que sera ejecutor de los servicios de los agentes .
- AZ_DEVOPS_PAT_FILE: 	        Direccion exacta del archivo que contiene el azure devops pat (Personal Access Token).
- AZ_DEVOPS_POOL_NAME: 	        Nombre del azure devops pool Name.
- AZ_DEVOPS_ORGANIZATION_NAME:  Nombre de la organizacion de azure devops

ejemplo:

> ./startup.sh ubuntu /opt/patfile oncloud ABC-ORGANIZATION

 
** NOTA:**
 
 1. Brindar permisos de ejecucion a todos los scripts antes de ejecutarlos **(chmod +x scripname.sh)**
 
 2. Todos los scripts deberan ser ejecutados como root.