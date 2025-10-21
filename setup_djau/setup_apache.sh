#!/bin/bash
# setup_apache.sh
# Automatiza la configuración de Apache2, módulos, virtual hosts y certificados.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash setup_apache.sh)

echo -e "\n"
echo "======================================================================"
echo "--- 🟢 FASE 3: SERVIDOR WEB Y CERTIFICADOS SSL setup_apache.sh 🟢 ---"
echo "======================================================================"
echo -e "\n"

if [ "$(id -u)" -ne 0 ]; then
    echo "❌ ADVERTENCIA: Este script debe ejecutarse con 'sudo bash setup_cron.sh' para modificar las tareas programadas en crontab."
    sleep 3
fi

# ----------------------------------------------------------------------
# FUNCIONES DE AYUDA Y VALIDACIÓN
# ----------------------------------------------------------------------

# Función para leer la entrada de datos del usuario o asignar un valor por defecto
# Uso: read_or_default "Mensaje de la pregunta" VARIABLE_NAME "VALOR_POR_DEFECTO"
read_or_default () {
    # $1: Mensaje (prompt), $2: Nombre de la variable (sin $), $3: Valor por defecto
    local PROMPT_MSG="$1"
    local VAR_NAME="$2"
    local DEFAULT_VALUE="$3"
    local INPUT_VALUE=""
    
    # Leer la entrada del usuario
    read -p "$PROMPT_MSG" INPUT_VALUE
    
    # Eliminar espacios en blanco alrededor (trim)
    INPUT_VALUE=$(echo "$INPUT_VALUE" | xargs)
    
    if [ -z "$INPUT_VALUE" ]; then
        # Asignar el valor por defecto
        eval "$VAR_NAME='$DEFAULT_VALUE'"
        echo "☑️ Valor por defecto usado: '$DEFAULT_VALUE'"
    else
        # Asignar el valor introducido por el usuario
        eval "$VAR_NAME='$INPUT_VALUE'"
        echo "☑️ Valor introducido: '$INPUT_VALUE'"
    fi
}


echo "======================================================================"
echo "--- 📝 1. PREPARACIÓN DEL ENTORNO Y CARGA DE VARIABLES COMPARTIDAS ---"
echo "======================================================================"
echo -e "\n"

# Càrrega de variables comunes

# El script se ejecuta desde /opt/djau/setup_djau, por lo que el directorio padre es /opt/djau
FULL_PATH=$(dirname "$PWD")
SETUP_DIR="$PWD" # La ubicación actual del script

CONFIG_FILE="$SETUP_DIR/config_vars.sh"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo "☑️ Variables de configuración cargadas desde $CONFIG_FILE."
else
    echo "❌ ERROR: Archivo de configuración ($CONFIG_FILE) no encontrado. Saliendo."
    exit 1
fi

echo -e "\n"

# ----------------------------------------------------------------------
# 2. INSTALACIÓN Y DEFINICIÓN DE PARÁMETROS
# ----------------------------------------------------------------------

echo "================================================================="
echo "--- ⚙️ 2. INSTALACIÓN Y DEFINICIÓN DE PARÁMETROS DEL SERVIDOR ---"
echo "================================================================="
echo -e "\n"

echo -e "--- 2.1 Instalación del Servidor Apache y Módulo WSGI ---\n"

apt update && apt install -y apache2 libapache2-mod-wsgi-py3

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo en la instalación del servidor Apache. Saliendo."
    exit 1
fi
echo -e "\n"
echo "✅ Servidor Apache y WSGI instalados."
echo -e "\n"
sleep 3

echo "--- 2.2 Solicitud y Validación de Parámetros ---"
echo -e "\n"

# Implementación de read_and_validate
#read_and_validate "Introduce el dominio principal (ej: elteudomini.cat): " DOMAIN_NAME
read_or_default "Introduce el correo del administrador (por defecto: juan@xtec.cat): " SERVER_ADMIN "juan@xtec.cat"
#read_and_validate "Introduce el nombre de la carpeta del proyecto (ej: djau): " PROJECT_FOLDER

#INSTALL_DIR="/opt"
#FULL_PATH="$INSTALL_DIR/$PROJECT_FOLDER"
#VENV_PATH="$FULL_PATH/venv"
WSGI_PATH="$FULL_PATH/aula/wsgi.py"

echo "☑️ Parámetros definidos."
echo -e "\n"
sleep 3

# ESTE PUNTO ES REDUNDANTE PORQUE AHORA $FULL_PATH LO CARGAMOS DE config_vars.sh CON LO QUE TIENE QUE SER VÁLIDO
echo "--- 2.3 Verificando la existencia del directorio del proyecto ---"

if [ ! -d "$FULL_PATH" ]; then
    echo "❌ ERROR: No se encuentra el directorio del proyecto esperado en '$FULL_PATH'."
    echo "Asegúrate de que el script 'install_djau.sh' y 'setup_djau.sh' se hayan ejecutado correctamente."
    exit 1
fi
echo "✅ Directorio del proyecto proporcionado '$FULL_PATH' ha sido encontrado."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 3. HABILITACIÓN DE MÓDULOS Y GENERACIÓN DE CERTIFICADO
# ----------------------------------------------------------------------

