#!/bin/bash
# setup_apache.sh
# Automatiza la configuración de Apache2, módulos, virtual hosts y certificados.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash setup_apache.sh)

clear

# ----------------------------------------------------------------------
# CARGA DE VARIABLES Y FUNCIONES COMUNES A LOS SCRIPTS DE AUTOMATIZACIÓN
# ----------------------------------------------------------------------
echo -e "\n"
echo -e "Ejecutando script setup_apache.sh."
echo -e "\n"

echo -e "${C_SUBTITULO}--- Cargando variables y funciones comunes para la instalación ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------------${RESET}"
echo -e "\n"

echo -e "Leyendo functions.sh y config_vars.sh."
echo -e "\n"

# 1. CARGAR LIBRERÍA DE FUNCIONES (Contiene variables de color y read_prompt)
source "./functions.sh"

# 2. CARGAR VARIABLES DE CONFIGURACIÓN
CONFIG_FILE="./config_vars.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo -e "${C_EXITO}☑️ Variables de configuración cargadas.${RESET}"
else
    # Usar variables de color si están definidas en functions.sh
    echo -e "${C_ERROR}❌ ERROR: Archivo de configuración ($CONFIG_FILE) no encontrado. Saliendo.${RESET}"
    exit 1
fi

echo -e "\n\n"
echo -e "${C_PRINCIPAL}================================================================="
echo -e "${C_PRINCIPAL}--- FASE 2: SERVIDOR WEB Y CERTIFICADOS SSL${RESET} ${CIANO}(setup_apache.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}=================================================================${RESET}"


if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n"
    echo -e "${C_ERROR}❌ ADVERTENCIA: Este script debe ejecutarse con ${RESET} ${C_INFO}'sudo bash setup_apache.sh'${RESET} ${C_ERROR}para modificar las tareas programadas en crontab.${RESET}"
    sleep 3
fi


# ----------------------------------------------------------------------
# 1. INSTALACIÓN Y CONFIGURACIÓN DE SEGURIDAD
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}==============================================================="
echo -e "${C_CAPITULO}--- 1. INSTALACIÓN DE SERVIDOR Y CONFIGURACIÓN DE SEGURIDAD ---"
echo -e "${C_CAPITULO}===============================================================${RESET}"
echo -e "\n"

# 1.1 Instalación de Servidor Apache, WSGI, UFW y Certbot

echo -e "${C_SUBTITULO}--- 1.1 Instalación de Servidor Apache, WSGI, UFW y Certbot ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------------------${RESET}"

echo -e "${C_INFO}ℹ️ Actualizando la lista de paquetes (apt-get update)...${RESET}"
apt-get update > /dev/null

# Instalar el servidor Apache, módulo WSGI y herramientas de seguridad/certificados
echo -e "${C_INFO}ℹ️ Instalando dependencias: Apache, WSGI, UFW, Certbot...${RESET}"
echo -e "\n"

# -----------------------------------------------------------------
# INSTALACIÓN DEL SERVIDOR APACHE Y MOD-WSGI
# -----------------------------------------------------------------
APT_DESC="Servidor Apache y mod-wsgi"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y apache2 libapache2-mod-wsgi-py3
check_install "$APT_DESC"

# -----------------------------------------------------------------
# INSTALACIÓN DEL CORTAFUEGOS UFW
# -----------------------------------------------------------------
APT_DESC="Cortafuegos UFW"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y ufw
check_install "$APT_DESC"

# -----------------------------------------------------------------
# INSTALACIÓN DEL CERTBOT Y SU INTEGRACIÓN CON EL SERVIDOR APACHE
# -----------------------------------------------------------------
APT_DESC="Certbot y su integración con el servidor Apache"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y certbot python3-certbot-apache
check_install "$APT_DESC"

echo -e "\n"
echo -e "${C_EXITO}✅ El servidor Apache y sus complementos se han instalado correctamente.${RESET}"
echo -e "\n"
sleep 3


# 1.2 Configuración del Firewall UFW

echo -e "${C_SUBTITULO}--- 1.2 Configurando Firewall (UFW) ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------${RESET}"

# Permitir OpenSSH (para no perder el acceso)
ufw allow OpenSSH > /dev/null
echo -e "${C_EXITO}✅ Permitir OpenSSH.${RESET}"

# Permitir tráfico web (Apache Full: 80 y 443)
ufw allow "Apache Full" > /dev/null
echo -e "${C_EXITO}✅ Permitir tráfico web (Apache Full: 80 y 443).${RESET}"
echo -e "\n"

