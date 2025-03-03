#!/bin/bash

#Actualizando el sistema
apt-get update -y
apt-get upgrade -y

#Instalando el servidor FTP
apt-get install vsftpd -y

#Creando carpeta raiz
mkdir /home/ftp
mkdir /home/ftp/Reprobados
mkdir /home/ftp/Recursadores
mkdir /home/ftp/Publico

#Asingando permisos
chmod 777 /home/ftp/Reprobados
chmod 777 /home/ftp/Recursadores
chmod 777 /home/ftp/Publico

#Configurando el servidor FTP
echo "anonymous_enable=YES" >> /etc/vsftpd.conf
echo "local_enable=YES" >> /etc/vsftpd.conf
echo "write_enable=YES" >> /etc/vsft
echo "chroot_local_user=YES" >> /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf

#Reiniciando el servidor FTP
systemctl restart vsftpd

#Mostrando el servicio corriendo
systemctl status vsftpd