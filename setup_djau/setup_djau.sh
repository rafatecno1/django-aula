#!/bin/bash
# setup_djau.sh
# Configura el entorno virtual, la base de datos PostgreSQL, 
# y personaliza el archivo settings_local.py para la aplicación Django.
# DEBE EJECUTARSE como el usuario de la aplicación (djau).

clear

# ----------------------------------------------------------------------
# CARGA DE VARIABLES Y FUNCIONES COMUNES A LOS SCRIPTS DE AUTOMATIZACIÓN
# ----------------------------------------------------------------------
echo -e "\n"
echo -e "Ejecutando script setup_djau.sh."
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
	echo -e "\n"
    exit 1
fi

echo -e "\n\n"
echo -e "${C_PRINCIPAL}==============================================================="
echo -e "${C_PRINCIPAL}--- CONFIGURACIÓN DE DJANGO Y BASE DE DATOS${RESET} ${CIANO}(setup_djau.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}===============================================================${RESET}"

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================"
echo -e "${C_CAPITULO}--- 1. ENTORNO VIRTUAL (venv) DE DJANGO Y REQUERIMIENTOS ---"
echo -e "${C_CAPITULO}============================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 1.1 Creando Entorno Virtual (venv) ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------${RESET}"

cd "$FULL_PATH"

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip wheel

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar el entorno virtual (venv) o pip o wheel. Saliendo.${RESET}"
	echo -e "\n"
    deactivate
	echo -e "\n"
    exit 1
fi
echo -e "\n"
echo -e "${C_EXITO}✅ Entorno virtual creado y los paquetes pip y wheel instalados.${RESET}"
echo -e "\n"


echo -e "${C_SUBTITULO}--- 1.2 Instalando requerimientos de Django-Aula ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------${RESET}"

pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar las dependencias de Python requeridas para Django-Aula. Saliendo.${RESET}"
	echo -e "\n"
    deactivate
	echo -e "\n"
    exit 1
fi
echo -e "\n"
echo -e "${C_EXITO}✅ Dependencias de Python requeridas para Django-Aula instaladas.${RESET}"
echo -e "\n"
sleep 3

echo -e "\n"
echo -e "${C_CAPITULO}======================================================================="
echo -e "${C_CAPITULO}--- 2. POSTGRESQL, PARÁMETROS PARA LA BASE DE DATOS Y SU GENERACIÓN ---"
echo -e "${C_CAPITULO}=======================================================================${RESET}"
echo -e "\n"

# 2.1 Solicitud de Parámetros de la Base de Datos

echo -e "${C_SUBTITULO}--- 2.1 Solicitud de parámetros par la base de datos en PostgreSQL ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------------------------${RESET}"

read_prompt "Introduzca el NOMBRE de la BASE DE DATOS en PostgreSQL (por defecto: djau_db): " DB_NAME "djau_db"
read_prompt "Introduzca el USUARIO de la BASE DE DATOS en PostgreSQL (por defecto: djau): " DB_USER "djau"

# Validación de contraseñas

read_password_confirm "Introduzca la CONTRASEÑA para el usuario $DB_USER de la BD en PostgreSQL: " DB_PASS

echo -e "\n"
echo -e "${C_EXITO}☑️ Los parámetros de la Base de Datos en PostgreSQL han sido definidos.${RESET}"
echo -e "\n"
sleep 3

# 2.2 Creación y configuración interna de la base de datos en PostgreSQL

echo -e "${C_SUBTITULO}--- 2.2 Creación y configuración interna de la base de datos en PostgreSQL ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------------------------${RESET}"


# Crear el script SQL temporal
SQL_FILE="temp_setup_${DB_NAME}.sql"

cat << EOF > "$SQL_FILE"
DROP DATABASE IF EXISTS $DB_NAME;
DROP ROLE IF EXISTS $DB_USER;
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
EOF