# Habilitar el firewall
ufw --force enable

#GESTIONAR ESTA SALIDA PARA MOSTRAR UN MENSAJE U OTRO DESPUES DEL STATUS
ufw status

echo -e "\n"
echo -e "${C_EXITO}✅ Firewall UFW habilitado, permitiendo tráfico SSH y Apache Full (80/443).${RESET}"
sleep 3


# ----------------------------------------------------------------------
# 2. HABILITACIÓN DE MÓDULOS Y GENERACIÓN DE CERTIFICADO (INTERACTIVO)
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}========================================================================="
echo -e "${C_CAPITULO}--- 2. CONFIGURACIÓN DE MÓDULOS Y GENERACIÓN DE CERTIFICADO (SSL/TLS) ---"
echo -e "${C_CAPITULO}=========================================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 2.1 Habilitación de Módulos de Apache ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------${RESET}"

a2enmod wsgi ssl headers rewrite > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al habilitar módulos de Apache (wsgi, ssl, headers, rewrite).${RESET}"
	echo -e "\n"
    exit 1
fi
echo -e "${C_EXITO}✅ Módulos habilitados: wsgi, ssl, headers, rewrite.${RESET}"
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 2.2 LIMPIEZA DE VARIABLES Y DEFINICIÓN DE PARÁMETROS DE CERTIFICADO
# ----------------------------------------------------------------------

echo -e "${C_SUBTITULO}--- 2.2 Solicitud y Validación de Parámetros ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------${RESET}"

VENV_PATH="$FULL_PATH/venv"
WSGI_PATH="$FULL_PATH/aula/wsgi.py"

