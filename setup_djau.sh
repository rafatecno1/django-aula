#!/bin/bash

# Este script automatiza la configuración de la BD, migraciones, superusuario,
# grupos y archivos estáticos de una instalación de Django.
echo -e "setup_djau.sh en marxa\n"

# --- 4. Crear venv e Instalar Requisitos (Paso 4) ---
python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip wheel
pip install -r requirements.txt

deactivate

# --- Variables de Configuración de la BD (Reutilizando el script anterior) ---

echo -e "\n\n"
echo -e "--- 1. Configuración de PostgreSQL ---\n"
read -p "Introduzca el nombre de la BASE DE DATOS (por defecto: djau_db): " DB_NAME
read -p "Introduzca el nombre del USUARIO de la BD (por defecto: djau): " DB_USER
read -sp "Introduzca la CONTRASEÑA para el usuario $DB_USER de la BD: " DB_PASS
echo
read -sp "Repita la CONTRASEÑA: " DB_PASS2
echo # Salto de línea después de la contraseña

if [ -z "$DB_NAME" ] ; then
	DB_NAME="djau_db"
    echo -e "Por defecto, el nombre de la base de datos será '$DB_NAME'.\n"
fi
if [ -z "$DB_USER" ] ; then
	DB_USER="djau"
    echo -e "Por defecto, el nombre del usuario de la base de datos será '$DB_USER'.\n"
fi
if [ -z "$DB_PASS" ] || [ -z "$DB_PASS2" ]; then
    echo -e "ERROR: Alguna de las contraseñas, o quizás las dos, se ha dejado en blanco. Se debe asignar una contraseña. Saliendo."
    exit 1
fi
if [ "$DB_PASS" != "$DB_PASS2" ]; then
    echo -e "ERROR: Las contraseñas no coinciden. Saliendo."
    exit 1
fi

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

# Ejecutar el script SQL con el usuario postgres
sudo -u postgres psql -t -f "$SQL_FILE"
if [ $? -ne 0 ]; then
    echo "❌ Error al configurar PostgreSQL. Revisa las credenciales o permisos de sudo."
    rm "$SQL_FILE"
    exit 1
fi
rm "$SQL_FILE"
echo -e "\n"
echo -e "✅ Base de datos '$DB_NAME' y usuario '$DB_USER' configurados en PostgreSQL.\n\n"


# --- 2. Preparación de Archivos de Configuración (settings_local.py) ---

echo -e "--- 2. Personalizando el archivo settings_local.py ---\n"

# --- 2.1 Solicitud de Parámetros de la Aplicación ---

# Función para leer la entrada de datos del usuario y asegurar que no deja respuestas en blanco ni con espacios delante o detrás.
# Uso: read_and_validate "Mensaje de la pregunta" VARIABLE_NAME
read_and_validate () {
    # $1 contiene el mensaje (prompt), $2 contiene el nombre de la variable (sin $)
    local PROMPT_MSG="$1"
    local VAR_NAME="$2"
    local INPUT_VALUE=""
    
    # Bucle de validación
    while true; do
        read -p "$PROMPT_MSG" INPUT_VALUE
        
        # Eliminar espacios en blanco alrededor (trim)
        INPUT_VALUE=$(echo "$INPUT_VALUE" | xargs)
        
        if [ -z "$INPUT_VALUE" ]; then
            echo -e "ERROR: Esta pregunta no puede dejarse en blanco.\n"
        else
            # Asignar el valor a la variable cuyo nombre se pasó como argumento ($2)
            eval "$VAR_NAME='$INPUT_VALUE'"
            break
        fi
    done
}

echo -e "--- Personalización de Parámetros de la Aplicación ---\n"

# 1. Nombre del Centro
read_and_validate "Introduzca el nombre del CENTRO EDUCATIVO (ej: Centre de Demo): " NOM_CENTRE
echo -e "Valor guardado para NOM_CENTRE: $NOM_CENTRE\n"

# 2. Localidad
read_and_validate "Introduzca la LOCALIDAD del centro educativo (ej: Badia del Vallés): " LOCALITAT
echo -e "Valor guardado para LOCALITAT: $LOCALITAT\n"

# 3. Código del Centro
read_and_validate "Introduzca el CÓDIGO del centro (ej: 00000000): " CODI_CENTRE
echo -e "Valor guardado para CODI_CENTRE: $CODI_CENTRE\n"

# 4. URL base de la aplicación
read_and_validate "Introduzca la URL base de la aplicación (ej: http://elteudomini.cat) Cambiar http por https si se activa el tráfico TSL: " URL_BASE
echo -e "Valor guardado para la URL base: $URL_BASE\n"

# 5. HOSTS permitidos
read_and_validate "Introduzca los HOSTS permitidos separados por comas (ej: elteudomini.cat, www.elteudomini.cat, 127.0.0.1, 192.168.1.30): " ALLOWED_HOSTS_LIST
echo -e "Valor guardado para los HOSTS permitidos: $ALLOWED_HOSTS_LIST\n"

