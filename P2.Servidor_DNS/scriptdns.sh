#!/bin/bash

#Actualizar el sistema
echo "Actualizando el sistema..."
apt-get update -y
apt-get upgrade -y

#Instalar BIND9
echo "Instalando Servicio DNS..."
apt-get install bind9 bind9utils

#Validar la IP
validar_ipv4() {
	local ip="$1"
	local regex=' ^([0-9]{1,3}\.([0-9]{1,3})\.([0-9]{1-3})\.([0-9]{1-3})$'
	if [[ "$ip" =~ "$regex" ]];then
		return 0
	else
		return 1
	fi
}

#Configuracion de Zona Directa
dominio=""
while true; do
	read -p "Introduzca el dominio: " dominio
	if [[ -n "$dominio" ]]; then
		echo "Dominio Valido"
		break
	fi
	echo "El dominio no puede estar vacio"
done

ip=""
read -p "Introduzca la direcion IP: " ip


echo "Creando carpeta de zonas..."
echo "Asignando permisos para poder acceder...."

sudo mkdir -p /etc/bind/zones
sudo chown bind:bind /etc/bind/zones

nombrearchzona="db.${dominio}"
ruta="/etc/bind/zones/${nombrearchzona}"

echo "Generando la zona del dominio...."
cat > ${ruta} << EOF
\$TTL	86400
@	IN	SOA	ns1.${dominio}. admin.${dominio}. (
				$(date +%Y%m%d)01 ; Serial
			28800		; Refresh
			 7200		; Retry
		       864000		; Expire
			86400 )		; Minimum TTL
;
	IN	NS	ns1.${dominio}.
ns1	IN	A	${ip}
@	IN	A	${ip}
www	IN	A	${ip}
EOF

echo "COnfigurando el host de la zona...."

ZoneConfig="/etc/bind/named.conf.local"
echo "zone \"${dominio}\" {
	type master;
	file \"${ruta}\";
};" | sudo tee -a ${ZoneConfig}

echo "Verificacion final..."
sudo named-checkconf

sudo chown bind:bind ${ruta}

echo "Reiniciando el servicio del DNS...."
sudo systemctl restart bind9

echo "Servicio reiniciado."
sudo systemctl status bind9
