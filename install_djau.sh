#!/bin/bash
# install_djau.sh
# Script Maestro de Instalación de la Aplicación Django-Aula.
# Se encarga de la configuración del sistema, usuarios y permisos.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash install_app.sh).

# Definiciones de Color ANSI (ejemplo para la visualización)
RESET='\e[0m'
VERDE='\e[32m'
AZUL='\e[34m'
NEGRITA='\e[1m'
C_TITULO="${NEGRITA}${AZUL}"
C_ACCION="${NEGRITA}${VERDE}"
C_INFO="${VERDE}"

echo -e "\n"
echo -e "${C_TITULO}====================================================================================${RESET}"
echo -e "${C_TITULO}--- 🟢 FLUJO DE INSTALACIÓN AUTOMATIZADA DE LA APLICACIÓN DJANGO-AULA 🟢 ---${RESET}"
echo -e "${C_TITULO}====================================================================================${RESET}"
echo -e "\n"

echo -e "${C_ACCION}--- FASE 1: INSTALACIÓN BASE Y DEPENDENCIAS (Automática) ---${RESET}"
echo -e "   ${NEGRITA}ACCIÓN:${RESET} Ejecución inicial del script maestro."
echo "   \$ sudo bash install_djau.sh"
echo -e "   ${VERDE}FUNCIÓN:${RESET} Crea directorios, configura permisos de usuario (para PostgreSQL), instala dependencias base y clona el repositorio."
echo -e "\n"

echo -e "${C_ACCION}--- FASE 2: CONFIGURACIÓN DE DJANGO Y BASE DE DATOS (Interactivo) ---${RESET}"
echo -e "   ${NEGRITA}ACCIÓN:${RESET} Se ejecuta automáticamente el script ${C_INFO}setup_djau.sh${RESET} (sin intervención del usuario)."
echo -e "   ${C_INFO}FUNCIÓN:${RESET} Crea la BD en PostgreSQL, configura el entorno virtual (venv), personaliza ${NEGRITA}settings_local.py${RESET}, realiza las migraciones, crea el superusuario de Django y configura la base de datos interna."
echo -e "\n"

echo -e "${C_ACCION}--- FASE 3: SERVIDOR WEB Y CERTIFICADOS SSL (Manual) ---${RESET}"
echo -e "   ${NEGRITA}ACCIÓN:${RESET} El usuario debe entrar al directorio ${NEGRITA}/opt/djau${RESET} y ejecutar el siguiente script:"
echo "   \$ sudo bash setup_djau/setup_apache.sh"
echo -e "   ${VERDE}FUNCIÓN:${RESET} Instala Apache, genera los archivos de conexión ${NEGRITA}vhost${RESET} (incluyendo SSL) según el dominio proporcionado y crea los certificados SSL (autofirmados o Let's Encrypt)."
echo -e "\n"

echo -e "${C_ACCION}--- FASE 4: TAREAS PROGRAMADAS Y MANTENIMIENTO (Manual) ---${RESET}"
echo -e "   ${NEGRITA}ACCIÓN:${RESET} El usuario debe seguir en ${NEGRITA}/opt/djau${RESET} y ejecutar el siguiente script:"
echo "   \$ sudo bash setup_djau/setup_cron.sh"
echo -e "   ${VERDE}FUNCIÓN:${RESET} Automatiza la configuración de tareas programadas (CRON) en el servidor, como el ${NEGRITA}backup de la base de datos${RESET} y la ejecución de scripts de mantenimiento de la aplicación."
echo -e "\n"

sleep 10


echo -e "\n"
echo "====================================================================="
echo "--- 🔴 FASE 1: INSTALACIÓN BASE Y DEPENDENCIAS install_djau.sh 🔴 ---"
echo "====================================================================="
echo -e "\n"


# ----------------------------------------------------------------------
# FUNCIONES DE AYUDA (Lectura de entrada con valor por defecto)
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


# ----------------------------------------------------------------------
# 1. DEFINICIÓN DE DIRECTORIOS Y USUARIOS
# ----------------------------------------------------------------------

echo "========================================================"
echo "--- ⚙️ 1. DEFINICIÓN DE DIRECTORIOS Y USUARIOS CLAVE ---"
echo "========================================================"
echo -e "\n"

# URL del Repositorio (Mantenida como referencia)
REPO_URL="https://github.com/rafatecno1/django-aula.git"
#REPO_URL="https://github.com/ctrl-alt-d/django-aula.git"	#repositorio original del proyecto

echo -e "ℹ️  Pulse Enter para aceptar el valor por defecto.\n"
echo -e "--- 1.1 Solicitud de Parámetros de Ruta ---\n"

