#!/bin/bash

# Paso 1: Instalar Docker en Ubuntu
echo "Instalando Docker..."
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Paso 2: Descargar imagen oficial de Apache (httpd)
echo "Descargando imagen de Apache..."
docker pull httpd:latest

# Paso 3 y 4: Crear Dockerfile con modificación de index.html
echo "Creando imagen personalizada de Apache con index.html modificado..."
mkdir -p apache_custom
cat <<EOF > apache_custom/index.html
<html>
  <head><title>Servidor Apache Personalizado</title></head>
  <body><h1>¡Hola desde la imagen personalizada!</h1></body>
</html>
EOF

cat <<EOF > apache_custom/Dockerfile
FROM httpd:latest
COPY index.html /usr/local/apache2/htdocs/index.html
EOF

docker build -t apache_custom:1.0 apache_custom

# Paso 5: Crear red Docker para comunicación entre contenedores
echo "Creando red Docker personalizada para comunicación..."
docker network create app_network

# Crear contenedor Apache usando la nueva imagen personalizada
echo "Levantando contenedor Apache personalizado..."
docker run -dit --name apache_server --network app_network -p 8080:80 apache_custom:1.0

# Crear dos contenedores con PostgreSQL
echo "Levantando contenedores PostgreSQL..."
docker run -dit --name pg1 --network app_network \
  -e POSTGRES_PASSWORD=clave123 -e POSTGRES_USER=usuario1 -e POSTGRES_DB=bd1 \
  postgres:latest

docker run -dit --name pg2 --network app_network \
  -e POSTGRES_PASSWORD=clave123 -e POSTGRES_USER=usuario2 -e POSTGRES_DB=bd2 \
  postgres:latest

# Esperar a que PostgreSQL se inicie
echo "Esperando a que PostgreSQL se inicie..."
sleep 10

# Verificar conexión desde pg1 a pg2 usando psql
echo "Instalando cliente psql en pg1 para pruebas de conexión..."
docker exec pg1 apt update && docker exec pg1 apt install -y postgresql-client

echo "Probando conexión desde pg1 a pg2..."
docker exec pg1 bash -c "PGPASSWORD=clave123 psql -h pg2 -U usuario2 -d bd2 -c '\l'"

echo "Script completado."
