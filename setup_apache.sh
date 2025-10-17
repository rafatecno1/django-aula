#!/bin/bash
# setup_apache.sh
# Automatiza la configuración de Apache2, módulos, virtual hosts y certificados.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash setup_apache.sh)

echo -e "\n================================================================"
echo "--- 🟢 INICIO DEL SCRIPT: setup_apache.sh (Configuración Apache) 🟢 ---"
echo "=================================================================="
echo -e "\n"

# ----------------------------------------------------------------------
# FUNCIONES DE AYUDA Y VALIDACIÓN
# ----------------------------------------------------------------------

# Función para leer la entrada de datos del usuario y asegurar que no deja 
# respuestas en blanco ni con espacios delante o detrás.
# Uso: read_and_validate "Mensaje de la pregunta" VARIABLE_NAME
read_and_validate () {
    # $1 contiene el mensaje (prompt), $2 contiene el nombre de la variable (sin $)
    local PROMPT_MSG="$1"
    local VAR_NAME="$2"
    local INPUT_VALUE=""
    
    # Bucle de validación: se repite hasta obtener una respuesta no vacía
    while true; do
        read -p "$PROMPT_MSG" INPUT_VALUE
        
        # Eliminar espacios en blanco alrededor (trim)
        INPUT_VALUE=$(echo "$INPUT_VALUE" | xargs)
        
        if [ -z "$INPUT_VALUE" ]; then
            echo -e "❌ ERROR: Este campo no puede dejarse en blanco.\n"
        else
            # Asignar el valor a la variable cuyo nombre se pasó como argumento ($2)
            eval "$VAR_NAME='$INPUT_VALUE'"
            break
        fi
    done
}


# ----------------------------------------------------------------------
# 1. INSTALACIÓN Y DEFINICIÓN DE PARÁMETROS
# ----------------------------------------------------------------------

echo "=================================================================="
echo "--- ⚙️ 1. INSTALACIÓN Y DEFINICIÓN DE PARÁMETROS DEL SERVIDOR ---"
echo "=================================================================="
echo -e "\n"

echo "--- 1.1 Instalación del Servidor Apache y Módulo WSGI ---"

apt update && apt install -y apache2 libapache2-mod-wsgi-py3 > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo en la instalación del servidor Apache. Saliendo."
    exit 1
fi
echo "✅ Servidor Apache y WSGI instalados."
echo -e "\n"


echo "--- 1.2 Solicitud y Validación de Parámetros ---"
echo -e "\n"

# Implementación de read_and_validate
read_and_validate "Introduce el dominio principal (ej: elteudomini.cat): " DOMAIN_NAME
read_and_validate "Introduce el correo del administrador (ej: juan@xtec.cat): " SERVER_ADMIN
read_and_validate "Introduce el nombre de la carpeta del proyecto (ej: djau2025): " PROJECT_FOLDER

INSTALL_DIR="/opt"
FULL_PATH="$INSTALL_DIR/$PROJECT_FOLDER"
VENV_PATH="$FULL_PATH/venv"
WSGI_PATH="$FULL_PATH/aula/wsgi.py"
echo "☑️ Parámetros definidos."
echo -e "\n"

# 1.3 Verificación de la Carpeta del Proyecto (OBJETIVO 2)
echo "--- 1.3 Verificando la existencia del directorio del proyecto ---"

if [ ! -d "$FULL_PATH" ]; then
    echo "❌ ERROR: No se encuentra el directorio del proyecto esperado en '$FULL_PATH'."
    echo "Asegúrate de que el script 'install_app.sh' y 'setup_djau.sh' se hayan ejecutado correctamente."
    exit 1
fi
echo "✅ Directorio del proyecto '$FULL_PATH' encontrado."
echo -e "\n"

# ----------------------------------------------------------------------
# 2. HABILITACIÓN DE MÓDULOS Y GENERACIÓN DE CERTIFICADO
# ----------------------------------------------------------------------

echo "================================================================="
echo "--- 🛡️ 2. CONFIGURACIÓN DE MÓDULOS Y CERTIFICADO SSL ---"
echo "================================================================="
echo -e "\n"

