# Práctica: Configuración de Servidor DNS y FTPS (vsftpd)

* **Alumno:** Antonio Benitez Garcia
* **Asignatura:** Despliegue
* **Curso:** 2web-b

---

## 1. Configuración de Partida (DNS)

El primer paso consiste en configurar la máquina virtual `ns` (IP: `192.168.56.101`) como servidor DNS para el dominio `antonio.test` (en lugar de `example.com`) y para la zona de resolución inversa de la red `192.168.56.0/24`.

Esta configuración es crítica, ya que el servidor DNS debe ser capaz de resolver nombres como `ftp.antonio.test` para que el resto de la práctica funcione.

Capturas de confirmación:

  <img width="520" height="380" alt="Captura de pantalla 2025-11-04 233839" src="https://github.com/user-attachments/assets/2bdb4388-e6f6-438c-8ec5-71017380ae2a" />
  <img width="509" height="389" alt="Captura de pantalla 2025-11-04 234007" src="https://github.com/user-attachments/assets/57665e72-f96c-4900-b5bd-17e9e1d2b426" />
  <img width="504" height="376" alt="Captura de pantalla 2025-11-04 234039" src="https://github.com/user-attachments/assets/c5b076dd-b485-4e33-90fa-990adaf1a3d1" />

---

## 2. Uso del Cliente FTP Gráfico

Antes de montar nuestro propio servidor, se realiza una prueba de conexión a un servidor FTP público (`ftp.cica.es`) utilizando un cliente gráfico (FileZilla).

El objetivo es familiarizarse con el cliente, probando una conexión anónima, la descarga de un archivo de prueba y un intento (fallido) de subida.

Conexión a (`ftp.cica.es`):
<img width="1174" height="935" alt="Captura de pantalla 2025-11-04 235018" src="https://github.com/user-attachments/assets/11946e3f-6ded-43b7-8ee3-20b5f9b34534" />

Descarga de archivo (`check`):
  <img width="1176" height="934" alt="Captura de pantalla 2025-11-04 235111" src="https://github.com/user-attachments/assets/4bcb9fa2-94ae-422a-9f96-2298bca1263e" />
  <img width="552" height="90" alt="Captura de pantalla 2025-11-04 235123" src="https://github.com/user-attachments/assets/f7332a70-b8eb-48c0-90aa-1a22a08fdb2f" />

Subida de (`datos.txt`):

  <img width="566" height="250" alt="Captura de pantalla 2025-11-04 235206" src="https://github.com/user-attachments/assets/88d7d5f6-a33b-4b50-88f7-5abaabb2859f" />
  <img width="353" height="82" alt="Captura de pantalla 2025-11-04 235217" src="https://github.com/user-attachments/assets/e538e7f4-bc65-4d69-981c-fb8af1fb3cab" />

---

## 3. Instalación y Configuración de VSFTPD

Esta es la sección principal de la práctica, donde se instala y configura el servidor `vsftpd` en nuestra máquina Debian (`ns`).

### 3.1. Pasos Previos (Instalación y Usuarios)

Se realizan las siguientes tareas de preparación:
1.  **Instalación del paquete `vsftpd`**.
  <img width="556" height="140" alt="Captura de pantalla 2025-11-05 000329" src="https://github.com/user-attachments/assets/9cf95088-c4a7-4592-86be-ab732f7bc08b" />
  <img width="841" height="442" alt="punto 3 1" src="https://github.com/user-attachments/assets/c52cd2d2-ea80-41b9-aa1c-f756618ab6b5" />
   
2.  **Comprobación del usuario `ftp`** (en `/etc/passwd`) y su directorio home (`/srv/ftp`).
  <img width="383" height="30" alt="Captura de pantalla 2025-11-05 000619" src="https://github.com/user-attachments/assets/5ccef6ce-4416-4433-82ef-ce5b75baa1d2" />
  <img width="239" height="33" alt="Captura de pantalla 2025-11-05 000647" src="https://github.com/user-attachments/assets/62de75ae-43f2-4630-b481-382fc2ec83be" />
  <img width="344" height="32" alt="Captura de pantalla 2025-11-05 000850" src="https://github.com/user-attachments/assets/7d92dba5-e3da-472e-ac42-5438b6b2db78" />
  <img width="522" height="256" alt="Captura de pantalla 2025-11-05 001355" src="https://github.com/user-attachments/assets/944a175c-7b52-4379-8f32-52888e9d40e9" />

3.  **Comprobación del servicio** (con `systemctl status` y `ss -tlpn` para ver el puerto 21).
  <img width="713" height="234" alt="Captura de pantalla 2025-11-05 002308" src="https://github.com/user-attachments/assets/8edc32be-12bf-4de7-8130-37335281f5e0" />
  <img width="1544" height="137" alt="Captura de pantalla 2025-11-05 002447" src="https://github.com/user-attachments/assets/8ee5901a-a395-47d3-bb7d-a9af25cf75a2" />
  <img width="446" height="18" alt="Captura de pantalla 2025-11-05 002621" src="https://github.com/user-attachments/assets/e4718906-0507-4949-9d2d-f2a82325c891" />

4.  **Creación de usuarios locales** (`luis`, `maria`, `miguel`) con sus contraseñas.
   <img width="299" height="257" alt="Captura de pantalla 2025-11-05 003238" src="https://github.com/user-attachments/assets/0e79495d-f733-41fc-8731-5a19a3f8b8a3" />

