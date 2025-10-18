#!/bin/bash
# setup_djau.sh
# Configura el entorno virtual, la base de datos PostgreSQL, 
# y personaliza el archivo settings_local.py para la aplicación Django.
# DEBE EJECUTARSE como el usuario de la aplicación (djau).

echo -e "\n"
echo "====================================================================="
echo "--- 🟢 INICIO DEL SCRIPT: setup_djau.sh (Configuración Django) 🟢 ---"
echo "====================================================================="
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
# 1. PREPARACIÓN DEL ENTORNO Y BASE DE DATOS
# ----------------------------------------------------------------------

echo "==================================================================="
echo "--- 📝 1. CONFIGURACIÓN DE PARÁMETROS DE LA BASE DE DATOS Y APP ---"
echo "==================================================================="
echo -e "\n"

# 1.1 Capturar la ruta de datos privados (Pasada por el script padre)
PATH_DADES_PRIVADES="$1"

if [ -z "$PATH_DADES_PRIVADES" ]; then
    echo "❌ ERROR: No se recibió la ruta de datos privados (Argumento \$1). Saliendo."
    exit 1
fi
echo "☑️ Ruta de datos privados recibida del script install_app.sh: $PATH_DADES_PRIVADES"
echo -e "\n"


# 1.2 Solicitud de Parámetros de la Base de Datos
echo "--- 1.2 Solicitud de Parámetros de PostgreSQL ---"
echo -e "\n"

# La función read_and_validate ya no permite dejar campos en blanco.
read_and_validate "Introduzca el NOMBRE de la BASE DE DATOS (ej: djau_db): " DB_NAME
read_and_validate "Introduzca el USUARIO de la BD (ej: djau): " DB_USER

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

echo -e "--- 2.1 Creando Entorno Virtual (venv) e instalando dependencias ---\n"

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

# FILTRO ROBUSTO:
# 1. Usamos 'tr' para reemplazar los caracteres problemáticos (|, #, /, &) por un guion (-).
#    Este filtro garantiza que la clave no contendrá el delimitador que usaremos en sed (|).
SECRET_KEYPASS_FILTERED=$(echo "$SECRET_KEYPASS" | tr '\|#/&' '----')

if [ ${#SECRET_KEYPASS} -lt 32 ]; then
    echo "❌ ERROR: No se pudo generar una clave secreta válida. Saliendo."
    deactivate
    exit 1
fi

echo "✅ Clave secreta generada automáticamente."
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
echo "✅ Base de datos '$DB_NAME' y usuario '$DB_USER' creados correctamente."
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

read_and_validate "Introduzca el nombre del CENTRO EDUCATIVO (ej: Centre de Demo): " NOM_CENTRE
read_and_validate "Introduzca la LOCALIDAD del centro educativo (ej: Badia del Vallés): " LOCALITAT
read_and_validate "Introduzca el CÓDIGO del centro (ej: 00000000): " CODI_CENTRE
read_and_validate "Introduzca la URL base de la aplicación (ej: https://elteudomini.cat): " URL_BASE
read_and_validate "Introduzca los HOSTS permitidos separados por comas. (ej: elteudomini.cat,127.0.0.1): " ALLOWED_HOSTS_LIST
read_and_validate "Introduzca la dirección de CORREO del administrador (ej: ui@mega.cracs.cat): " ADMIN_EMAIL
echo -e "\n"
echo -e "☑️ Parámetros generales definidos.\n"
echo -e "\n"

echo "--- 4.2 Parámetros de Correo SMTP (Google/App Password) ---"
echo "ℹ️  Para el envío de correos se requiere una contraseña de aplicación de Google."
echo -e "    La información se puede encontrar aquí: https://support.google.com/mail/answer/185833?hl=ca\n"

read_and_validate "Introduzca el CORREO para envío SMTP (EMAIL_HOST_USER): " EMAIL_HOST_USER
read_and_validate "Introduzca la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): " EMAIL_HOST_PASS
read_and_validate "Introduzca el CORREO del servidor (SERVER_EMAIL/DEFAULT_FROM_EMAIL): " SERVER_MAIL
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
sed -i "s#^URL_DJANGO_AULA = r'http://elteudomini.cat'#URL_DJANGO_AULA = r'$URL_BASE'#" "$FINAL_FILE"

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

echo -e "--- 5.2 Ejecutando 'scripts/fixtures.sh' (si existe) ---\n"
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
echo "⚠️  ATENCIÓN: Se abrirá el modo interactivo para crear el superusuario 'admin'."
echo -e "   Por favor, utiliza el nombre de usuario 'admin', en vez del que el sistema sugiere por defecto, y una contraseña segura.\n"
python manage.py createsuperuser
sleep 3

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


echo "========================================================================================="
echo "--- 🟢 CONFIGURACIÓN BÁSICA GESTIONADA PARA DJANGO-AULA COMPLETADA (setup_djau.sh) 🟢 ---"
echo "Devolviendo el control al script install_app.sh"
echo "========================================================================================="
echo -e "\n"