echo "--- 2.1 Habilitación de Módulos de Apache ---"
a2enmod wsgi ssl headers rewrite > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al habilitar módulos de Apache (wsgi, ssl, headers, rewrite)."
    exit 1
fi
echo "✅ Módulos habilitados: wsgi, ssl, headers, rewrite."
echo -e "\n"


echo "--- 2.2 Generación de Certificado Self-Signed (para Desarrollo) ---"

CERT_KEY="/etc/ssl/private/$PROJECT_FOLDER-selfsigned.key"
CERT_CRT="/etc/ssl/certs/$PROJECT_FOLDER-selfsigned.crt"

# Se genera el certificado para evitar errores al activar el vhost SSL
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$CERT_KEY" -out "$CERT_CRT" -subj "/C=ES/ST=Catalonia/L=Badia/O=$PROJECT_FOLDER/CN=$DOMAIN_NAME" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al generar el certificado SSL autofirmado."
    exit 1
fi
echo "✅ Certificado de desarrollo generado en $CERT_CRT."
echo -e "\n"


# ----------------------------------------------------------------------
# 3. CREACIÓN DE ARCHIVOS VIRTUAL HOST
# ----------------------------------------------------------------------

echo "================================================================="
echo "--- 📝 3. CREACIÓN DE ARCHIVOS DE CONFIGURACIÓN VIRTUAL HOST ---"
echo "================================================================="
echo -e "\n"

VHOST_DIR="/etc/apache2/sites-available"
HTTP_CONF="$VHOST_DIR/$PROJECT_FOLDER.conf"
SSL_CONF="$VHOST_DIR/$PROJECT_FOLDER-ssl.conf"


echo "--- 3.1 Creando archivo para acceso por HTTP (Redirección) ---"

cat << EOF | sudo tee "$HTTP_CONF" > /dev/null
<VirtualHost *:80>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_NAME
	# Redirección permanente a HTTPS
	# NOTA: Para testing local en VirtualBox con port forwarding (8080->80, 4443->443),
	#       esta redirección debe ser: https://$DOMAIN_NAME:4443$1
	RedirectMatch permanent ^(.*)$ https://$DOMAIN_NAME$1
</VirtualHost>
EOF
echo "✅ Archivo HTTP ($HTTP_CONF) creado (Redirección)."
echo -e "\n"


echo "--- 3.2 Creando archivo para acceso HTTPS (SSL) ---"

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


# ----------------------------------------------------------------------
# 4. HABILITACIÓN DE VIRTUAL HOSTS Y REINICIO
# ----------------------------------------------------------------------

echo "================================================================="
echo "--- 🚀 4. HABILITACIÓN DE SITIOS Y RECARGA DE APACHE ---"
echo "================================================================="
echo -e "\n"

echo "--- 4.1 Deshabilitando Virtual Hosts por defecto ---"
a2dissite 000-default.conf > /dev/null 2>&1
echo "☑️ Vhost por defecto deshabilitado."
echo -e "\n"

echo "--- 4.2 Habilitando los nuevos Virtual Hosts ---"
a2ensite "$PROJECT_FOLDER.conf" > /dev/null
a2ensite "$PROJECT_FOLDER-ssl.conf" > /dev/null
echo "☑️ Vhosts de la aplicación habilitados."
echo -e "\n"

echo "--- 4.3 Recargando Apache para aplicar los cambios ---"
systemctl reload apache2

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al recargar Apache2. Revisa los logs y la sintaxis de los Vhosts."
    exit 1
else
	# Mostrar el estado del servicio para confirmación
	echo "--- Estado del servicio Apache2 ---"
	systemctl status apache2 | grep Loaded
	systemctl status apache2 | grep Active
	echo "✅ Recarga de Apache2 completada sin errores."
fi

echo -e "\n"
echo "================================================================="
echo "--- 🟢 CONFIGURACIÓN DE APACHE FINALIZADA 🟢 ---"
echo "La aplicación debería estar disponible en https://$DOMAIN_NAME"
echo "================================================================="
echo -e "\n"