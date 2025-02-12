#!/bin/bash



#Actualizar el sistema
apt-get update -y
apt-get upgrade -y


#Instalar Bind9
apt-get install bind9 bind9utils

#validacion de ip



#COnfiguracion Zona Directa
dominio=""
read -p "Introduzca el dominio: " dominio

ip=""
read -p "introduzca la ip: " ip

sudo mkdir -p /etc/bind/zones
sudo chown bind:bind /etc/bind/zones

nombrearchivozona="db.${dominio}"
ruta="etc/bind/zones/${nombrearchivozona}"

cat > ${ruta} << EOF
\STTL	86401
@	IN	SOA	ns1.${dominio}.	admin.${dominio}. (
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

ZoneConfig="/etc/bind/named.conf.local"
echo "zone \"${dominio}\"{
	type master;
	file\"${ruta}\";
};" | sudo tee -a ${ZoneConfig}

sudo named-checkconf

sudo chown bind:bind ${ruta}

sudo systemctl restart bind9

systemctl status bind9