echo -e "\n"
echo -e "${C_INFO}--- Ejecutando Script SQL con 'psql' (NOPASSWD) ---${RESET}"

# Se ejecuta con NOPASSWD configurado en el script padre, la salida se redirige a /dev/null
sudo -u postgres psql -t -f "$SQL_FILE" > /dev/null 2>&1 

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al configurar PostgreSQL. Revisa la regla NOPASSWD o la sintaxis SQL.${RESET}"
    rm "$SQL_FILE"
    deactivate
	echo -e "\n"
    exit 1
fi
rm "$SQL_FILE"

echo -e "\n"
echo -e "${C_EXITO}✅ Base de datos '$DB_NAME' y usuario '$DB_USER' configurados en PostgreSQL.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 3. PERSONALIZACIÓN DEL ARCHIVO settings_local.py
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}========================================================"
echo -e "${C_CAPITULO}--- 3. PERSONALIZACIÓN DEL ARCHIVO${RESET} ${CIANO}settings_local.py${RESET} ${C_CAPITULO}---"
echo -e "${C_CAPITULO}========================================================${RESET}"
echo -e "\n"

# --- 3.1 Solicitud de Parámetros de la Aplicación (Usuario) ---

echo -e "${C_SUBTITULO}--- 3.1 Preguntas para la definición de variables y parámetros críticos para la aplicación ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------------------------------------------------${RESET}"

# 0. Obtener los datos del centro educativo
read_prompt "Introduzca el nombre del CENTRO EDUCATIVO (por defecto: Centre de Demo): " NOM_CENTRE "Centre de Demo"
read_prompt "Introduzca la LOCALIDAD del centro educativo (por defecto: Badia del Vallés): " LOCALITAT "Badia del Vallés"
read_prompt "Introduzca el CÓDIGO del centro (por defecto: 00000000): " CODI_CENTRE "00000000"

# 1. Obtener el dominio base (limpio)
read_prompt "Introduzca el nombre de dominio o subdominio para la aplicación (ej: djau.elteudomini.cat): " DOMAIN_NAME_CLEAN "djau.elteudomini.cat"

# 2. Definir cómo será el entorno donde la aplicación esté funcionando (Interno vs. Público)
echo -e "${C_INFO}Cuando la aplicación esté en producción puede ser servida de dos maneras:${RESET}"
echo -e "${C_INFO}   - o en una RED INTERNA (Servidor local dentro de un edificio) por HTTP sin certificados de seguridad SSL.${RESET}"
echo -e "${C_INFO}   - o desde internet, de forma PÚBLICA por HTTPS con certificados autofirmados sin confianza pública o con certificados gratuitos Let's Encrypt de confianza.${RESET}"
echo -e "\n"

read_prompt "¿Cómo quiere servir la aplicación, desde una RED INTERNA (HTTP sin certificados de seguridad SSL) o desde internet de forma PÚBLICA (HTTPS con certificados)? (INT/PUB - Enter para PUB): " INSTALL_TYPE "PUB"
INSTALL_TYPE_LOWER=$(echo "$INSTALL_TYPE" | tr '[:upper:]' '[:lower:]')

# 3. Limpiar el dominio introducido por el usuario y Definir la URL de Acceso según su protocolo de acceso (PROTOCOL_URL y DOMAIN_CLEAN)
# Limpieza forzada: Asegura que no hay protocolo en DOMAIN_CLEAN, por si el usuario lo añadió.
DOMAIN_CLEAN=$(echo "$DOMAIN_NAME_CLEAN" | sed -e 's|^http[s]*://||')

# Definir la URL completa (con protocolo http o https), basándose en el tipo de instalación
if [[ "$INSTALL_TYPE_LOWER" == "int" ]]; then
    PROTOCOL_URL="http://$DOMAIN_CLEAN"
else
    # Por defecto, PÚBLICO siempre usa HTTPS (incluso si Certbot falla, usará el Self-Signed)
    PROTOCOL_URL="https://$DOMAIN_CLEAN"