# 1. Quitar acentos y caracteres especiales (usando iconv, asumiendo su disponibilidad)
# 2. Reemplazar espacios por guiones bajos.
# 3. Eliminar cualquier carácter que no sea alfanumérico o guion bajo, por seguridad.
LOCALITAT_CLEAN=$(echo "$LOCALITAT" | iconv -t ascii//TRANSLIT | tr ' ' '_')
LOCALITAT_CLEAN=$(echo "$LOCALITAT_CLEAN" | sed 's/[^a-zA-Z0-9_]//g')

read_prompt "Introduce el correo del administrador (por defecto: juan@xtec.cat): " SERVER_ADMIN "juan@xtec.cat"

echo -e "${C_EXITO}✅ Parámetros de seguridad definidos.${RESET}"
echo -e "\n"
sleep 3


echo -e "${C_SUBTITULO}--- 2.3 Asegurando la correcta configuración del archivo apache2.conf para prevenir errores de Certbot (ServerName global) ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------------------------------------------------------------------------${RESET}"

# Se añade la directiva ServerName al archivo de configuración principal de Apache.
APACHE_CONF="/etc/apache2/apache2.conf"

# 1. LIMPIEZA PREVENTIVA
# Elimina cualquier línea incompleta 'ServerName ' que pudo fallar antes,
# lo que soluciona el error de sintaxis del "ServerName" sin argumento.
sudo sed -i '/^ServerName *$/d' "$APACHE_CONF"

# 2. VERIFICACIÓN Y ADICIÓN IDEMPOTENTE
# Verifica si la directiva ServerName ya existe con el argumento correcto.
if ! grep -q "^ServerName $DOMAIN_CLEAN" "$APACHE_CONF"; then

    # Se añade solo si NO existe.
    echo "ServerName $DOMAIN_CLEAN" | sudo tee -a "$APACHE_CONF" > /dev/null

    echo -e "${C_EXITO}✅ Directiva 'ServerName $DOMAIN_CLEAN' añadida a $APACHE_CONF (Limpieza automática OK).${RESET}"
else
    echo -e "${C_INFO}ℹ️ La directiva 'ServerName $DOMAIN_CLEAN' ya existe en $APACHE_CONF. No se realizaron cambios.${RESET}"
fi
echo -e "\n"
sleep 3


# ----------------------------------------------------------------------
# 2.4 ELECCIÓN Y GENERACIÓN DE CERTIFICADOS
# ----------------------------------------------------------------------

echo -e "${C_SUBTITULO}--- 2.4 Generación y Elección de Certificados SSL/TLS ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------${RESET}"

# Variables de ruta de certificados
CERT_KEY="/etc/ssl/private/$PROJECT_FOLDER-selfsigned.key"
CERT_CRT="/etc/ssl/certs/$PROJECT_FOLDER-selfsigned.crt"

if [[ "$INSTALL_TYPE_LOWER" == "pub" ]]; then

    echo -e "${C_INFO}-> Generando certificado Self-Signed TEMPORAL para $DOMAIN_CLEAN${RESET}"
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout "$CERT_KEY" \
		-out "$CERT_CRT" \
		-subj "/C=ES/ST=Catalonia/L=$LOCALITAT_CLEAN/O=$PROJECT_FOLDER/CN=$DOMAIN_CLEAN" > /dev/null 2>&1

	# Verificar la generación (la comprobación es CRÍTICA)
	if [ $? -ne 0 ] || [ ! -s "$CERT_CRT" ]; then
        echo -e "${C_ERROR}❌ ERROR CRÍTICO: Fallo al generar el certificado SSL temporal...${RESET}"
        echo -e "\n"
        exit 1
    fi
    echo -e "${C_EXITO}✅ Certificado Self-Signed TEMPORAL generado y listo como marcador de posición.${RESET}"
    sleep 3

	# ----------------------------------------------------------------------
	# Mensaje informativo sobre la elección del certificado
	# ----------------------------------------------------------------------
	echo -e "\n"
	echo -e "${C_INFO}--- Tipos de Certificados SSL/TLS ---${RESET}"
	echo -e "La aplicación necesita un certificado para habilitar la conexión segura (HTTPS/SSL) del navegador, en caso contrario mostrará un error de confianza."
	echo -e "\n"
	echo -e "${C_SUBTITULO}1. Certificado Autofirmado (Self-Signed):${RESET}"
	echo -e "   - Son generados localmente y son ideales para ${NEGRITA}entornos de desarrollo (test) o redes internas a las que no accederá desde el exterior (internet).${RESET}"
	echo -e "   - ${C_ERROR}Advertencia:${RESET} Los navegadores web mostrarán una ${NEGRITA}alerta de seguridad${RESET} al no ser emitidos por una Autoridad de Certificación reconocida."
	echo -e "\n"
	echo -e "${C_SUBTITULO}2. Certificado Válido (Let's Encrypt):${RESET}"
	echo -e "   - Son certificados ${NEGRITA}reconocidos, válidos y gratuitos${RESET}, adecuados para ${NEGRITA}entornos de producción.${RESET}"
	echo -e "   - ${C_EXITO}Requisito:${RESET} Solo se pueden obtener si el servidor tiene un ${NEGRITA}nombre de dominio o subdominio real${RESET} que apunta correctamente a su IP pública."
	echo -e "\n"

	echo -e "${C_INFO}⚠️ PRE-REQUISITO: Para Let's Encrypt, el dominio '$DOMAIN_CLEAN' (y www.) debe apuntar a la IP pública del servidor.${RESET}"

	read_prompt "¿Desea instalar un certificado Let's Encrypt (LE) o un certificado Autofirmado (AUTO)? (LE/AUTO - Enter para AUTO): " CERT_TYPE "AUTO"
	CERT_TYPE_LOWER=$(echo "$CERT_TYPE" | tr '[:upper:]' '[:lower:]')

	if [[ "$CERT_TYPE_LOWER" == "le" ]] || [[ "$CERT_TYPE_LOWER" == "letsencrypt" ]]; then

		# LÓGICA CERTBOT (Let's Encrypt)
		echo -e "${C_INFO}ℹ️ Ha seleccionado Let's Encrypt. La ejecución interactiva se realizará después de crear el archivo de configuración VHost del servidor Apache.${RESET}"
		echo -e "${C_INFO}   El certificado autofirmado TEMPORAL será reemplazado por el de Let's Encrypt.${RESET}"

		else

		# LÓGICA CERTIFICADO AUTOFIRMADO (Self-Signed)
		echo -e "${C_INFO}-> Convirtiendo el certificado Self-Signed creado temportalmente en permanente para $DOMAIN_CLEAN${RESET}"
		echo -e "${C_INFO}⚠️ Advertencia: Los navegadores web mostrarán un mensaje de no confianza...${RESET}"
		sleep 3
	fi
else
    # Entorno INTERNO: NO se genera ningún certificado.
    echo -e "${C_INFO}ℹ️ Entorno INTERNO seleccionado. Se omite la generación de certificados SSL.${RESET}"
    # Definimos la variable a 'int' para la lógica posterior (VHost/Certbot)
    CERT_TYPE_LOWER="int" 
    sleep 3
fi

# ----------------------------------------------------------------------
# FUNCIÓ OPCIONAL: INSTAL·LACIÓ DEL CATCH-ALL (zzz-catchall.conf)
# ----------------------------------------------------------------------

# Argument: $1 - 'yes' o 'no' per instal·lar
setup_catchall() {
    if [ "$1" != "yes" ]; then
        echo "⏭️ Instal·lació de Catch-all no sol·licitada. Saltant."
        return 0
    fi

    echo -e "\n"
    echo "⚙️ Instal·lant Virtual Host 'Catch-all' (zzz-catchall.conf) per bloquejar tràfic no desitjat (flood control)."

    # 1. Crear el directori per al DocumentRoot buit (requisit de l'Apache)
    sudo mkdir -p /var/www/catchall

    # 2. Crear el fitxer de configuració zzz-catchall.conf
    # NOTA: Utilitzem ServerName _ i ServerAlias * per atrapar tot el tràfic no reclamat
    sudo tee /etc/apache2/sites-available/zzz-catchall.conf > /dev/null <<EOT
# --- CATCH-ALL PER TRÀFIC NO RECONEGUT (zzz-catchall.conf) ---
# Aquest host es carrega a la fi (zzz) per capturar el tràfic que cap altre VirtualHost ha reclamat.
# Això evita que els bots consumeixin recursos de l'aplicació Django i enviïn correus d'error.

## 1. TRAFIC HTTP (80)
<VirtualHost *:80>
    ServerName _
    ServerAlias *
    DocumentRoot /var/www/catchall

    # Bloquejar peticions no reconegudes amb un error 400 (Bad Request)
    ErrorDocument 400 "Host no reconegut"
    RewriteEngine On
    RewriteRule ^ - [R=400,L]
</VirtualHost>

## 2. TRAFIC HTTPS (443)
<VirtualHost *:443>
    ServerName _
    ServerAlias *
    DocumentRoot /var/www/catchall

    SSLEngine on
    # Configuració SSL dummy (Apache necessita un certificat per iniciar 443)
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    # TANCAMENT IMMEDIAT (403 Forbidden)
    RewriteEngine On
    # Regla: Per qualsevol petició, retorna 403 (tancar connexió).
    RewriteRule ^ - [R=403,L]
    ErrorDocument 403 /catchall-403

    <Directory /var/www/catchall>
        Require all denied
    </Directory>
</VirtualHost>
EOT

    # 3. Habilitar el nou Virtual Host
    sudo a2ensite zzz-catchall.conf > /dev/null

    echo -e "${C_EXITO}✅ Fitxer zzz-catchall.conf instal·lat i habilitat.${RESET}"
    echo "⚠️ Aquest Virtual Host només actua sobre peticions que NO coincideixen amb $PROJECT_FOLDER.conf."
    sleep 2
}


# ----------------------------------------------------------------------
# 3. CREACIÓN DE ARCHIVOS VIRTUAL HOST
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================="
echo -e "${C_CAPITULO}--- 3. CREACIÓN DE ARCHIVOS DE CONFIGURACIÓN VIRTUAL HOST ---"
echo -e "${C_CAPITULO}=============================================================${RESET}"
echo -e "\n"

VHOST_DIR="/etc/apache2/sites-available"					# Nombre para el directorio donde se encontrarán los VHost
HTTP_REDIRECT_CONF="$VHOST_DIR/$PROJECT_FOLDER.conf"		# Nombre para el VHost http externo que redirigirá a https
SSL_CONF="$VHOST_DIR/$PROJECT_FOLDER-ssl.conf"				# Nombre para el VHost https externo
HTTP_INTERNAL_CONF="$VHOST_DIR/$PROJECT_FOLDER-int.conf"	# Nombre para el VHost http interno

if [[ "$INSTALL_TYPE_LOWER" == "pub" ]]; then

    echo -e "${C_INFO}-> Configurando Vhosts para entorno PÚBLICO (HTTP a HTTPS)${RESET}"
	echo -e "\n"

	# 3.1 Creando archivo para acceso por HTTP (Redirección)
	echo -e "${C_SUBTITULO}--- 3.1 Creando archivo para acceso por HTTP externo (Redirección) ---${RESET}"
	echo -e "${C_SUBTITULO}----------------------------------------------------------------------${RESET}"

	# NOTA: Añadido ServerAlias www.$DOMAIN_CLEAN
	cat << EOF | sudo tee "$HTTP_REDIRECT_CONF" > /dev/null
	<VirtualHost *:80>
		ServerAdmin $SERVER_ADMIN
		ServerName $DOMAIN_CLEAN
		ServerAlias www.$DOMAIN_CLEAN
		RedirectMatch permanent ^(.*)$ https://$DOMAIN_CLEAN$1
	</VirtualHost>
EOF

	echo -e "${C_EXITO}✅ Archivo HTTP ($HTTP_REDIRECT_CONF) para acceso externo creado (Redirección).${RESET}"
	echo -e "\n"
	sleep 1

	# 3.2 Creando archivo para acceso seguro HTTPS (SSL)
	echo -e "${C_SUBTITULO}--- 3.2 Creando archivo para acceso seguro HTTPS (SSL) ---${RESET}"
	echo -e "${C_SUBTITULO}----------------------------------------------------------${RESET}"

	# NOTA: Añadido ServerAlias www.$DOMAIN_CLEAN
	cat << EOF | sudo tee "$SSL_CONF" > /dev/null
<VirtualHost *:443>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_CLEAN
	ServerAlias www.$DOMAIN_CLEAN

	# Configuración WSGI
	WSGIDaemonProcess $PROJECT_FOLDER python-home=$VENV_PATH python-path=$FULL_PATH \\
		locale="ca_ES.utf8"
	WSGIProcessGroup $PROJECT_FOLDER
	WSGIApplicationGroup %{GLOBAL}
	WSGIScriptAlias / $WSGI_PATH 

	# Alias para contenido estático (collectstatic)
	Alias /site-css/admin $FULL_PATH/aula/static/admin/
	Alias /site-css $FULL_PATH/aula/static/

	# Acceso a directorios
	<Directory $FULL_PATH/aula>
		<Files wsgi.py>
			Require all granted
		</Files>
	</Directory>
	<Directory $FULL_PATH/aula/static/>
		Require all granted
	</Directory>
	<Directory $FULL_PATH/aula/static/admin/>
		Require all granted
	</Directory>

	ErrorLog /var/log/apache2/$PROJECT_FOLDER-ssl-error.log
	CustomLog /var/log/apache2/$PROJECT_FOLDER-ssl-access.log combined

	# Configuración SSL (Self-Signed por defecto. Certbot lo reemplazará si se elige LE)
	SSLEngine on
	SSLCertificateFile $CERT_CRT
	SSLCertificateKeyFile $CERT_KEY
	LogLevel warn

	# Otras configuraciones...
	BrowserMatch ".*MSIE.*" \
		nokeepalive ssl-unclean-shutdown \
		downgrade-1.0 force-response-1.0

</VirtualHost>
EOF

	echo -e "${C_EXITO}✅ Archivo SSL ($SSL_CONF) creado.${RESET}"
	sleep 3

else # INSTALACIÓN INTERNA (int)

	echo -e "${C_INFO}-> Configurando Vhost para entorno INTERNO (HTTP-only)${RESET}"
cat << EOF | sudo tee "$HTTP_INTERNAL_CONF" > /dev/null
<VirtualHost *:80>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_CLEAN
	ServerAlias www.$DOMAIN_CLEAN

	# Configuración WSGI
	WSGIDaemonProcess $PROJECT_FOLDER python-home=$VENV_PATH python-path=$FULL_PATH \\
		locale="ca_ES.utf8"
	WSGIProcessGroup $PROJECT_FOLDER
	WSGIApplicationGroup %{GLOBAL}
	WSGIScriptAlias / $WSGI_PATH

	# Alias para contenido estático (collectstatic)
	Alias /site-css/admin $FULL_PATH/aula/static/admin/
	Alias /site-css $FULL_PATH/aula/static/

	# Acceso a directorios
	<Directory $FULL_PATH/aula>
		<Files wsgi.py>
			Require all granted
		</Files>
	</Directory>
	<Directory $FULL_PATH/aula/static/>
		Require all granted
	</Directory>
	<Directory $FULL_PATH/aula/static/admin/>
		Require all granted
	</Directory>

	ErrorLog /var/log/apache2/$PROJECT_FOLDER-http-error.log
	CustomLog /var/log/apache2/$PROJECT_FOLDER-http-access.log combined
	LogLevel warn

	# Otras configuraciones...
	BrowserMatch ".*MSIE.*" \
		nokeepalive \
		downgrade-1.0 force-response-1.0

</VirtualHost>
EOF

echo -e "${C_EXITO}✅ Archivo HTTP INTERNO ($HTTP_INTERNAL_CONF) creado (WSGI puerto 80).${RESET}"

fi

echo -e "\n\n"
echo -e "${C_CAPITULO}================================================"
echo -e "${C_CAPITULO}--- 4. AJUSTE DE PERMISOS DE www-data (WSGI) ---"
echo -e "${C_CAPITULO}================================================${RESET}"
echo -e "\n"

# 1. Aseguramos que www-data pueda leer y ejecutar todos los directorios (X) y archivos (r) 
#    dentro del VENV ($VENV_PATH) y el proyecto ($FULL_PATH).
#    Esto es crucial ya que el VENV fue creado por el usuario '$APP_USER'.
chmod -R a+rX "$VENV_PATH"
chmod -R a+rX "$FULL_PATH"
echo -e "${C_EXITO}✅ Permisos de lectura/ejecución asignados al Venv y código fuente.${RESET}"

# 2. Permisos para la CARPETA DE DATOS PRIVADOS (Necesita Lectura/Escritura)
# Asignamos el grupo 'www-data' y damos permisos de lectura/escritura (770) al grupo.
chown -R "$APP_USER":www-data "$PATH_DADES_PRIVADES"
chmod 770 "$PATH_DADES_PRIVADES"
echo -e "${C_EXITO}✅ Permisos para datos privados asignados a '$APP_USER':www-data (chmod 770).${RESET}"

# 3. Asignar el grupo www-data al proyecto (por si acaso, el propietario sigue siendo $APP_USER)
chown -R "$APP_USER":www-data "$FULL_PATH"
chmod -R g+rx "$FULL_PATH"
echo -e "${C_EXITO}✅️ Grupo 'www-data' asignado al directorio del proyecto.${RESET}"
echo -e "\n\n"

echo -e "${C_EXITO}✅ Ajuste de permisos completados.${RESET}"
sleep 5



# ----------------------------------------------------------------------
# 5. HABILITACIÓN DE VIRTUAL HOSTS Y CERTBOT
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}====================================================="
echo -e "${C_CAPITULO}--- 5. HABILITACIÓN DE SITIOS, CERTBOT Y RECARGA ---"
echo -e "${C_CAPITULO}=====================================================${RESET}"
echo -e "\n"

