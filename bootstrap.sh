#!/bin/bash
# Script de aprovisionamiento para la configuración del servidor DNS (BIND9)
# Este script se ejecuta en la máquina virtual Debian 11 (servidor-dns)

echo "--- Aprovisionamiento de Servidor DNS (midominio.net) ---"

echo "--- 1. Actualizando el sistema ---"
# Actualizar la lista de paquetes
apt-get update -y

echo "--- 2. Instalando el servidor DNS (BIND9) ---"
# Instalar todos los paquetes requeridos: bind9, bind9utils, bind9-doc
apt-get install -y bind9 bind9utils bind9-doc

echo "--- 2.1. Desactivando IPv6 en BIND9 (/etc/default/named) ---"
# Modifica /etc/default/named para usar solo IPv4, según la práctica.
# Reemplaza la línea OPTIONS="" por OPTIONS="-u bind -4"
sed -i 's/OPTIONS=""/OPTIONS="-u bind -4"/g' /etc/default/named

echo "--- 3. Copiando archivos de configuración de zonas ---"

# La carpeta del proyecto está montada en /vagrant. 
# Copiamos los archivos de zona desde /vagrant/config/ a /etc/bind/
cp /vagrant/config/db.midominio.net /etc/bind/
cp /vagrant/config/db.192.168.56 /etc/bind/

# Copia el archivo de declaración de zonas (named.conf.local)
cp /vagrant/config/named.conf.local /etc/bind/

echo "--- 4. Aplicando permisos y reiniciando BIND9 ---"

# Asigna los permisos correctos a los nuevos archivos de zona
chown -R bind:bind /etc/bind/db.*

# Reinicia el servicio para que tome la nueva configuración (IPv4 y zonas)
systemctl restart bind9

echo "--- Aprovisionamiento de DNS completado. ---"