fi

# 4. Generar la lista de ALLOWED_HOSTS (incluyendo www. y 127.0.0.1)
# ----------------------------------------------------------------------

# 4.1. Comprobación de la variante WWW: Si el dominio limpio NO empieza por 'www.', la añadimos.
if [[ "$DOMAIN_CLEAN" != www.* ]]; then
    WWW_DOMAIN="www.$DOMAIN_CLEAN"
else
    WWW_DOMAIN="" # La variante WWW ya es el dominio principal.
fi

# 4.2. Construir la lista final de ALLOWED_HOSTS
ALLOWED_HOSTS_LIST="127.0.0.1,$DOMAIN_CLEAN"

if [ -n "$WWW_DOMAIN" ]; then
    ALLOWED_HOSTS_LIST="$ALLOWED_HOSTS_LIST,$WWW_DOMAIN"
fi

echo -e "${C_INFO}ℹ️ Lista de ALLOWED_HOSTS generada: ${CIANO}$ALLOWED_HOSTS_LIST${RESET}"
echo -e "${C_INFO}ℹ️ URL de Acceso generada: ${CIANO}$PROTOCOL_URL${RESET}"
echo -e "\n"

# 5. Definir el correo del administrador del dominio
read_prompt "Introduzca la dirección de CORREO del administrador (por defecto: ui@mega.cracs.cat): " ADMIN_EMAIL "ui@mega.cracs.cat"


#read_prompt "Introduzca la URL base de la aplicación (por defecto: https://djau.elteudomini.cat): " DOMAIN_NAME "https://djau.elteudomini.cat"
#read_prompt "Introduzca los HOSTS permitidos separados por comas. (por defecto: djau.elteudomini.cat,127.0.0.1): " ALLOWED_HOSTS_LIST "djau.elteudomini.cat,127.0.0.1"


echo -e "${C_EXITO}☑️ Variables y parámetros generales definidos.${RESET}"
echo -e "\n"

# --- 3.2 Parámetros de Correo SMTP (Google/App Password) ---

echo -e "${C_SUBTITULO}--- 3.2 Parámetros de Correo SMTP (Google/App Password) ---${RESET}"
echo -e "${C_SUBTITULO}-----------------------------------------------------------${RESET}"

echo -e "${C_INFO}ℹ️ Para el envío de correos se requiere una contraseña de aplicación de Google.${RESET}"
echo -e "    La información se puede encontrar aquí: ${C_SUBTITULO}'https://support.google.com/mail/answer/185833?hl=ca'${RESET}\n"

read_email_confirm "Introduzca el CORREO para envío SMTP (EMAIL_HOST_USER) (por defecto: djau@elteudomini.cat): " EMAIL_HOST_USER "djau@elteudomini.cat"
read_password_confirm "Introduzca la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): " EMAIL_HOST_PASS
read_prompt "Introduzca el CORREO del servidor (SERVER_EMAIL/DEFAULT_FROM_EMAIL) (por defecto: $EMAIL_HOST_USER): " SERVER_MAIL "$EMAIL_HOST_USER"

echo -e "${C_EXITO}☑️ Parámetros SMTP definidos.${RESET}\n"
echo -e "\n"

# --- 3.3 Generando Clave Secreta de Django ---

echo -e "${C_SUBTITULO}--- 3.3 Generando Clave Secreta de Django ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------${RESET}"

# Genera 50 bytes aleatorios, los codifica en base64, y toma los primeros 50 caracteres.
SECRET_KEYPASS_RAW=$(openssl rand -base64 50 | head -c 50)

# 4. FILTRADO: Eliminar caracteres que rompen SED/Python (es necesario).
# Caracteres a eliminar: '|', '#', '/', '&', '\', '$', y las comillas simples o dobles.
# Sintaxis corregida para Bash:
FILTER_CHARS='|#/&\\'\''"$'