# 5.1 Deshabilitando Virtual Hosts por defecto
echo -e "${C_SUBTITULO}--- 5.1 Deshabilitando Virtual Hosts por defecto ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------${RESET}"

a2dissite 000-default.conf > /dev/null 2>&1

echo -e "${C_EXITO}✅ Vhost por defecto deshabilitado.${RESET}"
echo -e "\n"
sleep 1

# 5.2 Habilitando los nuevos Virtual Hosts
echo -e "${C_SUBTITULO}--- 5.2 Habilitando los nuevos Virtual Hosts ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------${RESET}"

if [[ "$INSTALL_TYPE_LOWER" == "pub" ]]; then
    # Habilitar VHosts HTTP y SSL
    a2ensite "$PROJECT_FOLDER.conf" > /dev/null
    echo -e "${C_EXITO}✅ Vhost HTTP (80) habilitado y listo para redireccionar.${RESET}"

    a2ensite "$PROJECT_FOLDER-ssl.conf" > /dev/null
    echo -e "${C_EXITO}✅ Vhost HTTPS (443) habilitado. Servidor web listo.${RESET}"

    echo -e "\n"
    echo -e "${C_EXITO}✅ Vhosts ($PROJECT_FOLDER y $PROJECT_FOLDER-ssl) habilitados.${RESET}"