# 1. Carpeta del Proyecto
read_or_default "Introduce el nombre del DIRECTORIO del proyecto (por defecto: djau): " PROJECT_FOLDER "djau"
INSTALL_DIR="/opt"
FULL_PATH="$INSTALL_DIR/$PROJECT_FOLDER"
echo -e "La ruta completa de instalación serà: '$FULL_PATH'."
echo -e "\n"
sleep 1


# 2. Carpeta de Datos Privados
read_or_default "Introduce el nombre del DIRECTORIO para datos privados (por defecto: djau-dades-privades): " DADES_PRIVADES "djau-dades-privades"
PATH_DADES_PRIVADES="$INSTALL_DIR/$DADES_PRIVADES"
export PATH_DADES_PRIVADES
echo -e "La ruta completa de datos privados serà: '$PATH_DADES_PRIVADES'."
echo -e "\n"
sleep 1


echo -e "--- 1.2 Solicitud y Validación de Usuario de la Aplicación ---\n"

# 3. Usuario de la Aplicación
read_or_default "Introduce el nombre del USUARIO de la aplicación (debe existir y tener sudo) (defecto: djau): " APP_USER "djau"
echo -e "\n"

# Verifica si el usuario existe antes de continuar (Verificación crucial)
if ! id -u "$APP_USER" >/dev/null 2>&1; then
    echo "❌ ERROR: El usuario '$APP_USER' no existe en el sistema."
    echo "Por favor, cree el usuario antes de continuar y asegúrese de que esté en el grupo 'sudoers'."
    exit 1
fi
echo "✅ Usuario '$APP_USER' verificado y disponible."
echo -e "\n"
sleep 2

# ----------------------------------------------------------------------
# 2. CONFIGURACIÓN DE POSTGRESQL Y SUDOERS
# ----------------------------------------------------------------------

echo "============================================================"
echo "--- 🔒 2. CONFIGURACIÓN DE SEGURIDAD (Permisos NOPASSWD) ---"
echo "============================================================"
echo -e "\n"

echo "--- 2.1 Configurando Permisos NOPASSWD para PostgreSQL ---"

PSQL_PATH="/usr/bin/psql"
PGDUMP_PATH="/usr/bin/pg_dump"

SUDOERS_RULE="/etc/sudoers.d/90-djau-psql"
PSQL_RULE="$APP_USER ALL=(postgres) NOPASSWD: $PSQL_PATH, $PGDUMP_PATH"

# Conceder a djau permiso para ejecutar 'psql' y 'pg_dump' como 'postgres' sin contraseña
printf "%s\n" "$PSQL_RULE" | sudo tee $SUDOERS_RULE > /dev/null

# Asegurar los permisos seguros para el archivo sudoers
sudo chmod 0440 $SUDOERS_RULE

echo "✅ Permisos NOPASSWD configurados para '$APP_USER' para psql y pg_dump."
echo -e "\n"
sleep 2

# ----------------------------------------------------------------------
# 3. INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA Y CREACIÓN DE CARPETAS
# ----------------------------------------------------------------------

echo "================================================================"
echo "--- 📥 3. INSTALACIÓN DE DEPENDENCIAS Y PREPARACIÓN DE RUTAS ---"
echo "================================================================"
echo -e "\n"

echo -e "--- 3.1 Instalando dependencias del sistema (Python, Git, PostgreSQL, etc. Ahora no se instalará el servidor web) ---\n"

# Se ha quitado la instalación de Apache para aislar el servidor web en setup_apache.sh.
apt update && apt install -y python3 python3-venv libxml2-dev libxslt-dev python3-lxml python3-libxml2 python3-dev lib32z1-dev git libgl1 libglib2.0-0t64 postgresql
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo en la instalación de dependencias del sistema. Saliendo."
    exit 1
fi
echo -e "\n"
echo "✅ Dependencias del sistema instaladas correctamente."
echo -e "\n"
sleep 2


echo "--- 3.2 Creación de Directorios del Proyecto y para los datos privados ---"
# Directorio del proyecto
mkdir -p "$FULL_PATH"
if [ ! -d "$FULL_PATH" ]; then
    echo "❌ ERROR: No se pudo crear el directorio del proyecto '$FULL_PATH'. Saliendo."
    exit 1
fi

# Directorio de datos privados
mkdir -p "$PATH_DADES_PRIVADES"
if [ ! -d "$PATH_DADES_PRIVADES" ]; then
    echo "❌ ERROR: No se pudo crear el directorio de datos privados '$PATH_DADES_PRIVADES'. Saliendo."
    exit 1
fi
echo "✅ Directorios creados: '$FULL_PATH' y '$PATH_DADES_PRIVADES'."
echo -e "\n"
sleep 2

