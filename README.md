# Práctica: Configuración de Servidor DNS y FTPS (vsftpd)

* **Alumno:** Antonio Benitez Garcia
* **Asignatura:** Despliegue
* **Curso:** 2web-b

---

## 1. Configuración de Partida (DNS)

[cite_start]El primer paso consiste en configurar la máquina virtual `ns` (IP: `192.168.56.101`) como servidor DNS para el dominio `antonio.test` (en lugar de `example.com`) y para la zona de resolución inversa de la red `192.168.56.0/24`. [cite: 5, 8, 12, 13]

[cite_start]Esta configuración es crítica, ya que el servidor DNS debe ser capaz de resolver nombres como `ftp.antonio.test` para que el resto de la práctica funcione. [cite: 16]

---

## 2. Uso del Cliente FTP Gráfico

[cite_start]Antes de montar nuestro propio servidor, se realiza una prueba de conexión a un servidor FTP público (`ftp.cica.es`) utilizando un cliente gráfico (FileZilla). [cite: 27, 31]

[cite_start]El objetivo es familiarizarse con el cliente, probando una conexión anónima, la descarga de un archivo de prueba [cite: 31, 32] [cite_start]y un intento (fallido) de subida. [cite: 34]

---

## 3. Instalación y Configuración de VSFTPD

[cite_start]Esta es la sección principal de la práctica, donde se instala y configura el servidor `vsftpd` en nuestra máquina Debian (`ns`). [cite: 36, 39]

### 3.1. Pasos Previos (Instalación y Usuarios)

Se realizan las siguientes tareas de preparación:
1.  [cite_start]**Instalación del paquete `vsftpd`**. [cite: 41]
2.  [cite_start]**Comprobación del usuario `ftp`** (en `/etc/passwd`) y su directorio home (`/srv/ftp`). [cite: 42, 43, 44]
3.  [cite_start]**Comprobación del servicio** (con `systemctl status` [cite: 46] [cite_start]y `ss -tlpn` para ver el puerto 21 [cite: 47]).
4.  [cite_start]**Creación de usuarios locales** (`luis`, `maria`, `miguel`) con sus contraseñas. [cite: 49, 51, 52]
5.  [cite_start]**Creación de ficheros de prueba** (ej: `luis1.txt`, `luis2.txt`, `maria1.txt`, etc.). [cite: 53, 54, 55, 56, 57]

### 3.2. Configuración de `/etc/vsftpd.conf`

[cite_start]Se modifica el archivo de configuración para cumplir los siguientes requisitos[cite: 58, 66]:

* [cite_start]**(a)** Modo *standalone* y solo IPv4. [cite: 67]
* [cite_start]**(b)** Mensaje de bienvenida (`ftpd_banner`). [cite: 68]
* [cite_start]**(c)** Mensaje post-login para anónimos (`dirmessage_enable`). [cite: 70]
* [cite_start]**(d)** Timeout de inactividad de 720 segundos. [cite: 72]
* [cite_start]**(e)** Límite de 5 MB/s para usuarios locales. [cite: 73]
* [cite_start]**(f)** Límite de 2 MB/s para anónimos. [cite: 74]
* [cite_start]**(g)** Permisos de anónimos (solo descarga). [cite: 75]
* [cite_start]**(h)** Permisos de locales (descarga y subida). [cite: 76]
* [cite_start]**(i)** Enjaulamiento (`chroot`) para todos, excepto para `maria` (usando `chroot_list`). [cite: 79]
* **(Extra)** Se añade `allow_writeable_chroot=YES` para solucionar el error `500 OOPS` al enjaular.

### 3.3. Pruebas de Conexión (FTP Inseguro)

**j. Reinicio y comprobación del servicio**

[cite_start]Tras guardar la configuración, se reinicia el servicio y se comprueba que está activo y escuchando en el puerto 21. [cite: 80]

---

**k. Conexión Anónima**

[cite_start]Se comprueba la secuencia de conexión y la aparición de los dos mensajes de bienvenida (pasos 'b' y 'c'). [cite: 81]

---

**l. Conexión `maria` (NO Enjaulada)**

[cite_start]Se comprueba que `maria` puede conectarse y navegar libremente fuera de su home (ej: `cd /`). [cite: 82]

---

**m. Conexión `luis` (SÍ Enjaulado)**

[cite_start]Se comprueba que `luis` está enjaulado en su home y solo puede ver sus propios archivos (`luis1.txt`, `luis2.txt`). [cite: 83]

---

## 4. Configuración del Servidor VSFTPD Seguro (FTPS)

[cite_start]En esta sección final, se modifica la configuración del servidor para añadir cifrado SSL/TLS y convertirlo en un servidor FTPS. [cite: 87]

### 4.1. Creación de Certificado SSL

[cite_start]Se genera un certificado SSL autofirmado (`antonio.test.pem`) usando `openssl` y se almacena en `/etc/ssl/certs/`. [cite: 88, 89]

### 4.2. Configuración de `vsftpd.conf` (SSL)

[cite_start]Se añaden las directivas para habilitar SSL, forzarlo para usuarios locales y prohibirlo para anónimos [cite: 90][cite_start], además de la directiva de compatibilidad `require_ssl_reuse=NO`. [cite: 92]

### 4.3. Pruebas de Conexión (FTPS)

**1. Reinicio y comprobación del servicio**

[cite_start]Se reinicia el servicio y se comprueba que sigue `active (running)` y escuchando en el puerto 21. [cite: 93]

---

**2. Conexión segura con `luis` (FileZilla)**

[cite_start]Se configura FileZilla para usar "Requerir FTP explícito sobre TLS" y se realiza una conexión autenticada con `luis`. [cite: 94]

---

**3. Aceptación del certificado y descarga**

[cite_start]Se acepta el certificado autofirmado (advertencia esperada) [cite: 95] [cite_start]y se comprueba la descarga segura de un archivo [cite: 96][cite_start], verificando el icono del candado cerrado. [cite: 97]

---

**4. Intento de conexión segura anónima**

[cite_start]Se comprueba que el servidor **rechaza** la conexión (Error 530), cumpliendo la directiva `allow_anon_ssl=NO`. [cite: 98]

---

**5. Conexión segura con otro usuario (`maria`)**

[cite_start]Prueba final que combina seguridad y las reglas de `chroot` (se comprueba que `maria` sigue sin estar enjaulada, incluso en modo FTPS). [cite: 99]

---

### Práctica Finalizada