else
    # Habilitar solo el VHost HTTP interno
    a2ensite "$PROJECT_FOLDER-int.conf" > /dev/null
    echo -e "${C_EXITO}✅ Vhost HTTP INTERNO ($PROJECT_FOLDER-int.conf) habilitado en el puerto 80.${RESET}"
fi

echo -e "\n"
sleep 1


# 5.3 PREGUNTA OPCIONAL: INSTAL·LACIÓ DEL CATCH-ALL
echo -e "${C_SUBTITULO}--- 5.3 Configuración de Seguridad Adicional (Catch-all) ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------${RESET}"

echo
echo -e "${C_INFO}ℹ️ Si un servidor està exposat a internet sempre rebrà intents d'accedir al servidor que acaben arribant a Django-aula. L'aplicatiu els rebutja si no es troben dins [ALLOWED_HOSTS], però es genera un correu de notificació a l'administrador per cada intent de connexió rebutjat.${RESET}"
echo
read_prompt "¿Desitja instal·lar el Virtual Host 'Catch-all' (zzz-catchall.conf) que bloquejarà aquestes peticions no reconegudes per a que no arribin a Django-Aula? (Recomanat en Producció) [s/N]: " CATCHALL_CHOICE "n"

CATCHALL_CHOICE_LOWER=$(echo "$CATCHALL_CHOICE" | tr '[:upper:]' '[:lower:]')

