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
echo -e "Cargando archivo functions.sh y config_vars.sh."
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
# 1. INSTALACIÓN Y DEFINICIÓN DE PARÁMETROS
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}=============================================================="
echo -e "${C_CAPITULO}--- 1. INSTALACIÓN Y DEFINICIÓN DE PARÁMETROS DEL SERVIDOR ---"
echo -e "${C_CAPITULO}==============================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 1.1 Instalación del Servidor Apache y Módulo WSGI ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------------${RESET}"

# 1. Actualizar la lista de paquetes
echo -e "${C_INFO}ℹ️ Actualizando la lista de paquetes (apt update)...${RESET}"
apt update
echo -e "\n"

# 2. Instalar el servidor Apache y el módulo WSGI
echo -e "${C_INFO}ℹ️ Instalando servidor Apache y módulo WSGI.${RESET}"

apt install -y apache2 libapache2-mod-wsgi-py3

if [ $? -ne 0 ]; then
    echo -e "\n"
    echo -e "${C_ERROR}❌ ERROR: Fallo CRÍTICO en la instalación del servidor Apache.${RESET}"
    echo -e "${C_INFO}ℹ️ No es posible continuar sin el servidor Apache. Revise la conexión, el log y ejecute el script de nuevo.${RESET}"
	echo -e "\n"
    exit 1
fi

echo -e "\n"
echo -e "${C_EXITO}✅ Servidor Apache y WSGI instalados correctamente.${RESET}"
echo -e "\n"
sleep 3


echo -e "${C_SUBTITULO}--- 1.2 Solicitud y Validación de Parámetros ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------${RESET}"

read_prompt "Introduce el correo del administrador (por defecto: juan@xtec.cat): " SERVER_ADMIN "juan@xtec.cat"

VENV_PATH="$FULL_PATH/venv"
WSGI_PATH="$FULL_PATH/aula/wsgi.py"

echo -e "${C_EXITO}✅ Parámetros definidos.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 2. HABILITACIÓN DE MÓDULOS Y GENERACIÓN DE CERTIFICADO
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}====================================================="
echo -e "${C_CAPITULO}--- 2. CONFIGURACIÓN DE MÓDULOS Y CERTIFICADO SSL ---"
echo -e "${C_CAPITULO}=====================================================${RESET}"
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

echo -e "${C_SUBTITULO}--- 2.2 Generación de Certificados autofirmados (Self-Signed), normalmente usados para pruebas ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------------------------------------------${RESET}"

CERT_KEY="/etc/ssl/private/$PROJECT_FOLDER-selfsigned.key"
CERT_CRT="/etc/ssl/certs/$PROJECT_FOLDER-selfsigned.crt"

# ----------------------------------------------------------------------
# LIMPIEZA DE VARIABLES PARA OPENSSL
# ----------------------------------------------------------------------

# 1. Quitar acentos y caracteres especiales (usando iconv, asumiendo su disponibilidad)
# 2. Reemplazar espacios por guiones bajos.
# 3. Eliminar cualquier carácter que no sea alfanumérico o guion bajo, por seguridad.

