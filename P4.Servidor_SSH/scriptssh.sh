#!/bin/bash
source /home/albertodobleh/SysAdmin/AdminSistemas/LinModulos/modulos

verde="\e[32m"
rojo="\e[31m"
reset="\e[0m"

#Actualizar el sistema
echo -e "${verde}Actualizando el sistema...${reset}"
apt-get update -y
apt-get upgrade -y

#Instalar SSH
echo .e "${verde}Instalando Servicio SSH...${reset}"
apt-get install openssh-server -y

#Solicitar la IP
ipserver=""
while :; do
    read -p "Ingrese la direccion del servidor: " ipserver
    if validar_ipv4 "$ipserver"; then
        echo "${verde}La IP es válida.${reset}"
        break
    else
        echo "${rojo}IP inválida, inténtelo de nuevo.${reset}"
    fi
done

#Configuracion de IP Estatica
echo -e "${verde}Empezando proceso de asignacion de ip estatica a la red local.....${reset}"
echo -e "${verde}Generando copia de seguridad del archivo de configuracion de NetPlan....${reset}"
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak  # Copia de seguridad

echo -e "${verde}Empezando la insercion de nueva informacion al archivo..${reset}"
cat << EOF | sudo tee /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true

    enp0s8:
      dhcp4: false
      addresses:
        - ${ipserver}/24
      gateway4: ${ipserver}
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF

# Aplicar cambios
echo -e "${verde}Aplicando cambios en los adaptadores de red de la maquina....${reset}"
sudo netplan apply

#Solicitud de datos para creacion de usuario
usuario=""
while true; do
  read -p "Introduzca el nombre de usuario: " usuario
  if [[ -n "$usuario" ]]; then
    echo "${verde}Usuario Valido${reset}"
    break
  fi
  echo "${rojo}El usuario no puede estar vacio${reset}"
done
contrasena=""
while true; do
  read -p "Introduzca la contrasena: " contrasena
  if [[ -n "$contrasena" ]]; then
    echo "${verde}Contrasena Valida${reset}"
    break
  fi
  echo "${rojo}La contrasena no puede estar vacia${reset}"
done

#Crear usuario
echo "${verde}Creando usuario...${reset}"
useradd -m -d /home/$usuario -s /bin/bash $usuario
echo "$usuario:$contrasena" | chpasswd

#Verificar que el usuario fue creado
echo "${verde}Verificando que el usuario fue creado...${reset}"
cat /etc/passwd | grep $usuario

#Asignando permisos para el usuario en el SSH
echo "${verde}Asignando permisos para el usuario en el SSH...${reset}"
path="/home/$usuario/.ssh"
mkdir -p $path
chmod 700 $path
chown $usuario:$usuario $path

#Ajustando Firewall para permitir SSH
echo "${verde}Ajustando Firewall para permitir SSH...${reset}"
ufw allow ssh

#Iniciando el servicio SSH
echo "${verde}Iniciando el servicio SSH...${reset}"
systemctl start ssh

#Verificar que este corriendo el SSH
echo "${verde}Verificando que el servicio SSH este corriendo...${reset}"
systemctl status ssh
