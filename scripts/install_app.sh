#!/bin/bash
# install_app.sh
# Script Maestro de Instalación (Debe ejecutarse con sudo)


# --- CONFIGURACIÓN DE DIRECTORIOS I USUARIOS PARA LA INSTALACIÓN DE DJANGO-AULA ---
echo "--- CONFIGURACIÓN DE DIRECTORIOS I USUARIOS PARA LA INSTALACIÓN DE DJANGO-AULA ---"
echo -e "--- Este archivo de ejecutarse con sudo ---\n"

#REPO_URL="https://github.com/ctrl-alt-d/django-aula.git"	#repositorio original del proyecto
REPO_URL="https://github.com/rafatecno1/django-aula.git"	#repositorio copiado para hacere las mejoras en privado

read -p "Introduce el nombre del DIRECTORIO (CARPETA) del proyecto (por defecto: djau): " PROJECT_FOLDER

if [ -z "$PROJECT_FOLDER" ]; then
	PROJECT_FOLDER="djau"
    echo "Por defecto, el nombre del directorio será '$PROJECT_FOLDER'."
fi

INSTALL_DIR="/opt"
FULL_PATH="$INSTALL_DIR/$PROJECT_FOLDER"
echo -e "La ruta completa de instalación serà '$FULL_PATH'.\n"
echo -e "------------\n"


read -p "Introduce el nombre del USUARIO que instalará la aplicación. El usuario debe existir y tener permisos de sudo (grupo sudoers) (por defecto: djau): " APP_USER

if [ -z "$APP_USER" ]; then
	APP_USER="djau"
    echo "Por defecto, el nombre del usuario que instalarà la aplicación será '$APP_USER'."
fi

# Verifica si el usuario existe antes de continuar
if ! id -u "$APP_USER" >/dev/null 2>&1; then
    echo "ERROR: El usuario '$APP_USER' no existe en el sistema. Debe crearlo antes de continuar y asegurarse que tenga persmisos de sudo."
    exit 1
fi

echo -e "El nombre del usuario que efectuará la instalación serà '$APP_USER'.\n"
echo -e "------------\n"



read -p "Introduce el nombre del DIRECTORIO donde se guardarán los datos privados (como las fotografías del alumnado) (por defecto: djau-dades-privades): " DADES_PRIVADES

if [ -z "$DADES_PRIVADES" ]; then
	DADES_PRIVADES="djau-dades-privades"
    echo "Por defecto, el nombre del directorio será '$DADES_PRIVADES'."
fi

PATH_DADES_PRIVADES="$INSTALL_DIR/$DADES_PRIVADES"
export PATH_DADES_PRIVADES
echo -e "La ruta completa para el directorio donde se guardarán los datos privados serà '$PATH_DADES_PRIVADES'.\n"
echo -e "------------\n"

# -----------------------------------

echo "--- 3.b: Configurando Permisos NOPASSWD para PostgreSQL ---"

PSQL_PATH="/usr/bin/psql" # Usamos la ruta absoluta más común

# 1. Definir la regla completa
# Creamos un archivo de reglas específico para el usuario djau
# Esto es más seguro que modificar el archivo /etc/sudoers directamente
SUDOERS_RULE="/etc/sudoers.d/90-djau-psql"
PSQL_RULE="$APP_USER ALL=(postgres) NOPASSWD: $PSQL_PATH"

# 2. Concedemos a djau permiso para ejecutar el comando 'psql' como el usuario 'postgres' sin contraseña
# Escribir la regla de forma segura. 'printf' es más seguro que 'echo' para evitar problemas de formato y saltos de línea
printf "%s\n" "$PSQL_RULE" | sudo tee $SUDOERS_RULE > /dev/null

# 3. Asegurar los permisos seguros para el archivo sudoers
sudo chmod 0440 $SUDOERS_RULE

echo -e "✅ Permiso NOPASSWD configurado para el usuario '$APP_USER' para psql.\n"

# -----------------------------------

echo -e "--- INICIO DE INSTALACIÓN DE DJANGO-AULA ---\n"

# 1. INSTALAR DEPENDENCIAS (Paso 1)
echo -e "1/5: Instalando dependencias del sistema...\n"
apt update && apt install -y python3 python3-venv libxml2-dev libxslt-dev python3-lxml python3-libxml2 python3-dev lib32z1-dev git libgl1 libglib2.0-0t64 postgresql
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo en la instalación de dependencias. Saliendo."
    exit 1
fi
echo -e "✅ Dependencias instaladas.\n"

# 2. CREAR CARPETAS Y ASIGNAR PERMISOS (Paso 2)
echo -e "2/5: Creando directorio '$FULL_PATH' y ajustando permisos...\n"
mkdir -p "$FULL_PATH"
if [ ! -d "$FULL_PATH" ]; then
    echo "❌ ERROR: No se pudo crear el directorio '$FULL_PATH'. Saliendo."
    exit 1
fi

mkdir -p "$PATH_DADES_PRIVADES"
if [ ! -d "$PATH_DADES_PRIVADES" ]; then
    echo "❌ ERROR: No se pudo crear el directorio '$PATH_DADES_PRIVADES'. Saliendo."
    exit 1
fi

# Asignar la propiedad al usuario de la aplicación.
chown -R "$APP_USER":"$APP_USER" "$FULL_PATH"
echo -e "✅ Directorio '$FULL_PATH' creado y permisos asignados a usuario '$APP_USER' y grupo '$APP_USER'.\n"

chown -R "$APP_USER":www-data "$PATH_DADES_PRIVADES"
chmod 770 "$PATH_DADES_PRIVADES"
echo -e "✅ Directorio '$PATH_DADES_PRIVADES' creado y permisos asignados a usuario '$APP_USER' y grupo www-data.\n"

# 3. CLONAR REPOSITORIO (Paso 3)
echo -e "3/5: Clonando repositorio. Esto se hará como el usuario '$APP_USER'...\n"

# Usamos su para clonar como el usuario de la aplicación
sudo -u "$APP_USER" git clone "$REPO_URL" "$FULL_PATH"
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al clonar el repositorio '$REPO_URL'. Comprueba que la URL ('$FULL_PATH') sea correcta y los permisos."
    exit 1
fi
echo -e "✅ Repositorio clonado en '$FULL_PATH'.\n"

# 4. DELEGAR AL SCRIPT DE CONFIGURACIÓN DE DJANGO (Paso 4 en adelante)
echo "4/5: Ejecutando el script de configuración de la aplicación..."
echo -e "Esto se ejecutará como el usuario '$APP_USER' para manejar el venv y manage.py.\n"

# Transfiere la ejecución al script de configuración de Django DENTRO del repositorio clonado
cd "$FULL_PATH"
chmod +x setup_djau.sh
sudo -u "$APP_USER" bash setup_djau.sh "$PATH_DADES_PRIVADES" # Asumiendo que setup_django.sh está a la subcarpeta raiz

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo en el script de configuración de Django. Revisa los logs."
    exit 1
fi

echo "--- 🟢 INSTALACIÓN BÁSICA FINALIZADA 🟢 ---"
echo "5/5: La aplicación está configurada. Sigue las instrucciones para Apache y CRON."