LOCALITAT_CLEAN=$(echo "$LOCALITAT" | iconv -t ascii//TRANSLIT | tr ' ' '_')
LOCALITAT_CLEAN=$(echo "$LOCALITAT_CLEAN" | sed 's/[^a-zA-Z0-9_]//g')

# Limpiar la variable DOMAIN_NAME para obtener solo el host/dominio
# Usamos sustitución de shell de Bash para eliminar el prefijo http(s)://
DOMAIN_CLEAN="${DOMAIN_NAME#https://}"  # Elimina el prefijo 'https://'
DOMAIN_CLEAN="${DOMAIN_CLEAN#http://}"  # Elimina el prefijo 'http://' (si existiera)
DOMAIN_CLEAN="${DOMAIN_CLEAN%/}"        # Elimina la barra '/' final (si existiera)

# Se genera el certificado para evitar errores al activar el vhost SSL
echo -e "${C_INFO}-> Generando certificado Self-Signed para $DOMAIN_CLEAN${RESET}"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$CERT_KEY" -out "$CERT_CRT" -subj "/C=ES/ST=Catalonia/L=$LOCALITAT_CLEAN/O=$PROJECT_FOLDER/CN=$DOMAIN_CLEAN" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al generar el certificado SSL autofirmado.${RESET}"
	echo -e "\n"
    exit 1
fi
echo -e "${C_EXITO}✅ Certificado Self-Signed (para Desarrollo) generado en $CERT_CRT.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 3. CREACIÓN DE ARCHIVOS VIRTUAL HOST
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================="
echo -e "${C_CAPITULO}--- 3. CREACIÓN DE ARCHIVOS DE CONFIGURACIÓN VIRTUAL HOST ---"
echo -e "${C_CAPITULO}=============================================================${RESET}"
echo -e "\n"

VHOST_DIR="/etc/apache2/sites-available"
HTTP_CONF="$VHOST_DIR/$PROJECT_FOLDER.conf"
SSL_CONF="$VHOST_DIR/$PROJECT_FOLDER-ssl.conf"

echo -e "${C_SUBTITULO}--- 3.1 Creando archivo para acceso por HTTP (Redirección) ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------${RESET}"

cat << EOF | sudo tee "$HTTP_CONF" > /dev/null
<VirtualHost *:80>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_CLEAN
	# Redirección permanente a HTTPS
	# NOTA: Para testing local en VirtualBox con port forwarding desde la máquina Host (8080->80, 4443->443),
	#       esta redirección debe ser: https://$DOMAIN_CLEAN:4443$1
	#       además será necesario añadir una linea en el archivo host para hacer ligar la ip con el https://$DOMAIN_CLEAN
	RedirectMatch permanent ^(.*)$ https://$DOMAIN_CLEAN$1
</VirtualHost>
EOF

echo -e "${C_EXITO}✅ Archivo HTTP ($HTTP_CONF) creado (Redirección).${RESET}"
echo -e "\n"
sleep 1

echo -e "${C_SUBTITULO}--- 3.2 Creando archivo para acceso seguro HTTPS (SSL) ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------------${RESET}"


cat << EOF | sudo tee "$SSL_CONF" > /dev/null
<VirtualHost *:443>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_CLEAN

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

	ErrorLog /var/log/apache2/$PROJECT_FOLDER\_ssl\_error.log
	CustomLog /var/log/apache2/$PROJECT_FOLDER\_ssl\_access.log combined

	# Configuración SSL (Self-Signed)
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

echo -e "${C_EXITO}✅ Archivo SSL ($SSL_CONF) creado (Servicio principal).${RESET}"
sleep 3


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
# 5. HABILITACIÓN DE VIRTUAL HOSTS Y REINICIO
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}====================================================="
echo -e "${C_CAPITULO}--- 5. HABILITACIÓN DE SITIOS Y RECARGA DE APACHE ---"
echo -e "${C_CAPITULO}=====================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 5.1 Deshabilitando Virtual Hosts por defecto ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------${RESET}"

a2dissite 000-default.conf > /dev/null 2>&1

echo -e "${C_EXITO}✅ Vhost por defecto deshabilitado.${RESET}"
echo -e "\n"
sleep 1

echo -e "${C_SUBTITULO}--- 5.2 Habilitando los nuevos Virtual Hosts ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------${RESET}"

a2ensite "$PROJECT_FOLDER.conf" > /dev/null
echo -e "${C_EXITO}✅ Vhost HTTP (80) habilitado y listo para redireccionar.${RESET}"

a2ensite "$PROJECT_FOLDER-ssl.conf" > /dev/null
echo -e "${C_EXITO}✅ Vhost HTTPS (443) habilitado. Servidor web listo.${RESET}"
echo -e "\n"
sleep 1

echo -e "${C_SUBTITULO}--- 5.3 Recargando la configuración del servidor Apache para aplicar los cambios ---${RESET}"
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

echo -e "${C_INFO}La aplicación debería estar disponible en: ${RESET}${C_SUBTITULO}$DOMAIN_NAME${RESET}"
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