5.  **Creación de ficheros de prueba** (ej: `luis1.txt`, `luis2.txt`, `maria1.txt`, etc.).
    <img width="429" height="71" alt="Captura de pantalla 2025-11-05 003416" src="https://github.com/user-attachments/assets/e62e9c68-bb77-42d3-b240-61ed60a5d31b" />

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
<img width="535" height="557" alt="Captura de pantalla 2025-11-05 010747" src="https://github.com/user-attachments/assets/45746cc0-091e-4c88-ad62-8579432fbe95" />
<img width="928" height="59" alt="Captura de pantalla 2025-11-05 011213" src="https://github.com/user-attachments/assets/580d5b86-9cff-4e1a-912a-47189c4a6b07" />
<img width="935" height="61" alt="Captura de pantalla 2025-11-05 011230" src="https://github.com/user-attachments/assets/bbb85475-5e03-4672-921c-660ba576f2e2" />

### 3.3. Pruebas de Conexión (FTP Inseguro)

**j. Reinicio y comprobación del servicio**

Tras guardar la configuración, se reinicia el servicio y se comprueba que está activo y escuchando en el puerto 21.
<img width="737" height="304" alt="Captura de pantalla 2025-11-05 011311" src="https://github.com/user-attachments/assets/5bf93595-51d6-42f9-8853-18204b38a360" />

---

**k. Conexión Anónima**

Se comprueba la secuencia de conexión y la aparición de los dos mensajes de bienvenida (pasos 'b' y 'c').
<img width="673" height="216" alt="Captura de pantalla 2025-11-05 011805" src="https://github.com/user-attachments/assets/b067064b-b16a-4bc6-a885-f0be08f4b773" />

---

**l. Conexión `maria` (NO Enjaulada)**

Se comprueba que `maria` puede conectarse y navegar libremente fuera de su home (ej: `cd /`).
<img width="566" height="838" alt="Captura de pantalla 2025-11-05 012247" src="https://github.com/user-attachments/assets/fd07e78a-c929-4306-9a2e-8d9fdd00c39b" />

---

**m. Conexión `luis` (SÍ Enjaulado)**

Se comprueba que `luis` está enjaulado en su home y solo puede ver sus propios archivos (`luis1.txt`, `luis2.txt`).
<img width="557" height="485" alt="Captura de pantalla 2025-11-05 012833" src="https://github.com/user-attachments/assets/f120109c-1f0d-40fd-82fc-7b7437b8729e" />

---

## 4. Configuración del Servidor VSFTPD Seguro (FTPS)

En esta sección final, se modifica la configuración del servidor para añadir cifrado SSL/TLS y convertirlo en un servidor FTPS.

### 4.1. Creación de Certificado SSL

Se genera un certificado SSL autofirmado (`antonio.test.pem`) usando `openssl` y se almacena en `/etc/ssl/certs/`.
<img width="1065" height="339" alt="Captura de pantalla 2025-11-05 121010" src="https://github.com/user-attachments/assets/5331f508-e130-4d7d-9073-4c4abd70db6e" />

### 4.2. Configuración de `vsftpd.conf` (SSL)

Se añaden las directivas para habilitar SSL, forzarlo para usuarios locales y prohibirlo para anónimos, además de la directiva de compatibilidad `require_ssl_reuse=NO`.

<img width="458" height="263" alt="Captura de pantalla 2025-11-05 121812" src="https://github.com/user-attachments/assets/ae623569-996f-4e6c-94d9-1313511fa703" />

### 4.3. Pruebas de Conexión (FTPS)

**1. Reinicio y comprobación del servicio**

Se reinicia el servicio y se comprueba que sigue `active (running)` y escuchando en el puerto 21.
<img width="703" height="290" alt="Captura de pantalla 2025-11-05 122050" src="https://github.com/user-attachments/assets/78e3bad4-52d7-4e69-8fdf-1cdf842dae10" />

---

**2. Conexión segura con `luis` (FileZilla)**

Se configura FileZilla para usar "Requerir FTP explícito sobre TLS" y se realiza una conexión autenticada con `luis`.
<img width="1112" height="495" alt="Captura de pantalla 2025-11-05 123959" src="https://github.com/user-attachments/assets/c65c4612-f5ec-4524-b42c-e22ac492a325" />
<img width="584" height="338" alt="Captura de pantalla 2025-11-05 124106" src="https://github.com/user-attachments/assets/3bebd675-fd48-4278-8c6b-70e9492ef9db" />

---

**3. Aceptación del certificado y descarga**

Se acepta el certificado autofirmado (advertencia esperada) y se comprueba la descarga segura de un archivo, verificando el icono del candado cerrado.
<img width="1186" height="494" alt="Captura de pantalla 2025-11-05 124439" src="https://github.com/user-attachments/assets/0140399a-95ce-4718-945c-61f6010964c9" />

---

**4. Intento de conexión segura anónima**

Se comprueba que el servidor **rechaza** la conexión (Error 530), cumpliendo la directiva `allow_anon_ssl=NO`.
<img width="535" height="31" alt="Captura de pantalla 2025-11-05 124750" src="https://github.com/user-attachments/assets/3c3f4ac3-3e13-464b-8239-ccf1d017f4a3" />
<img width="344" height="96" alt="Captura de pantalla 2025-11-05 124809" src="https://github.com/user-attachments/assets/4bafd35a-9024-4ee1-a141-da989daa9774" />

---

**5. Conexión segura con otro usuario (`maria`)**

Prueba final que combina seguridad y las reglas de `chroot` (se comprueba que `maria` sigue sin estar enjaulada, incluso en modo FTPS).
<img width="1179" height="936" alt="Captura de pantalla 2025-11-05 125908" src="https://github.com/user-attachments/assets/80d71424-c9fb-4379-b9ab-e87aafaa19e0" />
<img width="579" height="382" alt="Captura de pantalla 2025-11-05 125933" src="https://github.com/user-attachments/assets/f1bef96c-7fd7-49d1-b2a2-434d556fb796" />

---

### Práctica Finalizada
