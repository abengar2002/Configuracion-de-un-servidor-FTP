# Práctica de Servidor DNS (BIND9) con Vagrant

Este proyecto documenta la configuración de un servidor DNS autoritativo utilizando BIND9 en una máquina virtual Debian 11, aprovisionada completamente mediante Vagrant.

---

## 1. Instrucciones (Sección 1.)

El objetivo de la práctica es configurar un servidor DNS siguiendo las instrucciones, documentar cada paso, preparar el despliegue automático con Vagrant, registrar cada cambio en GitHub, y al final, contestar algunas preguntas.

### 1.1. Control de versiones

Se creo un respositorio privado junto a un README.md y un .gitignore para el directorio .vagrant/

### 1.2. Documentación

Se creo una carpeta /doc en el cual se añadió un README.md para poder ir dando los pasos de las configuraciones poco a poco

### 1.3. Infraestructura como código

Se configuró el entorno de virtualización para automatizar el despliegue del servidor DNS.

**`Vagrantfile` (Configuración Esencial)**

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.hostname = "servidor-dns"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.provision "shell", path: "bootstrap.sh"
end
```

## 2. Instalación de Servidor DNS (Sección 3.)

Para la implementación, se utilizó **BIND9**, que es el estándar de facto para servidores DNS en plataformas Linux y Unix (también conocido como `named`). Es fundamental asegurarse de que el archivo `/etc/hosts` no contenga entradas que puedan interferir con la resolución del nuevo servidor DNS.

### 2.1. Paquetes Requeridos

La instalación de BIND9 requirió los siguientes paquetes de los repositorios oficiales:

* `bind9`
* `bind9utils`
* `bind9-doc`

### 2.2. Aprovisionamiento Automático (`bootstrap.sh`)

La instalación se llevó a cabo automáticamente mediante el script de Vagrant `bootstrap.sh`, asegurando que el proceso se ejecute cada vez que se levanta la máquina:

```bash
apt-get update -y
apt-get install -y bind9 bind9utils bind9-doc
```

## 3. Configuración del Servidor (Sección 4.)

### 3.1. Configuración Principal y Restricción a IPv4

Primero, se modificó el archivo `/etc/default/named` para obligar a BIND a escuchar únicamente en IPv4: OPTIONS="-u bind -4"
Este cambio es crucial, ya que solo utilizaremos IPv4 en la práctica.

El archivo principal de configuración es `/etc/bind/named.conf`, el cual solo agrupa las referencias a los tres archivos de configuración que debemos modificar:

* `/etc/bind/named.conf.options`
* `/etc/bind/named.conf.local`
* `/etc/bind/named.conf.default-zones`

### 3.2. Configuración `named.conf.options`

Se editó este archivo para implementar medidas de seguridad y correcciones. Se creó una **Lista de Control de Acceso (ACL)** llamada `confiables` para la red privada `192.168.56.0/24`.

**Contenido del archivo `named.conf.options`:**

```dns
acl confiables { 192.168.56.0/24; };
options {
    directory "/var/cache/bind";
    listen-on port 53 { 192.168.56.10; }; // Escucha solo en la IP privada
    allow-query { any; };
    allow-recursion { confiables; }; // Recursividad solo para la red privada
    allow-transfer { none; }; // Denegar transferencia de zona
    recursion yes;

    // forwarders { 8.8.8.8; }; // Si se usaran servidores externos

    dnssec-validation auto;

    // Deshabilita IPv6 (ya configurado en /etc/default/named)
    // listen-on-v6 { none; };
};  
```

### 3.3. Configuración `named.conf.local` (Declaración de Zonas)

Se utilizó este archivo para declarar las nuevas zonas maestra (autoritativas):

* **Zona Directa:** `midominio.net` (reemplazando `antonio.test` de la práctica).
* **Zona Inversa:** `56.168.192.in-addr.arpa` (reemplazando `X.168.192.in-addr.arpa`).

El archivo `named.conf.local` se configuró de la siguiente manera para declarar estas zonas:

```dns
// Zona Directa
zone "midominio.net" {
    type master;
    file "/etc/bind/db.midominio.net";
};