SECRET_KEYPASS_FILTERED=$(printf "%s" "$SECRET_KEYPASS_RAW" | tr -d "$FILTER_CHARS")

# 5. Verificación de la longitud de la clave.
if [ ${#SECRET_KEYPASS_FILTERED} -lt 40 ]; then
    echo -e "${C_ERROR}❌ ERROR: No se pudo generar una clave secreta válida con OpenSSL. Saliendo.${RESET}"
    # Si la clave es demasiado corta, salimos.
    deactivate
    echo -e "\n"
    exit 1
fi

echo -e "${C_EXITO}✅ Clave secreta generada automáticamente.${RESET}"
echo -e "\n"
sleep 3

# 3.4 Copiar y Aplicar Sustituciones

echo -e "${C_SUBTITULO}--- 3.4 Aplicando Sustituciones con 'sed' ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------${RESET}"

SETTINGS_LOCAL_SAMPLE_FILE="aula/settings_local.sample"
SETTINGS_LOCAL_FINAL_FILE="aula/settings_local.py"

if [ ! -f "$SETTINGS_LOCAL_SAMPLE_FILE" ]; then
    echo -e "${C_ERROR}❌ ERROR: No se encontró el archivo sample en '$SETTINGS_LOCAL_SAMPLE_FILE'. Saliendo.${RESET}"
    deactivate
	echo -e "\n"
    exit 1
fi

cp "$SETTINGS_LOCAL_SAMPLE_FILE" "$SETTINGS_LOCAL_FINAL_FILE"

# Aplicando substituciones

#Base de Datos
sed -i "s#^        'NAME': 'djau2025',#        'NAME': '$DB_NAME',#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^        'USER': 'djau2025',#        'USER': '$DB_USER',#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^        'PASSWORD': \"XXXXXXXXXX\",#        'PASSWORD': \"$DB_PASS\",#" "$SETTINGS_LOCAL_FINAL_FILE"

# Variables de la aplicación:
sed -i "s#^NOM_CENTRE = 'Centre de Demo'#NOM_CENTRE = u'$NOM_CENTRE'#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^LOCALITAT = u\"Badia del Vallés\"#LOCALITAT = u\"$LOCALITAT\"#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^CODI_CENTRE = u\"00000000\"#CODI_CENTRE = u\"$CODI_CENTRE\"#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^URL_DJANGO_AULA = r'http://elteudomini.cat'#URL_DJANGO_AULA = r'$PROTOCOL_URL'#" "$SETTINGS_LOCAL_FINAL_FILE"

# ALLOWED_HOSTS
ALLOWED_HOSTS_PYTHON_LIST="'${ALLOWED_HOSTS_LIST//,/\', \'}'"
sed -i "s#^ALLOWED_HOSTS = \[ 'elteudomini.cat', '127.0.0.1', \]#ALLOWED_HOSTS = [ $ALLOWED_HOSTS_PYTHON_LIST, ]#" "$SETTINGS_LOCAL_FINAL_FILE"

# Clave Secreta y Datos Privados
sed -i "s|^SECRET_KEY = .*|SECRET_KEY = '$SECRET_KEYPASS_FILTERED'|" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^PRIVATE_STORAGE_ROOT =.*#PRIVATE_STORAGE_ROOT = '$PATH_DADES_PRIVADES'#" "$SETTINGS_LOCAL_FINAL_FILE"

# Datos de Email/Admin
sed -i "s#('admin', 'ui@mega.cracs.cat'),#('admin', '$ADMIN_EMAIL'),#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^EMAIL_HOST_USER='el-meu-centre@el-meu-centre.net'#EMAIL_HOST_USER='$EMAIL_HOST_USER'#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^EMAIL_HOST_PASSWORD='xxxx xxxx xxxx xxxx'#EMAIL_HOST_PASSWORD='$EMAIL_HOST_PASS'#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^SERVER_EMAIL='el-meu-centre@el-meu-centre.net'#SERVER_EMAIL='$SERVER_MAIL'#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s#^DEFAULT_FROM_EMAIL = 'El meu centre <no-reply@el-meu-centre.net>'#DEFAULT_FROM_EMAIL = '$NOM_CENTRE - NO RESPONDER - <$SERVER_MAIL>'#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s/EMAIL_SUBJECT_PREFIX = .*/EMAIL_SUBJECT_PREFIX = '[Comunicació $NOM_CENTRE]'/" "$SETTINGS_LOCAL_FINAL_FILE"

# Lógica para SSL en Django Settings (SESSION/CSRF_COOKIE_SECURE)
if [[ "$INSTALL_TYPE_LOWER" == "int" ]]; then
    # Entorno Interno (HTTP)
    sed -i "s/^SESSION_COOKIE_SECURE=True/SESSION_COOKIE_SECURE=False/" "$SETTINGS_LOCAL_FINAL_FILE"
    sed -i "s/^CSRF_COOKIE_SECURE=True/CSRF_COOKIE_SECURE=False/" "$SETTINGS_LOCAL_FINAL_FILE"
else
    # Entorno Público (HTTPS)
    sed -i "s/^SESSION_COOKIE_SECURE=False/SESSION_COOKIE_SECURE=True/" "$SETTINGS_LOCAL_FINAL_FILE"
    sed -i "s/^CSRF_COOKIE_SECURE=False/CSRF_COOKIE_SECURE=True/" "$SETTINGS_LOCAL_FINAL_FILE"
fi

echo -e "${C_EXITO}✅ settings_local.py configurado y personalizado.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 4. MIGRACIONES Y CONFIGURACIÓN DE USUARIOS
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}==============================================================="
echo -e "${C_CAPITULO}--- 4. APLICACIÓN DE MIGRACIONES Y CONFIGURACIÓN DE USUARIO ---"
echo -e "${C_CAPITULO}===============================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 4.1 Aplicando Migraciones de Base de Datos ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------${RESET}"

python manage.py migrate --noinput

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al aplicar las migraciones. Revisa la conexión a la Base de Datos.${RESET}"
	echo -e "\n"
    deactivate
	echo -e "\n"
    exit 1
fi
echo -e "\n"
echo -e "${C_EXITO}✅ Migraciones aplicadas correctamente.${RESET}"
echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 4.2 Ejecutando el script${RESET} ${CIANO}fixtures.sh${RESET} ${C_SUBTITULO}---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------${RESET}"

if [ -f "scripts/fixtures.sh" ]; then
    bash scripts/fixtures.sh
	echo -e "\n"
    if [ $? -ne 0 ]; then
        echo -e "${C_ERROR}❌ Advertencia: Fallo al ejecutar 'scripts/fixtures.sh'.${RESET}"
    fi
    echo -e "${C_EXITO}✅ Fixtures ejecutados.${RESET}"
else
    echo -e "${C_ERROR}❌ scripts/fixtures.sh no encontrado. Paso omitido.${RESET}"
fi

echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 4.3 Creación de Superusuario 'admin' en la aplicación DJANGO ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------------${RESET}"


# 1. SOLICITAR EL EMAIL
read_prompt "Introduce el CORREO ELECTRÓNICO para el superusuario 'admin' de la aplicación DJANGO: " ADMIN_EMAIL

# 2. SOLICITAR Y VALIDAR LA CONTRASEÑA
read_password_confirm "Introduzca la CONTRASEÑA para el superusuario 'admin': " ADMIN_PASS

echo -e "${C_INFO}--- Creando Superusuario 'admin' automáticamente ---${RESET}\n"

# 3. CREAR EL SCRIPT DE PYTHON TEMPORAL

PYTHON_SCRIPT="temp_create_admin.py"

cat << EOF > "$PYTHON_SCRIPT"
from django.contrib.auth.models import User
import sys

try:
    # 1. Intentar obtener el usuario. Si no existe, lanza la excepción DoesNotExist.
    try:
        user = User.objects.get(username='admin')
        
        # 2. Si existe, actualizar sus credenciales.
        user.email = '${ADMIN_EMAIL}'
        user.set_password('${ADMIN_PASS}') # set_password maneja el hashing de la contraseña
        user.is_superuser = True
        user.is_staff = True
        user.save()
        sys.stdout.write("☑️ Superusuario 'admin' actualizado correctamente.\n")

    except User.DoesNotExist:
        # 3. Si no existe, crearlo.
        User.objects.create_superuser(
            username='admin',
            email='${ADMIN_EMAIL}',
            password='${ADMIN_PASS}'
        )
        sys.stdout.write("✅ Superusuario 'admin' creado automáticamente.\n")

except Exception as e:
    sys.stdout.write(f"❌ Error al procesar superusuario: {e}\n")
    sys.exit(1)
EOF

# 4. EJECUTAR EL SCRIPT

python3 manage.py shell < "$PYTHON_SCRIPT"

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ Error al ejecutar el script de creación de superusuario. Revisa el log.${RESET}"
fi

rm "$PYTHON_SCRIPT"

echo -e "\n"

echo -e "${C_SUBTITULO}--- 4.4 Creando Grupos y asignando al usuario dministrador de Django-Aula 'admin' ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------------------------${RESET}"


PYTHON_SCRIPT="temp_setup_groups.py"

cat << EOF > "$PYTHON_SCRIPT"
from django.contrib.auth.models import User, Group
try:
    g1, _ = Group.objects.get_or_create( name = 'direcció' )
    g2, _ = Group.objects.get_or_create( name = 'professors' )
    g3, _ = Group.objects.get_or_create( name = 'professional' )
    admin_user = User.objects.get( username = 'admin' )
    admin_user.groups.set( [ g1, g2, g3 ] )
    admin_user.save()
    print("✅ Grupos creados y asignados al usuario 'admin' correctamente.")
except Exception as e:
    print(f"❌ Error al configurar grupos: {e}")
    exit(1)
EOF

python manage.py shell < "$PYTHON_SCRIPT" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ Error al ejecutar el script de configuración de grupos.${RESET}"
fi

rm "$PYTHON_SCRIPT"

echo -e "${C_EXITO}✅ Grupos configurados.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 5. RECOLECCIÓN DE ESTÁTICOS Y FINALIZACIÓN
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================"
echo -e "${C_CAPITULO}--- 5. RECOLECCIÓN DE ARCHIVOS ESTÁTICOS ---"
echo -e "${C_CAPITULO}============================================${RESET}"
echo -e "\n"

python manage.py collectstatic -c --no-input

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al recolectar archivos estáticos.${RESET}"
    deactivate
	echo -e "\n"
    exit 1
fi
echo -e "${C_EXITO}✅ Archivos estáticos recolectados.${RESET}"

deactivate
sleep 3

# ===================================================================
# 6. GUARDAR VARIABLES EN config_vars.sh QUE SERÁN NECESARIAS
# ===================================================================

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================================================"
echo -e "${C_CAPITULO}--- 6. ACTUALIZACIÓN DEL ARCHIVO DE VARIABLES COMUNES PARA LOS SCRIPTS DE AUTOMATIZACIÓN ---"
echo -e "${C_CAPITULO}============================================================================================${RESET}"
echo -e "\n"

echo -e "${C_INFO}--- Añadiendo variables al archivo${RESET} ${CIANO}config_vars.sh${RESET} ${C_INFO}automáticamente ---${RESET}\n"

# Añadir la nueva información al archivo (usamos >> para append)
# El archivo está en $SETUP_DIR

echo "export DB_NAME='$DB_NAME'" >> "$SETUP_DIR/config_vars.sh"
echo "export DB_USER='$DB_USER'" >> "$SETUP_DIR/config_vars.sh"
echo "export LOCALITAT='$LOCALITAT'" >> "$SETUP_DIR/config_vars.sh"

#echo "export DOMAIN_NAME='$DOMAIN_NAME'" >> "$SETUP_DIR/config_vars.sh"
echo "export DOMAIN_CLEAN='$DOMAIN_CLEAN'" >> "$SETUP_DIR/config_vars.sh"                           # El dominio puro para Apache VHosts.
echo "export PROTOCOL_URL='$PROTOCOL_URL'" >> "$SETUP_DIR/config_vars.sh"                           # La URL con http o https para el mensaje final.
echo "export ALLOWED_HOSTS_LIST='$ALLOWED_HOSTS_LIST'" >> "$SETUP_DIR/config_vars.sh"               # Lista para uso general/informativo en Bash (separada por comas)
echo "export ALLOWED_HOSTS_PYTHON_LIST='$ALLOWED_HOSTS_PYTHON_LIST'" >> "$SETUP_DIR/config_vars.sh" # Lista con formato Python para inyectar en settings.py (separada por comas y entre comillas simples)
echo "export INSTALL_TYPE_LOWER='$INSTALL_TYPE_LOWER'" >> "$SETUP_DIR/config_vars.sh"               # Para la lógica condicional en un servidor web como Apache (setup_apache.sh)

# Reasignar permisos de forma preventiva
chmod 600 "$SETUP_DIR/config_vars.sh"
chown "$APP_USER":"$APP_USER" "$SETUP_DIR/config_vars.sh"

echo -e "${C_EXITO}✅ Credenciales de BD añadidas a${RESET} ${CIANO}config_vars.sh${RESET}${C_EXITO}.${RESET}"
echo -e "\n"

echo -e "\n"
echo -e "${C_CAPITULO}============================================${RESET}"
echo -e "${C_CAPITULO}--- 7. VERIFICACIÓN DE CORREO (Opcional) ---${RESET}"
echo -e "${C_CAPITULO}============================================${RESET}"
echo -e "\n"

# 1. Dar permisos de ejecución al nuevo script
cd "$SETUP_DIR"
chmod +x ./test_email.sh

read_prompt "¿Desea ejecutar el script de prueba de correo (./test_email.sh) ahora? (sí/NO - Enter para NO): " TEST_EMAIL_NOW "no"

TEST_EMAIL_NOW_LOWER=$(echo "$TEST_EMAIL_NOW" | tr '[:upper:]' '[:lower:]')

if [[ "$TEST_EMAIL_NOW_LOWER" == "sí" ]] || [[ "$TEST_EMAIL_NOW_LOWER" == "si" ]]; then
    echo -e "${C_INFO}ℹ️ Iniciando una prueba del sistema de correo configurado para $EMAIL_HOST_USER...${RESET}"
    bash test_email.sh
else
    echo -e "${C_INFO}ℹ️ Omitiendo la prueba inicial del sistema de correo configurado para $EMAIL_HOST_USER.${RESET}"
fi

# 2. Informar al usuario sobre el posible uso futuro del archivo de test de correo.
echo -e "${C_INFO}Siempre puede ejecutar el script de prueba de correo en cualquier momento desde el terminal de Linux con:${RESET} ${C_SUBTITULO}cd $SETUP_DIR${RESET} ${C_INFO}y${RESET} ${C_SUBTITULO}bash test_email.sh${RESET}"
echo -e "\n"
sleep 2

echo -e "\n"
echo -e "${C_PRINCIPAL}======================================================================================"
echo -e "${C_PRINCIPAL}--- COMPLETADA LA CONFIGURACIÓN BÁSICA GESTIONADA PARA DJANGO-AULA${RESET} ${CIANO}(setup_djau.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}Devolviendo el control al script${RESET} ${CIANO}(install_djau.sh)${RESET}"
echo -e "${C_PRINCIPAL}======================================================================================${RESET}"
echo -e "\n"
