#!/bin/bash
# setup_djau.sh
# Configura el entorno virtual, la base de datos PostgreSQL, 
# y personaliza el archivo settings_local.py para la aplicación Django.
# DEBE EJECUTARSE como el usuario de la aplicación (djau).

echo -e "\n"
echo "==========================================================================="
echo "--- 🟢 FASE 2: CONFIGURACIÓN DE DJANGO Y BASE DE DATOS setup_djau.sh 🟢 ---"
echo "==========================================================================="
echo -e "\n"

# ----------------------------------------------------------------------
# FUNCIONES DE AYUDA (Lectura de entrada con valor por defecto)
# ----------------------------------------------------------------------

read_prompt () {
    # $1: Mensaje (prompt)
    # $2: Nombre de la variable a asignar (sin $)
    # $3: [Opcional] Valor por defecto (si se omite o es vacío, el campo es obligatorio)

    local PROMPT_MSG="$1"
    local VAR_NAME="$2"
    local DEFAULT_VALUE="$3"
    local INPUT_VALUE=""

    while true; do
        # 1. Leer la entrada del usuario
        read -p "$PROMPT_MSG" INPUT_VALUE

        # 2. Eliminar espacios en blanco alrededor (trim)
        INPUT_VALUE=$(echo "$INPUT_VALUE" | xargs)

        if [ -z "$INPUT_VALUE" ]; then
            # A) Si no hay entrada del usuario:
            
            if [ -n "$DEFAULT_VALUE" ]; then
                # A.1) Si hay valor por defecto ($3 no está vacío), usarlo y salir.
                eval "$VAR_NAME='$DEFAULT_VALUE'"
                echo "☑️ Valor por defecto usado: '$DEFAULT_VALUE'"
                break
            else
                # A.2) Si NO hay valor por defecto, el campo es obligatorio.
                echo "❌ ERROR: Este campo no puede dejarse en blanco."
                # Vuelve a iterar el bucle (while true)
            fi
        else
            # B) Si hay entrada del usuario, usarla y salir.
            eval "$VAR_NAME='$INPUT_VALUE'"
            echo "☑️ Valor introducido: '$INPUT_VALUE'"
            break
        fi
    done
}




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
	echo -e "\n"
}

# ------------------------------------------------------------------------------------------
# 1. PREPARACIÓN DEL ENTORNO, CARGA DE VARIABLES COMPARTIDAS, AJUSTE DE RUTA Y BASE DE DATOS
# ------------------------------------------------------------------------------------------

echo "====================================================================================================="
echo "--- 📝 1. PREPARACIÓN DEL ENTORNO, CARGA DE VARIABLES COMPARTIDAS, AJUSTE DE RUTA Y BASE DE DATOS ---"
echo "====================================================================================================="
echo -e "\n"

# 1.1 Càrrega de variables comunes
echo "--- 1.1 Càrrega de variables comunes per la instalación ---"

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

#echo "Ruta de datos privados: $PATH_DADES_PRIVADES"
echo -e "\n"


# 1.2 Solicitud de Parámetros de la Base de Datos
echo "--- 1.2 Solicitud de Parámetros de PostgreSQL ---"
echo -e "\n"

# La función read_and_validate ya no permite dejar campos en blanco.
read_prompt "Introduzca el NOMBRE de la BASE DE DATOS (por defecto: djau_db): " DB_NAME "djau_db"
read_prompt "Introduzca el USUARIO de la BD (por defecto: djau): " DB_USER "djau"

# Validación de contraseñas
while true; do
    read -sp "Introduzca la CONTRASEÑA para el usuario $DB_USER de la BD: " DB_PASS
    echo
    read -sp "Repita la CONTRASEÑA: " DB_PASS2
    echo 

    if [ -z "$DB_PASS" ] || [ -z "$DB_PASS2" ]; then
        echo -e "❌ ERROR: La contraseña no puede dejarse en blanco. Inténtelo de nuevo.\n"
    elif [ "$DB_PASS" != "$DB_PASS2" ]; then
        echo -e "❌ ERROR: Las contraseñas no coinciden. Inténtelo de nuevo.\n"
    else
        break
    fi