echo "========================================================"
echo "--- 🛡️ 3. CONFIGURACIÓN DE MÓDULOS Y CERTIFICADO SSL ---"
echo "========================================================"
echo -e "\n"

echo "--- 3.1 Habilitación de Módulos de Apache ---"
a2enmod wsgi ssl headers rewrite > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al habilitar módulos de Apache (wsgi, ssl, headers, rewrite)."
    exit 1
fi
echo "✅ Módulos habilitados: wsgi, ssl, headers, rewrite."
echo -e "\n"
sleep 3

echo "--- 3.2 Generación de Certificado Self-Signed (para Desarrollo) ---"

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

# Se genera el certificado para evitar errores al activar el vhost SSL
echo "     -> Generando certificado Self-Signed para $DOMAIN_NAME"
echo -e "\n"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$CERT_KEY" -out "$CERT_CRT" -subj "/C=ES/ST=Catalonia/L=$LOCALITAT_CLEAN/O=$PROJECT_FOLDER/CN=$DOMAIN_NAME" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al generar el certificado SSL autofirmado."
    exit 1
fi
echo "✅ Certificado Self-Signed (para Desarrollo) generado en $CERT_CRT."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 4. CREACIÓN DE ARCHIVOS VIRTUAL HOST
# ----------------------------------------------------------------------

echo "================================================================"
echo "--- 📝 4. CREACIÓN DE ARCHIVOS DE CONFIGURACIÓN VIRTUAL HOST ---"
echo "================================================================"
echo -e "\n"

VHOST_DIR="/etc/apache2/sites-available"
HTTP_CONF="$VHOST_DIR/$PROJECT_FOLDER.conf"
SSL_CONF="$VHOST_DIR/$PROJECT_FOLDER-ssl.conf"


echo "--- 4.1 Creando archivo para acceso por HTTP (Redirección) ---"

cat << EOF | sudo tee "$HTTP_CONF" > /dev/null
<VirtualHost *:80>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_NAME
	# Redirección permanente a HTTPS
	# NOTA: Para testing local en VirtualBox con port forwarding desde la máquina Host (8080->80, 4443->443),
	#       esta redirección debe ser: https://$DOMAIN_NAME:4443$1
	#       además será necesario añadir una linea en el archivo host para hacer ligar la ip con el https://$DOMAIN_NAME
	RedirectMatch permanent ^(.*)$ https://$DOMAIN_NAME$1
</VirtualHost>
EOF

echo "✅ Archivo HTTP ($HTTP_CONF) creado (Redirección)."
echo -e "\n"
sleep 3

echo "--- 4.2 Creando archivo para acceso HTTPS (SSL) ---"

cat << EOF | sudo tee "$SSL_CONF" > /dev/null
<VirtualHost *:443>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_NAME

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

echo "✅ Archivo SSL ($SSL_CONF) creado (Servicio principal)."
echo -e "\n"
sleep 5

# ----------------------------------------------------------------------
# 5. HABILITACIÓN DE VIRTUAL HOSTS Y REINICIO
# ----------------------------------------------------------------------

echo "========================================================"
echo "--- 🚀 5. HABILITACIÓN DE SITIOS Y RECARGA DE APACHE ---"
echo "========================================================"
echo -e "\n"

echo "--- 5.1 Deshabilitando Virtual Hosts por defecto ---"
a2dissite 000-default.conf > /dev/null 2>&1
echo "☑️ Vhost por defecto deshabilitado."
echo -e "\n"
sleep 2

echo "--- 5.2 Habilitando los nuevos Virtual Hosts ---"
a2ensite "$PROJECT_FOLDER.conf" > /dev/null
a2ensite "$PROJECT_FOLDER-ssl.conf" > /dev/null
echo "☑️ Vhosts de la aplicación habilitados."
echo -e "\n"
sleep 3

echo "--- 5.3 Recargando Apache para aplicar los cambios ---"
echo -e "\n"

systemctl reload apache2

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al recargar Apache2. Revisa los logs y la sintaxis de los Vhosts."
    exit 1
else
	# Mostrar el estado del servicio para confirmación
	echo "- Estado del servicio Apache2:"
	systemctl status apache2 | grep Loaded
	systemctl status apache2 | grep Active
	echo -e "\n"
	echo "✅ Recarga de Apache2 completada sin errores."
fi
sleep 5

echo -e "\n"
echo "========================================================="
echo "--- 🟢 FASE 3. CONFIGURACIÓN DE APACHE FINALIZADA 🟢 ---"
echo ""
echo "La aplicación debería estar disponible en:"
echo "https://$DOMAIN_NAME"
echo "========================================================="
echo -e "\n"


echo "--- SIGUIENTE FASE: FASE 4 - TAREAS PROGRAMADAS Y MANTENIMIENTO ---"
echo -e "\n"
echo "Para continuar con la configuración de las automatizaciones para las tareas programadas (CRON) en el servidor, ejecute los siguientes comandos (Copiar/Pegar):"
echo -e "\n"
echo "   1. Cambie al directorio del proyecto:"
echo "      $ cd \"$FULL_PATH\""
echo -e "\n"
echo "   2. Ejecute el script de configuración del servidor web Apache (DEBE SER con sudo):"
echo "      $ sudo bash setup_djau/setup_cron.sh"
echo -e "\n"
echo "¡Puede proceder con la configuración de las automatizaciones (CRON)"
echo -e "\n"