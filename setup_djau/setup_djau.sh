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
	echo -e "\n"
    exit 1
fi

echo -e "\n"
echo -e "${C_PRINCIPAL}==============================================================="
echo -e "${C_PRINCIPAL}--- CONFIGURACIÓN DE DJANGO Y BASE DE DATOS${RESET} ${CIANO}(setup_djau.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}===============================================================${RESET}"

# ------------------------------------------------------------------------------------------
# 1. PREPARACIÓN DEL ENTORNO, CARGA DE VARIABLES COMPARTIDAS, AJUSTE DE RUTA Y BASE DE DATOS
# ------------------------------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}============================================================="
echo -e "${C_CAPITULO}--- 1. PREPARACIÓN DE LOS PARÁMETRO PARA LA BASE DE DATOS ---"
echo -e "${C_CAPITULO}=============================================================${RESET}"
echo -e "\n"

# 1.1 Solicitud de Parámetros de la Base de Datos

echo -e "${C_SUBTITULO}--- Solicitud de Parámetros de PostgreSQL ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------${RESET}"

read_prompt "Introduzca el NOMBRE de la BASE DE DATOS (por defecto: djau_db): " DB_NAME "djau_db"
read_prompt "Introduzca el USUARIO de la BD (por defecto: djau): " DB_USER "djau"

# Validación de contraseñas
while true; do
    read -sp "Introduzca la CONTRASEÑA para el usuario $DB_USER de la BD: " DB_PASS
    echo
    read -sp "Repita la CONTRASEÑA: " DB_PASS2
    echo 

    if [ -z "$DB_PASS" ] || [ -z "$DB_PASS2" ]; then
        echo -e "${C_ERROR}❌ ERROR: La contraseña no puede dejarse en blanco. Inténtelo de nuevo.${RESET}\n"
    elif [ "$DB_PASS" != "$DB_PASS2" ]; then
        echo -e "${C_ERROR}❌ ERROR: Las contraseñas no coinciden. Inténtelo de nuevo.${RESET}\n"
    else
        break
    fi
done
echo -e "\n"
echo -e "${C_EXITO}☑️ Parámetros de la Base de Datos definidos.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 2. CONFIGURACIÓN DEL ENTORNO VIRTUAL Y CLAVE SECRETA
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}===================================================="
echo -e "${C_CAPITULO}--- 2. PREPARACIÓN DEL ENTORNO VIRTUAL DE DJANGO ---"
echo -e "${C_CAPITULO}====================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 2.1 Creando Entorno Virtual (venv) e instalando requerimientos ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------------------------${RESET}"

cd "$FULL_PATH"

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip wheel
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar las dependencias de Python. Saliendo.${RESET}"
	echo -e "\n"
    deactivate
	echo -e "\n"
    exit 1
fi
echo -e "\n"
echo -e "${C_EXITO}✅ Entorno virtual creado y paquetes instalados.${RESET}"
echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 2.2 Generando Clave Secreta de Django ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------${RESET}"

SECRET_KEYPASS=$(python manage.py generate_secret_key 2>&1)

if [ ${#SECRET_KEYPASS} -lt 32 ]; then
    echo -e "${C_ERROR}❌ ERROR: No se pudo generar una clave secreta válida. Saliendo.${RESET}"
    deactivate
	echo -e "\n"
    exit 1
fi

# FILTRADO ROBUSTO DE LA SECRET_KEYPASS:
# 1. Eliminamos retornos de carro/saltos de línea.
# 2. Usamos 'printf' para construir una cadena con la clave y la pasamos a 'tr'.
#    El comando 'tr' filtra TODOS los caracteres conflictivos de Bash/Sed/Python:
#    | (delimitador), #, /, &, \, '
FILTER_CHARS='|#/&\\'\'
REPLACEMENT_CHARS='------'

# Ejecutamos el filtro:
SECRET_KEYPASS_FILTERED=$(printf "%s" "$SECRET_KEYPASS" | tr -d '\n\r' | tr "$FILTER_CHARS" "$REPLACEMENT_CHARS")

echo -e "${C_EXITO}✅ Clave secreta generada automáticamente.${RESET}"


sleep 3

# ----------------------------------------------------------------------
# 3. CREACIÓN Y CONFIGURACIÓN DE POSTGRESQL
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}==============================================================="
echo -e "${C_CAPITULO}--- 3. CREACIÓN Y CONFIGURACIÓN DE BASE DE DATOS POSTGRESQL ---"
echo -e "${C_CAPITULO}===============================================================${RESET}"
echo -e "\n"

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
# 4. PERSONALIZACIÓN DEL ARCHIVO settings_local.py
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}========================================================"
echo -e "${C_CAPITULO}--- 4. PERSONALIZACIÓN DEL ARCHIVO${RESET} ${CIANO}settings_local.py${RESET} ${C_CAPITULO}---"
echo -e "${C_CAPITULO}========================================================${RESET}"
echo -e "\n"