# 6. Correu del administrador
read_and_validate "Introduzca la dirección de CORREO del administrador (ej: ui@mega.cracs.cat): " ADMIN_EMAIL
echo -e "Valor guardado para el CORREO del administrador: $ADMIN_EMAIL\n"

echo
echo "--- Configuración del servidor de correo del DjAu ---"
echo
echo "Para que el DjAu pueda enviar correos a las famílias cal configurar una cuenta de google"
echo "con una contraseña de aplicación para usar el EMAIL_BACKEND SMTP" 
echo -e "La información se puede encontrar aquí: https://support.google.com/mail/answer/185833?hl=ca\n" 


echo "Backend SMTP"
echo "EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'"

# 1. Correu enviament SMTP
read_and_validate "Introduzca el CORREO para envío SMTP (EMAIL_HOST_USER) (ej: el-meu-centre@el-meu-centre): " EMAIL_HOST_USER
echo -e "Valor guardado para el CORREO para envío SMTP (EMAIL_HOST_USER): $EMAIL_HOST_USER\n"

# 2. Contraseña de aplicación SMTP
read_and_validate "Introduzca la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): " EMAIL_HOST_PASS
echo -e "Valor guardado para la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): $EMAIL_HOST_PASS\n"

#read -sp "Introduce la CONTRASEÑA de aplicación SMTP (EMAIL_HOST_PASSWORD): " EMAIL_HOST_PASS

# 3. Servidor de correu
read_and_validate "Introduzca el (SERVER_EMAIL) (ej: el-meu-centre@el-meu-centre): " SERVER_MAIL
echo -e "Valor guardado para el (SERVER_EMAIL): $SERVER_MAIL\n"



# 2.2 Generar automáticamente la Clave Secreta de Django
source venv/bin/activate
SECRET_KEYPASS=$(python manage.py generate_secret_key 2>&1)