if [[ "$CATCHALL_CHOICE_LOWER" == "s" || "$CATCHALL_CHOICE_LOWER" == "si" ]]; then
    # Habilitem el mòdul rewrite si l'usuari vol el catch-all, per si de cas
    a2enmod rewrite > /dev/null 2>&1
    setup_catchall "yes"
else
    setup_catchall "no"
fi

echo -e "\n"
sleep 1


# 5.4 Comprobació de la sintaxis de los Virtual Hosts para el servidor Apache
echo -e "${C_SUBTITULO}--- 5.4 Comprobació de la sintaxis de los Virtual Hosts para el servidor Apache ---${RESET}"
echo -e "${C_SUBTITULO}-----------------------------------------------------------------------------------${RESET}"

echo -e "${C_INFO}ℹ️ Verificando la sintaxis de los archivos de configuración de Apache (apache2ctl configtest)${RESET}"
echo -e "\n"
apache2ctl configtest


if [ $? -ne 0 ]; then
	echo -e "${C_ERROR}❌ ERROR CRÍTICO: Fallo en la prueba de configuración de Apache. Revise los archivos de configuración creados. La instalación se detiene.${RESET}"
    exit 1 # Detener la instalación si el Vhost SSL es inválido
fi
echo -e "/n"

# 5.5 Informació del certificado autofirmado o instal·lació del certificado Let's Encrypt