# --- 4.1 Solicitud de Parámetros de la Aplicación (Usuario) ---
echo -e "${C_SUBTITULO}--- 4.1 Parámetros de la Aplicación ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------${RESET}"

read_prompt "Introduzca el nombre del CENTRO EDUCATIVO (por defecto: Centre de Demo): " NOM_CENTRE "Centre de Demo"
read_prompt "Introduzca la LOCALIDAD del centro educativo (por defecto: Badia del Vallés): " LOCALITAT "Badia del Vallés"
read_prompt "Introduzca el CÓDIGO del centro (por defecto: 00000000): " CODI_CENTRE "00000000"
read_prompt "Introduzca la URL base de la aplicación (por defecto: https://djau.elteudomini.cat): " DOMAIN_NAME "https://djau.elteudomini.cat"
read_prompt "Introduzca los HOSTS permitidos separados por comas. (por defecto: djau.elteudomini.cat,127.0.0.1): " ALLOWED_HOSTS_LIST "djau.elteudomini.cat,127.0.0.1"
read_prompt "Introduzca la dirección de CORREO del administrador (por defecto: ui@mega.cracs.cat): " ADMIN_EMAIL "ui@mega.cracs.cat"
echo -e "\n"
echo -e "${C_EXITO}☑️ Parámetros generales definidos.${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 4.2 Parámetros de Correo SMTP (Google/App Password) ---${RESET}"
echo -e "${C_SUBTITULO}-----------------------------------------------------------${RESET}"

echo -e "${C_INFO}ℹ️ Para el envío de correos se requiere una contraseña de aplicación de Google.${RESET}"
echo -e "    La información se puede encontrar aquí: ${C_SUBTITULO}'https://support.google.com/mail/answer/185833?hl=ca'${RESET}\n"

read_prompt "Introduzca el CORREO para envío SMTP (EMAIL_HOST_USER) (por defecto: djau@elteudomini.cat): " EMAIL_HOST_USER "djau@elteudomini.cat"

while true; do
    read -sp "Introduzca la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): " EMAIL_HOST_PASS
    echo
    read -sp "Repita la CONTRASEÑA: " EMAIL_HOST_PASS2
    echo -e "\n" 

    if [ -z "$EMAIL_HOST_PASS" ] || [ -z "$EMAIL_HOST_PASS2" ]; then
        echo -e "${C_ERROR}❌ ERROR: La contraseña no puede dejarse en blanco. Inténtelo de nuevo.${RESET}\n"
    elif [ "$EMAIL_HOST_PASS" != "$EMAIL_HOST_PASS2" ]; then
        echo -e "${C_ERROR}❌ ERROR: Las contraseñas no coinciden. Inténtelo de nuevo.${RESET}\n"
    else
        break
    fi
done

read_prompt "Introduzca el CORREO del servidor (SERVER_EMAIL/DEFAULT_FROM_EMAIL) (por defecto: djau@elteudomini.cat): " SERVER_MAIL "djau@elteudomini.cat"

echo -e "${C_EXITO}☑️ Parámetros SMTP definidos.${RESET}\n"
echo -e "\n"


# 4.3 Copiar y Aplicar Sustituciones

echo -e "${C_SUBTITULO}--- 4.3 Aplicando Sustituciones con 'sed' ---${RESET}"
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
sed -i "s#^URL_DJANGO_AULA = r'http://elteudomini.cat'#URL_DJANGO_AULA = r'$DOMAIN_NAME'#" "$SETTINGS_LOCAL_FINAL_FILE"

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
sed -i "s#^DEFAULT_FROM_EMAIL = 'El meu centre <no-reply@el-meu-centre.net>'#DEFAULT_FROM_EMAIL = '$NOM_CENTRE <$SERVER_MAIL>'#" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s/EMAIL_SUBJECT_PREFIX = .*/EMAIL_SUBJECT_PREFIX = '[Comunicació $NOM_CENTRE]'/" "$SETTINGS_LOCAL_FINAL_FILE"

# Forzar SSL en cookies si la URL es HTTPS (se asume que sí)
sed -i "s/^SESSION_COOKIE_SECURE=False/SESSION_COOKIE_SECURE=True/" "$SETTINGS_LOCAL_FINAL_FILE"
sed -i "s/^CSRF_COOKIE_SECURE=False/CSRF_COOKIE_SECURE=True/" "$SETTINGS_LOCAL_FINAL_FILE"