done
echo -e "\n"
echo "☑️ Parámetros de la Base de Datos definidos."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 2. CONFIGURACIÓN DEL ENTORNO VIRTUAL Y CLAVE SECRETA
# ----------------------------------------------------------------------

echo "======================================================="
echo "--- ⚙️ 2. PREPARACIÓN DEL ENTORNO VIRTUAL DE DJANGO ---"
echo "======================================================="
echo -e "\n"

echo -e "--- 2.1 Creando Entorno Virtual (venv) e instalando requisitios ---\n"

cd "$FULL_PATH"

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip wheel
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al instalar las dependencias de Python. Saliendo."
    deactivate
    exit 1
fi
echo -e "\n"
echo "✅ Entorno virtual creado y paquetes instalados."
echo -e "\n"
sleep 3

echo "--- 2.2 Generando Clave Secreta de Django ---"

SECRET_KEYPASS=$(python manage.py generate_secret_key 2>&1)

if [ ${#SECRET_KEYPASS} -lt 32 ]; then
    echo "❌ ERROR: No se pudo generar una clave secreta válida. Saliendo."
    deactivate
    exit 1
fi

# FILTRADO DEFINITIVO Y ROBUSTO:
# 1. Eliminamos retornos de carro/saltos de línea.
# 2. Usamos 'printf' para construir una cadena con la clave y la pasamos a 'tr'.
#    El comando 'tr' filtra TODOS los caracteres conflictivos de Bash/Sed/Python:
#    | (delimitador), #, /, &, \, '
FILTER_CHARS='|#/&\\'\'
REPLACEMENT_CHARS='------'

# Ejecutamos el filtro:
SECRET_KEYPASS_FILTERED=$(printf "%s" "$SECRET_KEYPASS" | tr -d '\n\r' | tr "$FILTER_CHARS" "$REPLACEMENT_CHARS")

echo "✅ Clave secreta generada y filtrada automáticamente."
echo -e "\n"

sleep 3

# ----------------------------------------------------------------------
# 3. CREACIÓN Y CONFIGURACIÓN DE POSTGRESQL
# ----------------------------------------------------------------------

echo "=================================================================="
echo "--- 💾 3. CREACIÓN Y CONFIGURACIÓN DE BASE DE DATOS POSTGRESQL ---"
echo "=================================================================="
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

echo "--- Ejecutando Script SQL con 'psql' (NOPASSWD) ---"

# Se ejecuta con NOPASSWD configurado en el script padre, la salida se redirige a /dev/null
sudo -u postgres psql -t -f "$SQL_FILE" > /dev/null 2>&1 

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al configurar PostgreSQL. Revisa la regla NOPASSWD o la sintaxis SQL."
    rm "$SQL_FILE"
    deactivate
    exit 1
fi
rm "$SQL_FILE"

echo -e "\n"
echo "✅ Base de datos '$DB_NAME' y usuario '$DB_USER' configurados en PostgreSQL."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 4. PERSONALIZACIÓN DEL ARCHIVO settings_local.py
# ----------------------------------------------------------------------

echo "==========================================================="
echo "--- 📝 4. PERSONALIZACIÓN DEL ARCHIVO settings_local.py ---"
echo "==========================================================="
echo -e "\n"

# --- 4.1 Solicitud de Parámetros de la Aplicación (Usuario) ---
echo "--- 4.1 Parámetros de la Aplicación ---"
echo -e "\n"

read_prompt "Introduzca el nombre del CENTRO EDUCATIVO (por defecto: Centre de Demo): " NOM_CENTRE "Centre de Demo"
read_prompt "Introduzca la LOCALIDAD del centro educativo (por defecto: Badia del Vallés): " LOCALITAT "Badia del Vallés"
read_prompt "Introduzca el CÓDIGO del centro (por defecto: 00000000): " CODI_CENTRE "00000000"
read_prompt "Introduzca la URL base de la aplicación (por defecto: https://djau.elteudomini.cat): " DOMAIN_NAME "https://djau.elteudomini.cat"
read_prompt "Introduzca los HOSTS permitidos separados por comas. (por defecto: djau.elteudomini.cat,127.0.0.1): " ALLOWED_HOSTS_LIST "djau.elteudomini.cat,127.0.0.1"
read_prompt "Introduzca la dirección de CORREO del administrador (por defecto: ui@mega.cracs.cat): " ADMIN_EMAIL "ui@mega.cracs.cat"
echo -e "\n"
echo -e "☑️ Parámetros generales definidos.\n"
echo -e "\n"

echo "--- 4.2 Parámetros de Correo SMTP (Google/App Password) ---"
echo "ℹ️  Para el envío de correos se requiere una contraseña de aplicación de Google."
echo -e "    La información se puede encontrar aquí: https://support.google.com/mail/answer/185833?hl=ca\n"

read_prompt "Introduzca el CORREO para envío SMTP (EMAIL_HOST_USER) (por defecto: djau@elteudomini.cat): " EMAIL_HOST_USER "djau@elteudomini.cat"

while true; do
    read -sp "Introduzca la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): " EMAIL_HOST_PASS
    echo
    read -sp "Repita la CONTRASEÑA: " EMAIL_HOST_PASS2
    echo 

    if [ -z "$EMAIL_HOST_PASS" ] || [ -z "$EMAIL_HOST_PASS2" ]; then
        echo -e "❌ ERROR: La contraseña no puede dejarse en blanco. Inténtelo de nuevo.\n"
    elif [ "$EMAIL_HOST_PASS" != "$EMAIL_HOST_PASS2" ]; then
        echo -e "❌ ERROR: Las contraseñas no coinciden. Inténtelo de nuevo.\n"
    else
        break
    fi
done

read_prompt "Introduzca el CORREO del servidor (SERVER_EMAIL/DEFAULT_FROM_EMAIL) (por defecto: djau@elteudomini.cat): " SERVER_MAIL "djau@elteudomini.cat"

echo -e "\n"
echo -e "☑️ Parámetros SMTP definidos.\n"
echo -e "\n"


# 4.3 Copiar y Aplicar Sustituciones
CONFIG_FILE="aula/settings_local.sample"
FINAL_FILE="aula/settings_local.py"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ ERROR: No se encontró el archivo sample en '$CONFIG_FILE'. Saliendo."
    deactivate
    exit 1
fi
cp "$CONFIG_FILE" "$FINAL_FILE"

echo "--- 4.3 Aplicando Sustituciones con 'sed' ---"

# Base de Datos
sed -i "s#^        'NAME': 'djau2025',#        'NAME': '$DB_NAME',#" "$FINAL_FILE"
sed -i "s#^        'USER': 'djau2025',#        'USER': '$DB_USER',#" "$FINAL_FILE"
sed -i "s#^        'PASSWORD': \"XXXXXXXXXX\",#        'PASSWORD': \"$DB_PASS\",#" "$FINAL_FILE"

# Variables de la aplicación:
sed -i "s#^NOM_CENTRE = 'Centre de Demo'#NOM_CENTRE = u'$NOM_CENTRE'#" "$FINAL_FILE"
sed -i "s#^LOCALITAT = u\"Badia del Vallés\"#LOCALITAT = u\"$LOCALITAT\"#" "$FINAL_FILE"
sed -i "s#^CODI_CENTRE = u\"00000000\"#CODI_CENTRE = u\"$CODI_CENTRE\"#" "$FINAL_FILE"
sed -i "s#^URL_DJANGO_AULA = r'http://elteudomini.cat'#URL_DJANGO_AULA = r'$DOMAIN_NAME'#" "$FINAL_FILE"

# ALLOWED_HOSTS
ALLOWED_HOSTS_PYTHON_LIST="'${ALLOWED_HOSTS_LIST//,/\', \'}'"
sed -i "s#^ALLOWED_HOSTS = \[ 'elteudomini.cat', '127.0.0.1', \]#ALLOWED_HOSTS = [ $ALLOWED_HOSTS_PYTHON_LIST, ]#" "$FINAL_FILE"

# Clave Secreta y Datos Privados
sed -i "s|^SECRET_KEY = .*|SECRET_KEY = '$SECRET_KEYPASS_FILTERED'|" "$FINAL_FILE"
sed -i "s#^PRIVATE_STORAGE_ROOT =.*#PRIVATE_STORAGE_ROOT = '$PATH_DADES_PRIVADES'#" "$FINAL_FILE"

# Datos de Email/Admin
sed -i "s#('admin', 'ui@mega.cracs.cat'),#('admin', '$ADMIN_EMAIL'),#" "$FINAL_FILE"
sed -i "s#^EMAIL_HOST_USER='el-meu-centre@el-meu-centre.net'#EMAIL_HOST_USER='$EMAIL_HOST_USER'#" "$FINAL_FILE"
sed -i "s#^EMAIL_HOST_PASSWORD='xxxx xxxx xxxx xxxx'#EMAIL_HOST_PASSWORD='$EMAIL_HOST_PASS'#" "$FINAL_FILE"
sed -i "s#^SERVER_EMAIL='el-meu-centre@el-meu-centre.net'#SERVER_EMAIL='$SERVER_MAIL'#" "$FINAL_FILE"
sed -i "s#^DEFAULT_FROM_EMAIL = 'El meu centre <no-reply@el-meu-centre.net>'#DEFAULT_FROM_EMAIL = '$NOM_CENTRE <$SERVER_MAIL>'#" "$FINAL_FILE"
sed -i "s/EMAIL_SUBJECT_PREFIX = .*/EMAIL_SUBJECT_PREFIX = '[Comunicació $NOM_CENTRE]'/" "$FINAL_FILE"

# Forzar SSL en cookies si la URL es HTTPS (se asume que sí)
sed -i "s/^SESSION_COOKIE_SECURE=False/SESSION_COOKIE_SECURE=True/" "$FINAL_FILE"
sed -i "s/^CSRF_COOKIE_SECURE=False/CSRF_COOKIE_SECURE=True/" "$FINAL_FILE"

echo "✅ settings_local.py configurado y personalizado."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 5. MIGRACIONES Y CONFIGURACIÓN DE USUARIOS
# ----------------------------------------------------------------------

echo "=================================================================="
echo "--- 🔄 5. APLICACIÓN DE MIGRACIONES Y CONFIGURACIÓN DE USUARIO ---"
echo "=================================================================="
echo -e "\n"

echo -e "--- 5.1 Aplicando Migraciones de Base de Datos ---\n"
python manage.py migrate --noinput

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al aplicar las migraciones. Revisa la conexión a la Base de Datos."
    deactivate
    exit 1
fi
echo -e "\n"
echo "✅ Migraciones aplicadas correctamente."
echo -e "\n"
sleep 3

echo -e "--- 5.2 Ejecutando 'scripts/fixtures.sh' ---\n"
if [ -f "scripts/fixtures.sh" ]; then
    bash scripts/fixtures.sh
	echo -e "\n"
    if [ $? -ne 0 ]; then
        echo "❌ Advertencia: Fallo al ejecutar 'scripts/fixtures.sh'."
    fi
    echo -e "✅ Fixtures ejecutados.\n"
else
    echo -e "☑️ scripts/fixtures.sh no encontrado. Paso omitido.\n"
fi
echo -e "\n"
sleep 3

echo "--- 5.3 Creación de Superusuario 'admin' en la aplicación DJANGO ---"
echo -e "\n"

echo -e "--- Solicitud de Credenciales para el Superusuario 'admin' ---\n"

# 1. SOLICITAR EL EMAIL
read_prompt "Introduce el CORREO ELECTRÓNICO para el superusuario 'admin': " ADMIN_EMAIL

#if [ -z "$ADMIN_EMAIL" ]; then
#    echo "❌ ERROR: El correo electrónico del administrador no puede estar en blanco. Saliendo."
#    exit 1
#fi
echo -e "\n"

# 2. SOLICITAR Y VALIDAR LA CONTRASEÑA
read -sp "Introduce la CONTRASEÑA para el superusuario 'admin': " ADMIN_PASS
echo
read -sp "Repite la CONTRASEÑA: " ADMIN_PASS2
echo
echo -e "\n"

if [ "$ADMIN_PASS" != "$ADMIN_PASS2" ]; then
    echo "❌ ERROR: Las contraseñas del superusuario no coinciden. Saliendo."
    exit 1
fi

echo -e "--- Creando Superusuario 'admin' automáticamente ---\n"

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
    echo "❌ Error al ejecutar el script de creación de superusuario. Revisa el log."
fi
rm "$PYTHON_SCRIPT"




















#echo -e "Este superusuario es el que tiene el control total de la gestión de la aplicación una vez instalada y será quien cargue los datos del centro educativo.\n"
#echo -e "\n"
#echo "⚠️  ATENCIÓN: Se abrirá el modo interactivo para crear el superusuario 'admin'."
#echo -e "   Por favor, utiliza el nombre de usuario 'admin', en vez del que el sistema sugiere por defecto, y una contraseña segura.\n"
#python manage.py createsuperuser
#sleep 3







echo -e "\n"
echo "--- 5.4 Creando Grupos y asignando a 'admin' ---"

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
    echo "❌ Error al ejecutar el script de configuración de grupos."
fi
rm "$PYTHON_SCRIPT"

echo -e "\n"
echo "✅ Grupos configurados."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 6. RECOLECCIÓN DE ESTÁTICOS Y FINALIZACIÓN
# ----------------------------------------------------------------------

echo "==============================================="
echo "--- 🖼️ 6. RECOLECCIÓN DE ARCHIVOS ESTÁTICOS ---"
echo "==============================================="
#echo -e "\n"

python manage.py collectstatic -c --no-input

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al recolectar archivos estáticos."
    deactivate
    exit 1
fi
echo -e "\n"
echo "✅ Archivos estáticos recolectados."
echo -e "\n"

deactivate
sleep 3

# ===================================================================
# 7. GUARDAR VARIABLES EN config_vars.sh QUE SERÁN NECESARIAS
# ===================================================================

echo "============================================================================================"
echo "--- 🖼️ 7. ACTUALIZACIÓN DE ARCHIVO DE VARIABLES COMUNES A LOS SCRIPTS DE AUTOMATIZACIÓN ---"
echo "============================================================================================"
echo -e "\n"
echo -e "--- Actualizando archivo de variables con credenciales de la BD ---\n"
# Añadir la nueva información al archivo (usamos >> para append)
# El archivo está en $SETUP_DIR
echo "export DB_NAME='$DB_NAME'" >> "$SETUP_DIR/config_vars.sh"
echo "export DB_USER='$DB_USER'" >> "$SETUP_DIR/config_vars.sh"
echo "export DOMAIN_NAME='$DOMAIN_NAME'" >> "$SETUP_DIR/config_vars.sh"
echo "export LOCALITAT='$LOCALITAT'" >> "$SETUP_DIR/config_vars.sh"


# Reasignar permisos de forma preventiva
chmod 600 "$SETUP_DIR/config_vars.sh"
chown "$APP_USER":"$APP_USER" "$SETUP_DIR/config_vars.sh"
echo "✅ Credenciales de BD añadidas a config_vars.sh."
echo -e "\n"


echo "=================================================================================================="
echo "--- 🟢 FASE 2 COMPLETADA. CONFIGURACIÓN BÁSICA GESTIONADA PARA DJANGO-AULA (setup_djau.sh) 🟢 ---"
echo "Devolviendo el control al script install_djau.sh"
echo "=================================================================================================="
echo -e "\n"