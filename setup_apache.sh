#!/bin/bash
# setup_apache.sh
# Automatiza la configuración de Apache2, módulos, virtual hosts y certificados.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash setup_apache.sh)


# 1. INSTALAR SERVIDOR APACHE

echo -e "\n"
echo "------------------------------------------"
echo "--- 1. Instalación del servidor Apache ---"
echo "------------------------------------------"

apt update && apt install -y apache2 libapache2-mod-wsgi-py3

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo en la instalación del servidor Apache. Saliendo."
    exit 1
fi
echo -e "\n"
echo -e "✅ Servidor Apache instalado.\n\n"

echo "------------------------------------------------------"
echo "--- 2. Configuración de Parámetros de Apache y SSL ---"
echo "------------------------------------------------------"

echo -e "\n"


# 2.1 Solicitud de variables

echo -e "--- 2.1 Solicitud de variables ---\n"

read -p "Introduce el dominio principal (ej: elteudomini.cat): " DOMAIN_NAME
read -p "Introduce el correo del administrador (ej: juan@xtec.cat): " SERVER_ADMIN
read -p "Introduce el nombre de la carpeta del proyecto (ej: djau): " PROJECT_FOLDER

INSTALL_DIR="/opt"
FULL_PATH="$INSTALL_DIR/$PROJECT_FOLDER"
VENV_PATH="$FULL_PATH/venv"
WSGI_PATH="$FULL_PATH/aula/wsgi.py"

echo -e "\n"


# 2.2 Habilitar módulos necesarios de Apache: wsgi y ssl

echo -e "--- 2.2 Habilitar módulos necesarios de Apache: wsgi y ssl ---\n"

a2enmod wsgi ssl headers rewrite
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al habilitar módulos de Apache. Revisa la instalación de Apache."
    exit 1
fi
echo -e "\n"
echo -e "✅ Módulos habilitados.\n"


# 2.3 Generación de Certificado Self-Signed (Desarrollo/Test)

echo "--- 2.3 Generación de Certificado Self-Signed (para Desarrollo/Test) ---"

CERT_KEY="/etc/ssl/private/$PROJECT_FOLDER-selfsigned.key"
CERT_CRT="/etc/ssl/certs/$PROJECT_FOLDER-selfsigned.crt"

echo "     -> Generando certificado Self-Signed para $DOMAIN_NAME"

# Se genera el certificado para evitar errores al activar el vhost SSL
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$CERT_KEY" -out "$CERT_CRT" -subj "/C=ES/ST=Catalonia/L=Badia/O=$PROJECT_FOLDER/CN=$DOMAIN_NAME" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al generar el certificado SSL autofirmado."
    exit 1
fi

echo -e "✅ Certificado de desarrollo generado en $CERT_CRT \n\n"



echo "--------------------------------------"
echo "--- 3. Crear Archivos Virtual Host ---"
echo "--------------------------------------"

echo -e "\n"

VHOST_DIR="/etc/apache2/sites-available"
HTTP_CONF="$VHOST_DIR/$PROJECT_FOLDER.conf"
SSL_CONF="$VHOST_DIR/$PROJECT_FOLDER-ssl.conf"


# Creando archivos de configuración de Virtual Host

echo -e "--- Creando archivos de configuración de Virtual Host ---\n"


# 3.1 Archivo HTTP (Para Redirección)

echo "--- 3.1 Creando archivo para acceso por HTTP con redirección ---"

cat << EOF | sudo tee "$HTTP_CONF" > /dev/null
<VirtualHost *:80>
	ServerAdmin $SERVER_ADMIN
	ServerName $DOMAIN_NAME
	# Redirección permanente a HTTPS
	RedirectMatch permanent ^(.*)$ https://$DOMAIN_NAME/\$1
</VirtualHost>
EOF

echo -e "✅ Archivo HTTP ($HTTP_CONF) creado (Redirección).\n"

# 3.2 Archivo SSL (HTTPS)

echo "--- 3.2 Creando archivo para accesso HTTPS (SSL) ---"

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

echo -e "✅ Archivo SSL ($SSL_CONF) creado (Servicio principal).\n"

echo -e "\n"
echo "---------------------------------------------------------"
echo "--- 4. Habilitando Virtual Hosts y Reiniciando Apache ---"
echo "---------------------------------------------------------"

echo -e "\n"

echo "--- 4.1 Deshabilitando Virtual Hosts por defecto ---"
# Deshabilitar el sitio por defecto (si existe)
a2dissite 000-default.conf > /dev/null 2>&1
echo -e "☑️ Vhost por defecto deshabilitado. \n"

echo "--- 4.2 Habilitando los nuevos Virtual Hosts ---"
# Habilitar los nuevos sitios
a2ensite "$PROJECT_FOLDER.conf" > /dev/null
a2ensite "$PROJECT_FOLDER-ssl.conf" > /dev/null
echo -e "☑️ Vhosts de la aplicación habilitados.\n"

echo "--- 4.3 Recargando Apache para aplicar los cambios ---"
# Recargar Apache para aplicar los cambios
systemctl reload apache2
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al recargar Apache2. Revisa los logs y la sintaxis de los Vhosts."
    exit 1
else
	systemctl status apache2 | grep Loaded
	systemctl status apache2 | grep Active
	echo "️☑️ No habido errores al recargar Apache2 con los cambios efectuados."
fi

echo -e "\n"
echo -e "--- 🟢 CONFIGURACIÓN DE APACHE FINALIZADA 🟢 ---\n"
echo -e "La aplicación debería estar disponible en https://$DOMAIN_NAME \n"