// Zona Inversa
zone "56.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.56";
};
```

### 3.4. Archivos de Zona (Registros)

Se crearon los archivos maestros de zona en el directorio `/etc/bind/`:

* **Zona Directa (`db.midominio.net`):** Se creó el archivo con el registro **SOA** (incluyendo el administrador `antonio.midominio.net.`), los registros **NS**, y los registros **A** para la resolución de nombres a IP.
* **Zona Inversa (`db.192.168.56`):** Se creó el archivo con el registro **SOA** y los registros **PTR** para mapear la IP `192.168.56.10` al nombre `servidor-dns.midominio.net.`.

El contenido de estos archivos se basó en la estructura proporcionada por la práctica.

**Ejemplo de estructura de Zona Directa (`db.midominio.net`):**

```dns
$TTL 86400
@ IN SOA servidor-dns.midominio.net. antonio.midominio.net. (
         2025101401 ; Serial (AñoMesDíaVersión)
         3600       ; Refresh
         1800       ; Retry
         604800     ; Expire
         86400 )    ; Negative Cache TTL
; Registros NS y A
@ IN NS servidor-dns.midominio.net.
servidor-dns IN A 192.168.56.10
www IN A 192.168.56.10
```

### 3.5. Comprobación de las configuraciones (Sección 4.5)

Antes de reiniciar el servicio, se comprobó la sintaxis de la configuración de las zonas usando `named-checkzone`:

* **Zona Directa:** `named-checkzone antonio.test /var/lib/bind/antonio.test.dns` (usando el nombre de ejemplo de la práctica).
* **Zona Inversa:** `named-checkzone X.168.192.in-addr.arpa /var/lib/bind/antonio.test.rev` (usando el nombre de ejemplo de la práctica).

Se obtuvo una respuesta de **OK** y las zonas fueron cargadas correctamente al reiniciar el servicio.

Después, se verificó que el cliente DNS estuviera correctamente configurado para usar la IP del servidor DNS (`192.168.56.10`) como principal.

***

## 4. Comprobación de las Resoluciones y Consultas (Sección 5. y 6.)

### 4.1. Estado del Servicio BIND9

Se confirmó que el servicio está activo y funcionando.

```bash
systemctl status bind9
```

### 4.2. Comprobaciones con dig y nslookup

**dig:**


**nslookup:**

## 5. Cuestiones Finales (Sección 7.)

### 1. ¿Qué pasará si un cliente de una red diferente a la tuya intenta hacer uso de tu DNS de alguna manera, le funcionará? ¿Por qué? ¿En qué parte de la configuración puede verse?

**Respuesta:** No, **no le funcionará**. La configuración en `named.conf.options` restringe la **recursividad** a la `acl confiables` (`192.168.56.0/24`) por motivos de seguridad, evitando el abuso del servicio por parte de clientes externos.

### 2. ¿Por qué tenemos que permitir las consultas recursivas en la configuración?

**Respuesta:** Se permite la recursividad para que nuestro servidor actúe como **servidor primario** para nuestros clientes internos, resolviendo consultas externas por ellos.

### 3. El servidor DNS que acabáis de montar, ¿es autoritativo? ¿Por qué?

**Respuesta:** Sí, es **autoritativo** para la zona **`midominio.net`**. Es autoritativo porque contiene el archivo maestro de esa zona.

### 4. ¿Dónde podemos encontrar la directiva `$ORIGIN` y para qué sirve?

**Respuesta:** En los **archivos de zona**. Sirve para establecer el **nombre de dominio base** de la zona y permitir usar nombres relativos.

### 5. ¿Una zona es idéntico a un dominio?

**Respuesta:** No, no son idénticos. El **dominio** es la entidad lógica, y la **zona** es el archivo administrativo que contiene todos los registros DNS.

### 6. ¿Cuántos servidores raíz existen?

**Respuesta:** Existen **13 direcciones lógicas (nombres)** de servidores raíz, implementadas a través de **cientos de instancias físicas** (*anycast*).

### 7. ¿Qué es una consulta iterativa de referencia?

**Respuesta:** Es aquella en la que un servidor DNS **responde con la dirección de otro servidor DNS** que está más cerca de la respuesta, obligando al cliente a realizar la siguiente pregunta.

### 8. En una resolución inversa, ¿a qué nombre se mapearía la dirección IP `172.16.34.56`?

**Respuesta:** La dirección IP `172.16.34.56` se mapearía al nombre de zona **`56.34.16.172.in-addr.arpa`**.