echo "--- 3.3 Asignación de Permisos de Archivos ---"

# Permisos para el directorio del proyecto (propiedad del usuario de la app)
chown -R "$APP_USER":"$APP_USER" "$FULL_PATH"
echo "✅ Permisos de '$FULL_PATH' asignados al usuario '$APP_USER'."

# Permisos para el directorio de datos privados (www-data necesita acceso de lectura/escritura)
chown -R "$APP_USER":www-data "$PATH_DADES_PRIVADES"
chmod 770 "$PATH_DADES_PRIVADES"
echo "✅ Permisos de '$PATH_DADES_PRIVADES' asignados a '$APP_USER':www-data (chmod 770)."
echo -e "\n"
sleep 2

# ----------------------------------------------------------------------
# 4. CLONACIÓN DEL REPOSITORIO Y DELEGACIÓN
# ----------------------------------------------------------------------

echo "========================================================"
echo "--- 🌐 4. CLONACIÓN DEL REPOSITORIO DE LA APLICACIÓN ---"
echo "========================================================"
echo -e "\n"

echo -e "--- 4.1 Clonando Repositorio como usuario '$APP_USER' ---\n"
# Usamos sudo -u para clonar como el usuario de la aplicación
echo "Clonando $REPO_URL en $FULL_PATH. Esto puede tardar un rato..."
sudo -u "$APP_USER" git clone "$REPO_URL" "$FULL_PATH"
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al clonar el repositorio '$REPO_URL'."
    echo "Comprueba que la URL sea correcta o que el usuario '$APP_USER' tenga permisos de red."
    exit 1
fi
echo -e "\n"
echo "✅ Repositorio clonado en '$FULL_PATH'."
echo -e "\n"
sleep 3


# -------------------------------------------------------------------------------------------------
# CREACIÓN DEL ARCHIVO config_vars.sh CON LAS VARIABLES COMUNES PER LA INSTALACIÓN DE LA APLICACIÓN
# -------------------------------------------------------------------------------------------------

SETUP_DIR="$FULL_PATH/setup_djau"
CONFIG_FILE="$SETUP_DIR/config_vars.sh"
cat << EOF > "$CONFIG_FILE"

export APP_USER="$APP_USER"
export PROJECT_FOLDER="$PROJECT_FOLDER"
export FULL_PATH="$FULL_PATH"
export SETUP_DIR="$SETUP_DIR"
export PATH_DADES_PRIVADES="$PATH_DADES_PRIVADES"

EOF


# ----------------------------------------------------------------------
# 5. DELEGACIÓN AL SCRIPT DE CONFIGURACIÓN DE DJANGO
# ----------------------------------------------------------------------

echo "=================================================================="
echo "--- 🚀 5. INICIO DE LA CONFIGURACIÓN ESPECÍFICA DE DJANGO-AULA ---"
echo "=================================================================="
echo -e "\n"

echo -e "--- A partir de este momento, el usuario '$APP_USER' ejecutarà el script setup_djau.sh que se encuentra en '$SETUP_DIR' ---\n"

# Transfiere la ejecución al script de configuración de Django DENTRO del repositorio clonado
cd "$SETUP_DIR"
chmod +x setup_djau.sh
chmod +x setup_apache.sh
chmod +x setup_cron.sh

echo -e "ℹ️  **ATENCIÓN:** Espere la solicitud de parámetros para configurar la Base de Datos y la Aplicación.\n"
sleep 3

# Ejecuta el script de configuración de Django, pasando la ruta privada como argumento
sudo -u "$APP_USER" bash setup_djau.sh

if [ $? -ne 0 ]; then
    echo -e "\n❌ ERROR: Fallo en el script de configuración de Django (setup_djau.sh). Revisa los logs anteriores."
    exit 1
fi


echo -e "\n"
echo "============================================================================"
echo "--- 🟢 FASE 1 y FASE 2 COMPLETADAS (install_djau.sh i setup_djau.sh) 🟢 ---"
echo "============================================================================"
echo -e "\n"
echo "--- SIGUIENTE FASE: FASE 3 - CONFIGURACIÓN DEL SERVIDOR WEB APACHE ---"
echo -e "\n"
echo "Para continuar con la configuración del servidor web Apache, ejecute los siguientes comandos (Copiar/Pegar):"
echo -e "\n"
echo "   1. Cambie al directorio del proyecto:"
echo "      $ cd \"$FULL_PATH\""
echo -e "\n"
echo "   2. Ejecute el script de configuración del servidor web Apache (DEBE SER con sudo):"
echo "      $ sudo bash setup_djau/setup_apache.sh"
echo -e "\n"
echo "¡Puede proceder con la configuración del servidor web Apache!"
echo -e "\n"