# Mostrar este paso si se ha elegido 'auto', asumiendo que el certificado autofirmado 'self-signed' es el que se está utilizando.
if [[ "$CERT_TYPE_LOWER" == "auto" ]]; then

	echo -e "${C_SUBTITULO}--- 5.5 Certificado SSL Autofirmado generado e instalado ---${RESET}"
	echo -e "${C_SUBTITULO}------------------------------------------------------------${RESET}"
    echo -e "${C_EXITO}✅ Certificado SSL Autofirmado generado e instalado en el Vhost temporal.${RESET}"
    echo -e "${C_INFO}ℹ️ La conexión HTTPS funcionará, pero el navegador mostrará una advertencia de seguridad.${RESET}"


# Mostrar este paso si se ha elegido 'le' con el fin de ejecutar Certbot e instalar los certificados Let's Encrypt.
elif [[ "$CERT_TYPE_LOWER" == "le" ]]; then

	echo -e "${C_SUBTITULO}--- 5.4 Ejecutando Certbot para generar e instalar los certificados de Let's Encrypt ---${RESET}"
	echo -e "${C_SUBTITULO}----------------------------------------------------------------------------------------${RESET}"

	echo -e "${C_INFO}ℹ️ Certbot ejecutará una herramienta de comprobación interactiva y le hará preguntas sobre la configuración.${RESET}"
	echo -e "\n"

	echo -e "${C_INFO}Hay parámetros importantes que definir como:${RESET}"
	echo -e "${NEGRITA}  - Ingresar un correo válido.${RESET}"
	echo -e "${NEGRITA}  - Seleccionar 'Enter' para habilitar HTTPS en ambos dominios (con y sin www).${RESET}"
	echo -e "${NEGRITA}  - Seleccionar '2' cuando le pregunte si desea no redirigir (opción 1) o redirigir (opción 2) el tráfico generado cuando se haya usado HTTP en vez de HTPPS.${RESET}"
	echo -e "\n"

	# Ejecutar Certbot de forma interactiva
	certbot --apache --redirect

	echo -e "\n"
	if [ $? -ne 0 ]; then
		echo -e "${C_ERROR}❌ ERROR: Fallo en la obtención del certificado Let's Encrypt. La instalación continuará con el certificado Self-Signed original, si se pudo generar anteriormente como paso previo y necesario.${RESET}"
	else
		echo -e "${C_EXITO}✅ Certificados Let's Encrypt obtenidos e instalados con éxito. Apache2 modificado.${RESET}"
		echo -e "${C_INFO}ℹ️ La renovación automática está configurada por Certbot (certbot.timer).${RESET}"

		# ----------------------------------------------
		# VERIFICACIÓN Y PRUEBA DE RENOVACIÓN DE CERTBOT
		# ----------------------------------------------

		echo -e "\n"
		echo -e "${C_SUBTITULO}--- Verificación de la Renovación de Certificados ---${RESET}"
		echo -e "${C_SUBTITULO}-----------------------------------------------------${RESET}"

		read_prompt "¿Desea verificar el estado del servicio de renovación automática (certbot.timer)? (sí/NO - Enter para NO): " CHECK_TIMER "no"

		RESPONSE_LOWER=$(echo "$CHECK_TIMER" | tr '[:upper:]' '[:lower:]')

		if [[ "$RESPONSE_LOWER" == "sí" ]] || [[ "$RESPONSE_LOWER" == "si" ]]; then
			echo -e "${C_INFO}-> Estado de certbot.timer:${RESET}"
			systemctl status certbot.timer
		fi
		echo -e "\n" 
		read_prompt "¿Desea ejecutar una simulación de renovación de certificados (dry-run)? Esto no modificará el sistema, sólo és una simulación. (sí/NO - Enter para NO): " DRY_RUN_TEST "no"

		RESPONSE_LOWER=$(echo "$DRY_RUN_TEST" | tr '[:upper:]' '[:lower:]')

		if [[ "$RESPONSE_LOWER" == "sí" ]] || [[ "$RESPONSE_LOWER" == "si" ]]; then
			echo -e "${C_INFO}-> Ejecutando: sudo certbot renew --dry-run${RESET}"
			echo -e "\n" 
			certbot renew --dry-run

			echo -e "\n"
			if [ $? -eq 0 ]; then
				echo -e "${C_EXITO}✅ Simulación de renovación completada con éxito. El proceso automático funcionará.${RESET}"
			else
				echo -e "${C_ERROR}❌ ADVERTENCIA: La simulación de renovación falló. Revise los logs de Certbot para determinar la causa.${RESET}"
			fi
		fi
	fi
