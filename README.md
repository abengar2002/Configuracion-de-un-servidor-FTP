# Práctica: Configuración de Servidor DNS y FTPS (vsftpd)

* **Alumno:** Antonio Benitez Garcia
* **Asignatura:** Despliegue
* **Curso:** 2web-b

---

## 1. Configuración de Partida (DNS)

El primer paso consiste en configurar la máquina virtual `ns` (IP: `192.168.56.101`) como servidor DNS para el dominio `antonio.test` (en lugar de `example.com`) y para la zona de resolución inversa de la red `192.168.56.0/24`.

Esta configuración es crítica, ya que el servidor DNS debe ser capaz de resolver nombres como `ftp.antonio.test` para que el resto de la práctica funcione.

---

## 2. Uso del Cliente FTP Gráfico

Antes de montar nuestro propio servidor, se realiza una prueba de conexión a un servidor FTP público (`ftp.cica.es`) utilizando un cliente gráfico (FileZilla).

El objetivo es familiarizarse con el cliente, probando una conexión anónima, la descarga de un archivo de prueba y un intento (fallido) de subida.

---

## 3. Instalación y Configuración de VSFTPD

Esta es la sección principal de la práctica, donde se instala y configura el servidor `vsftpd` en nuestra máquina Debian (`ns`).

### 3.1. Pasos Previos (Instalación y Usuarios)

Se realizan las siguientes tareas de preparación:
1.  **Instalación del paquete `vsftpd`**.
2.  **Comprobación del usuario `ftp`** (en `/etc/passwd`) y su directorio home (`/srv/ftp`).
3.  **Comprobación del servicio** (con `systemctl status` y `ss -tlpn` para ver el puerto 21).
4.  **Creación de usuarios locales** (`luis`, `maria`, `miguel`) con sus contraseñas.
5.  **Creación de ficheros de prueba** (ej: `luis1.txt`, `luis2.txt`, `maria1.txt`, etc.).

### 3.2. Configuración de `/etc/vsftpd.conf`

Se modifica el archivo de configuración para cumplir los siguientes requisitos:

* **(a)** Modo *standalone* y solo IPv4.
* **(b)** Mensaje de bienvenida (`ftpd_banner`).
* **(c)** Mensaje post-login para anónimos (`dirmessage_enable`).
* **(d)** Timeout de inactividad de 720 segundos.
* **(e)** Límite de 5 MB/s para usuarios locales.
* **(f)** Límite de 2 MB/s para anónimos.
* **(g)** Permisos de anónimos (solo descarga).
* **(h)** Permisos de locales (descarga y subida).
* **(i)** Enjaulamiento (`chroot`) para todos, excepto para `maria` (usando `chroot_list`).
* **(Extra)** Se añade `allow_writeable_chroot=YES` para solucionar el error `500 OOPS` al enjaular.

### 3.3. Pruebas de Conexión (FTP Inseguro)

**j. Reinicio y comprobación del servicio**

Tras guardar la configuración, se reinicia el servicio y se comprueba que está activo y escuchando en el puerto 21.

---

**k. Conexión Anónima**

Se comprueba la secuencia de conexión y la aparición de los dos mensajes de bienvenida (pasos 'b' y 'c').

---

**l. Conexión `maria` (NO Enjaulada)**

Se comprueba que `maria` puede conectarse y navegar libremente fuera de su home (ej: `cd /`).

---

**m. Conexión `luis` (SÍ Enjaulado)**

Se comprueba que `luis` está enjaulado en su home y solo puede ver sus propios archivos (`luis1.txt`, `luis2.txt`).

---

## 4. Configuración del Servidor VSFTPD Seguro (FTPS)

En esta sección final, se modifica la configuración del servidor para añadir cifrado SSL/TLS y convertirlo en un servidor FTPS.

### 4.1. Creación de Certificado SSL

Se genera un certificado SSL autofirmado (`antonio.test.pem`) usando `openssl` y se almacena en `/etc/ssl/certs/`.

### 4.2. Configuración de `vsftpd.conf` (SSL)

Se añaden las directivas para habilitar SSL, forzarlo para usuarios locales y prohibirlo para anónimos, además de la directiva de compatibilidad `require_ssl_reuse=NO`.

### 4.3. Pruebas de Conexión (FTPS)

**1. Reinicio y comprobación del servicio**

Se reinicia el servicio y se comprueba que sigue `active (running)` y escuchando en el puerto 21.

---

**2. Conexión segura con `luis` (FileZilla)**

Se configura FileZilla para usar "Requerir FTP explícito sobre TLS" y se realiza una conexión autenticada con `luis`.

---

**3. Aceptación del certificado y descarga**

Se acepta el certificado autofirmado (advertencia esperada) y se comprueba la descarga segura de un archivo, verificando el icono del candado cerrado.

---

**4. Intento de conexión segura anónima**

Se comprueba que el servidor **rechaza** la conexión (Error 530), cumpliendo la directiva `allow_anon_ssl=NO`.

---

**5. Conexión segura con otro usuario (`maria`)**

Prueba final que combina seguridad y las reglas de `chroot` (se comprueba que `maria` sigue sin estar enjaulada, incluso en modo FTPS).

---

### Práctica Finalizada