# Verificar si se generó la clave (debe tener al menos 32 caracteres)
if [ ${#SECRET_KEYPASS} -lt 32 ]; then
    echo "❌ ERROR: No se pudo generar una clave secreta válida. Saliendo."
    exit 1
fi

echo "✅ Clave secreta generada automáticamente."

deactivate

# 2.3 Copiar y Personalizar el Archivo
CONFIG_FILE="aula/settings_local.sample" # Ajusta la ruta si es diferente
FINAL_FILE="aula/settings_local.py"

# Verificar si el archivo sample existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ ERROR: No se encontró el archivo sample en '$CONFIG_FILE'. Saliendo."
    exit 1
fi

# Copiar el archivo sample para trabajar con él
cp "$CONFIG_FILE" "$FINAL_FILE"

# --- 2.4 Aplicar Búsqueda y Reemplazo con 'sed' ---

# Variables de la aplicación:
sed -i "s#^NOM_CENTRE = 'Centre de Demo'#NOM_CENTRE = u'$NOM_CENTRE'#" "$FINAL_FILE"
sed -i "s#^LOCALITAT = u\"Badia del Vallés\"#LOCALITAT = u\"$LOCALITAT\"#" "$FINAL_FILE"
sed -i "s#^CODI_CENTRE = u\"00000000\"#CODI_CENTRE = u\"$CODI_CENTRE\"#" "$FINAL_FILE"
sed -i "s#^URL_DJANGO_AULA = r'http://elteudomini.cat'#URL_DJANGO_AULA = r'$URL_BASE'#" "$FINAL_FILE"

echo -e "Variables de la apliación ---> fets\n"

# ALLOWED_HOSTS: Necesita formatear la lista de hosts para Python
# Reemplazar comas por ", ' y añadir las comillas de inicio y fin
ALLOWED_HOSTS_PYTHON_LIST="'${ALLOWED_HOSTS_LIST//,/\', \'}'"
sed -i "s#^ALLOWED_HOSTS = \[ 'elteudomini.cat', '127.0.0.1', \]#ALLOWED_HOSTS = [ $ALLOWED_HOSTS_PYTHON_LIST, ]#" "$FINAL_FILE"

echo -e "ALLOWED_HOSTS ---> fets\n"

# Clave Secreta y Datos Privados
sed -i "s#^SECRET_KEY = .*#SECRET_KEY = '$SECRET_KEYPASS'#" "$FINAL_FILE"
# Se asume que PRIVATE_STORAGE_ROOT se define como /opt/djau-dades-privades-2025/ en el sample, ajustamos:
#sed -i "s#^PRIVATE_STORAGE_ROOT ='/opt/djau-dades-privades-2025/'#PRIVATE_STORAGE_ROOT='$PATH_DADES_PRIVADES'#" "$FINAL_FILE"
sed -i "s#^PRIVATE_STORAGE_ROOT =.*#PRIVATE_STORAGE_ROOT = '$PATH_DADES_PRIVADES'#" "$FINAL_FILE"
echo -e "Clave secreta y directorio para guardar los datos privados ---> fets\n"


# Datos de Email/Admin
sed -i "s#('admin', 'ui@mega.cracs.cat'),#('admin', '$ADMIN_EMAIL'),#" "$FINAL_FILE"
sed -i "s#^EMAIL_HOST_USER='el-meu-centre@el-meu-centre.net'#EMAIL_HOST_USER='$EMAIL_HOST_USER'#" "$FINAL_FILE"
sed -i "s#^EMAIL_HOST_PASSWORD='xxxx xxxx xxxx xxxx'#EMAIL_HOST_PASSWORD='$EMAIL_HOST_PASS'#" "$FINAL_FILE"
sed -i "s#^SERVER_EMAIL='el-meu-centre@el-meu-centre.net'#SERVER_EMAIL='$SERVER_MAIL'#" "$FINAL_FILE"
sed -i "s#^DEFAULT_FROM_EMAIL = 'El meu centre <no-reply@el-meu-centre.net>'#DEFAULT_FROM_EMAIL = '$NOM_CENTRE <$SERVER_MAIL>'#" "$FINAL_FILE"
#sed -i "s#^EMAIL_SUBJECT_PREFIX = '[DEMO AULA] '#EMAIL_SUBJECT_PREFIX = '[Comunicació $NOM_CENTRE]'#" "$FINAL_FILE"
# Versión más robusta de sed para ignorar espacios y caracteres de escape
sed -i "s/EMAIL_SUBJECT_PREFIX = .*/EMAIL_SUBJECT_PREFIX = '[Comunicació $NOM_CENTRE]'/" "$FINAL_FILE"

echo -e "Datos de Email/Admin ---> fets\n"

# Usaremos un delimitador poco común (ej: #) para evitar conflictos con la URL y las barras (/)
# La base de datos es lo más importante:
#sed -i "s#^DATABASES = {.*'NAME': 'djau2025',#DATABASES = {\n    'default': {\n        'ENGINE': 'django.db.backends.postgresql',\n        'NAME': '$DB_NAME',#" "$FINAL_FILE"
sed -i "s#^        'NAME': 'djau2025',#        'NAME': '$DB_NAME',#" "$FINAL_FILE"
sed -i "s#^        'USER': 'djau2025',#        'USER': '$DB_USER',#" "$FINAL_FILE"
sed -i "s#^        'PASSWORD': \"XXXXXXXXXX\",#        'PASSWORD': \"$DB_PASS\",#" "$FINAL_FILE"


echo -e "base de datos ---> fets\n"





echo "✅ Archivo settings_local.py creado y personalizado."





# --- 2. Preparación de Django (Pasos 9 y 10) ---

echo -e "--- 2. Ejecutando migraciones y creando superusuario ---\n"

source venv/bin/activate

# Ejecutar migraciones
python3 manage.py migrate

if [ $? -ne 0 ]; then
    echo "❌ Error al ejecutar 'migrate'."
    exit 1
fi
echo -e "✅ Migraciones completadas.\n"

# Ejecutar el script fixtures.sh si existe
if [ -f "fixtures.sh" ]; then
    echo "Ejecutando fixtures.sh..."
    bash fixtures.sh
    if [ $? -ne 0 ]; then
        echo "❌ Advertencia: Fallo al ejecutar 'fixtures.sh'."
    fi
    echo -e "✅ Fixtures ejecutados.\n"
fi

# Crear Superusuario 'admin'. La opción --no-input no se puede usar aquí
# ya que necesitamos la contraseña, por lo que lo hacemos de forma interactiva.
echo "⚠️  ATENCIÓN: Se abrirá el modo interactivo para crear el superusuario 'admin'."
echo -e "   Por favor, utiliza el nombre de usuario 'admin', aunque el sistema le sugiera otro, y una contraseña segura.\n"
python3 manage.py createsuperuser

# --- 3. Automatización de Creación y Asignación de Grupos (Paso 10) ---

echo -e "--- 3. Creando Grupos y asignando a 'admin' ---\n"

# Crear el script de Python para los grupos
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

# Ejecutar el script Python dentro del shell de Django
python3 manage.py shell < "$PYTHON_SCRIPT"
if [ $? -ne 0 ]; then
    echo "❌ Error al ejecutar el script de configuración de grupos."
fi
rm "$PYTHON_SCRIPT"

# --- 4. Recolección de Archivos Estáticos (Paso 11) ---

echo -e "--- 4. Recolección de archivos estáticos ---\n"
python3 manage.py collectstatic -c --no-input
if [ $? -ne 0 ]; then
    echo "❌ Error al ejecutar 'collectstatic'."
    exit 1
fi
deactivate

echo -e "✅ Archivos estáticos recolectados.\n"

echo -e"--- 🟢 CONFIGURACIÓN BÁSICA DE DJANGO FINALIZADA 🟢 ---\n"
#echo "Los siguientes pasos son la configuración de Apache y CRON."