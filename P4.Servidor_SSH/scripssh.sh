#!/bin/bash
source /home/albertodobleh/SysAdmin/AdminSistemas/LinModulos/modulos

#Actualizar el sistema
echo "Actualizando el sistema..."
apt-get update -y
apt-get upgrade -y

#Instalar SSH
echo "Instalando Servicio SSH..."
apt-get install openssh-server -y

#Solicitar la IP
ipserver=""
while :; do
    read -p "Ingrese la direccion del servidor: " ip
    echo "$ipserver"
    if validar_ipv4 "$ipserver"; then
        echo "La IP es válida."
        break  # Sale del bucle si la IP es válida
    else
        echo "IP inválida, inténtelo de nuevo."
    fi
done

#Configuracion de IP Estatica
echo -e "Empezando proceso de asignacion de ip estatica a la red local....."
echo -e "Generando copia de seguridad del archivo de configuracion de NetPlan...."
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak  # Copia de seguridad

echo -e "Empezando la insercion de nueva informacion al archivo.."
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
echo -e "Aplicando cambios en los adaptadores de red de la maquina...."
sudo netplan apply

#Solicitud de datos para creacion de usuario
usuario=""
read -p "Ingrese el nombre del usuario: " usuario
contrasena=""
read -p "Ingrese la contraseña: " contrasena

#Crear usuario
echo "Creando usuario..."
useradd -m -d /home/$usuario -s /bin/bash $usuario
echo "$usuario:$contrasena" | chpasswd

#Verificar que el usuario fue creado
echo "Verificando que el usuario fue creado..."
cat /etc/passwd | grep $usuario

#Asignando permisos para el usuario en el SSH
ehcho "Asignando permisos para el usuario en el SSH..."
echo "$usuario ALL=(ALL) ALL" >> /etc/sudoers

#Ajustando Firewall para permitir SSH
echo "Ajustando Firewall para permitir SSH..."
ufw allow ssh

#Verificar que este corriendo el SSH
echo "Verificando que el servicio SSH este corriendo..."
systemctl status ssh