echo -e "${C_EXITO}✅ settings_local.py configurado y personalizado.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 5. MIGRACIONES Y CONFIGURACIÓN DE USUARIOS
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}==============================================================="
echo -e "${C_CAPITULO}--- 5. APLICACIÓN DE MIGRACIONES Y CONFIGURACIÓN DE USUARIO ---"
echo -e "${C_CAPITULO}===============================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 5.1 Aplicando Migraciones de Base de Datos ---${RESET}"
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

echo -e "${C_SUBTITULO}--- 5.2 Ejecutando el script${RESET} ${CIANO}fixtures.sh${RESET} ${C_SUBTITULO}---${RESET}"
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

echo -e "${C_SUBTITULO}--- 5.3 Creación de Superusuario 'admin' en la aplicación DJANGO ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------------${RESET}"


# 1. SOLICITAR EL EMAIL
read_prompt "Introduce el CORREO ELECTRÓNICO para el superusuario 'admin': " ADMIN_EMAIL

# 2. SOLICITAR Y VALIDAR LA CONTRASEÑA

while true; do
    read -sp "Introduzca la CONTRASEÑA para el superusuario 'admin': " ADMIN_PASS
    echo
    read -sp "Repita la CONTRASEÑA: " ADMIN_PASS2
    echo -e "\n" 

    if [ -z "$ADMIN_PASS" ] || [ -z "$ADMIN_PASS2" ]; then
        echo -e "${C_ERROR}❌ ERROR: La contraseña no puede dejarse en blanco. Inténtelo de nuevo.${RESET}\n"
    elif [ "$ADMIN_PASS" != "$ADMIN_PASS2" ]; then
        echo -e "${C_ERROR}❌ ERROR: Las contraseñas no coinciden. Inténtelo de nuevo.${RESET}\n"
    else
        break
    fi
done

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

echo -e "${C_SUBTITULO}--- 5.4 Creando Grupos y asignando a 'admin' ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------${RESET}"


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
# 6. RECOLECCIÓN DE ESTÁTICOS Y FINALIZACIÓN
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================"
echo -e "${C_CAPITULO}--- 6. RECOLECCIÓN DE ARCHIVOS ESTÁTICOS ---"
echo -e "${C_CAPITULO}============================================${RESET}"
echo -e "\n"

python manage.py collectstatic -c --no-input

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al recolectar archivos estáticos.${RESET}"
    deactivate
	echo -e "\n"
    exit 1
fi
echo -e "\n"
echo -e "${C_EXITO}✅ Archivos estáticos recolectados.${RESET}"

deactivate
sleep 3

# ===================================================================
# 7. GUARDAR VARIABLES EN config_vars.sh QUE SERÁN NECESARIAS
# ===================================================================

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================================================"
echo -e "${C_CAPITULO}--- 7. ACTUALIZACIÓN DEL ARCHIVO DE VARIABLES COMUNES PARA LOS SCRIPTS DE AUTOMATIZACIÓN ---"
echo -e "${C_CAPITULO}============================================================================================${RESET}"
echo -e "\n"

echo -e "${C_INFO}--- Añadiendo variables al archivo${RESET} ${CIANO}config_vars.sh${RESET} ${C_INFO}automáticamente ---${RESET}\n"

# Añadir la nueva información al archivo (usamos >> para append)
# El archivo está en $SETUP_DIR

echo "export DB_NAME='$DB_NAME'" >> "$SETUP_DIR/config_vars.sh"
echo "export DB_USER='$DB_USER'" >> "$SETUP_DIR/config_vars.sh"
echo "export DOMAIN_NAME='$DOMAIN_NAME'" >> "$SETUP_DIR/config_vars.sh"
echo "export LOCALITAT='$LOCALITAT'" >> "$SETUP_DIR/config_vars.sh"

# Reasignar permisos de forma preventiva
chmod 600 "$SETUP_DIR/config_vars.sh"
chown "$APP_USER":"$APP_USER" "$SETUP_DIR/config_vars.sh"

echo -e "${C_EXITO}✅ Credenciales de BD añadidas a${RESET} ${CIANO}config_vars.sh${RESET}${C_EXITO}.${RESET}"
echo -e "\n"

echo -e "\n"
echo -e "${C_PRINCIPAL}======================================================================================"
echo -e "${C_PRINCIPAL}--- COMPLETADA LA CONFIGURACIÓN BÁSICA GESTIONADA PARA DJANGO-AULA${RESET} ${CIANO}(setup_djau.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}Devolviendo el control al script${RESET} ${CIANO}(install_djau.sh)${RESET}"
echo -e "${C_PRINCIPAL}======================================================================================${RESET}"
echo -e "\n"