fi

echo -e "\n"

# 5.6 Recargando la configuración del servidor Apache para aplicar los cambios

echo -e "${C_SUBTITULO}--- 5.6 Recargando la configuración del servidor Apache para aplicar los cambios ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------------------------------${RESET}"

systemctl reload apache2

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al recargar Apache2. Revisa los logs y la sintaxis de los Vhosts.${RESET}"
	echo -e "\n"
    exit 1
else
	# Mostrar el estado del servicio para confirmación
	echo -e "Estado del servicio Apache2:\n"
	systemctl status apache2 | grep Loaded
	systemctl status apache2 | grep Active
	echo -e "\n"
	echo -e "${C_EXITO}✅ Recarga de Apache2 completada sin errores.${RESET}"
fi
sleep 5


echo -e "\n\n"
echo -e "${C_PRINCIPAL}===================================================================="
echo -e "${C_PRINCIPAL}--- FASE 2. CONFIGURACIÓN DE APACHE FINALIZADA${RESET} ${CIANO}(setup_apache.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}====================================================================${RESET}"
echo -e "\n"

echo -e "${C_INFO}La aplicación debería estar disponible en: ${RESET}${C_SUBTITULO}$DOMAIN_CLEAN${RESET}"
echo -e "\n"

echo -e "${C_INFO}--- SIGUIENTE FASE: FASE 3 - TAREAS PROGRAMADAS Y MANTENIMIENTO ---${RESET}"
echo -e "\n"

echo -e "Para continuar con la automatización de las tareas programadas (CRON) en el servidor, ${NEGRITA}ejecute los siguientes comandos (Copiar/Pegar)${RESET}:"
echo -e "\n"

echo "   1. Cambie al directorio del proyecto:"
echo -e "      \$ ${C_SUBTITULO} cd \"$SETUP_DIR\"${RESET}"
echo -e "\n"

echo "   2. Ejecute el script que configurará las tareas programada (CRON) en el servidor (DEBE SER con sudo):"
echo -e "      \$ ${C_SUBTITULO} sudo bash setup_cron.sh${RESET}"
echo -e "\n"

echo "¡Puede proceder con la configuración de las automatizaciones (CRON)"
echo -e "\n"

