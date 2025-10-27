#!/bin/bash
# install_djau.sh
# Script Maestro de Instalación de la Aplicación Django-Aula.
# Se encarga de la configuración del sistema, usuarios y permisos.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash install_djau.sh).

clear

# ----------------------------------------------------------------------
# CARGA DE LIBRERÍA DE FUNCIONES Y VARIABLES DE COLOR
# ----------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------------"
echo "--- Proceso de descarga de la librería temporal necesaria en el inicio de la instalación ---"
echo "--------------------------------------------------------------------------------------------"

# 1. Definir la URL remota de la librería de funciones
FUNCTIONS_URL="https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/setup_djau/functions.sh"
FUNCTIONS_FILE="./functions.sh"

echo -e "\n"
echo "ℹ️ Descargando la librería temporal de funciones compartidas ($FUNCTIONS_FILE)..."

# 2. Descargar la librería de funciones usando wget
# La opción '-O' (mayúscula) fuerza la salida al archivo local especificado.
# La opción '-q' (quiet) suprime la salida detallada.
wget -q -O "$FUNCTIONS_FILE" "$FUNCTIONS_URL"

if [ $? -ne 0 ]; then
    echo -e "\n"
    echo "❌ ERROR: Fallo al descargar el archivo temporal de funciones desde $FUNCTIONS_URL. Saliendo."
    # No podemos usar las variables de color aquí porque aún no se han cargado.
    exit 1
fi

# 3. CAMBIAR PROPIEDAD: Asignar el archivo al usuario original que ejecutó 'sudo'
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$FUNCTIONS_FILE"
fi

# 4. Cargar la librería de funciones
source "$FUNCTIONS_FILE"

# Ahora las variables de color ($C_EXITO, $C_ERROR, etc.) y la función read_prompt están disponibles.
echo -e "\n"
echo -e "${C_EXITO}✅ Librería de funciones temporal cargada con éxito.${RESET}"
echo -e "\n"

echo -e "${C_INFO}ℹ️ Eliminación del archivo temporal de funciones${RESET} ${C_SUBTITULO}${FUNCTIONS_FILE}${RESET} ${C_INFO}dado que el archivo permanente estará ubicado en la carpeta de instalación de DJANGO-AULA.${RESET}"
rm "$FUNCTIONS_FILE"

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ADVERTENCIA: No se pudo eliminar el archivo de funciones${RESET} ${C_INFO} '$FUNCTIONS_FILE'${RESET} ${${C_ERROR}}. Puede que necesite hacerlo manualmente.${RESET}"
fi

echo -e "${C_EXITO}✅ Limpieza finalizada.${RESET}"
echo -e "\n\n"

read -p "Presione una tecla para dar paso a la información sobre el proceso de la instalación de DJANGO-AULA" -n1 -s

clear

echo -e "\n"
echo -e "${C_CAPITULO}======================================================================${RESET}"
echo -e "${C_CAPITULO}--- FLUJO DE INSTALACIÓN AUTOMATIZADA DE LA APLICACIÓN DJANGO-AULA ---${RESET}"
echo -e "${C_CAPITULO}======================================================================${RESET}"
echo -e "\n"

echo -e "${C_EXITO}--- FASE 1: INSTALACIÓN Y CONFIGURACIÓN DE DJANGO-AULA, CON SUS DEPENDENCIAS Y LA BASE DE DATOS ---${RESET}"
echo -e "    ${NEGRITA}PRIMERA ACCIÓN:${RESET} Ejecución inicial del script maestro obteniéndolo directamente del repositorio de Github."
echo -e "      \$ ${C_SUBTITULO}sudo bash install_djau.sh${RESET}"
echo -e "    ${VERDE}FUNCIÓN:${RESET} Crea directorios, configura permisos de usuarios, instala dependencias y clona el repositorio."
echo -e "\n"
echo -e "    ${NEGRITA}SEGUNDA ACCIÓN:${RESET} Se ejecuta automáticamente el script ${C_INFO}setup_djau.sh${RESET} (sin intervención del usuario)."
echo -e "    ${VERDE}FUNCIÓN:${RESET} Crea la BD en PostgreSQL, configura el entorno virtual (venv), personaliza ${C_INFO}settings_local.py${RESET},"
echo -e "             realiza las migraciones, crea el superusuario de Django y prepara la BD para el centro educativo."
echo -e "\n"

echo -e "${C_EXITO}--- FASE 2: SERVIDOR WEB Y CERTIFICADOS SSL ---${RESET}"
echo -e "    ${NEGRITA}ACCIÓN:${RESET} El usuario debe entrar manualmente al directorio ${C_INFO}/opt/djau/setup_djau${RESET} y ejecutar el siguiente script:"
echo -e "      \$ ${C_SUBTITULO}sudo bash setup_apache.sh${RESET}"
echo -e "    ${VERDE}FUNCIÓN:${RESET} Instala el servidor web Apache, genera los archivos de conexión ${NEGRITA}vhost${RESET} para el dominio proporcionado,"
echo -e "             y crea los certificados SSL (autofirmados o Let's Encrypt)."
echo -e "\n"

echo -e "${C_EXITO}--- FASE 3: TAREAS PROGRAMADAS Y MANTENIMIENTO ---${RESET}"
echo -e "    ${NEGRITA}ACCIÓN:${RESET} El usuario debe seguir en ${C_INFO}/opt/djau/setup_djau${RESET} y ejecutar el siguiente script:"
echo -e "      \$ ${C_SUBTITULO}sudo bash setup_cron.sh${RESET}"
echo -e "    ${VERDE}FUNCIÓN:${RESET} ${NEGRITA}Configura la automatización de las tareas programadas${RESET} (CRON) en el servidor, como el ${NEGRITA}backup de la base de datos${RESET}"
echo -e "             y la ejecución de scripts de mantenimiento de la aplicación."
echo -e "\n"

read -p "Presione una tecla para continuar" -n1 -s

clear

echo -e "\n"
echo -e "${C_PRINCIPAL}==============================================================="
echo -e "${C_PRINCIPAL}--- FASE 1: INSTALACIÓN BASE Y DEPENDENCIAS${RESET} ${CIANO}install_djau.sh${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}===============================================================${RESET}"

# ----------------------------------------------------------------------
# 1. DEFINICIÓN DE DIRECTORIOS Y USUARIOS
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}====================================================="
echo -e "${C_CAPITULO}--- 1. DEFINICIÓN DE DIRECTORIOS Y USUARIOS CLAVE ---"
echo -e "${C_CAPITULO}=====================================================${RESET}"
echo -e "\n"

echo -e "${C_INFO}ℹ️  **ATENCIÓN:**${RESET} Cuando se indique que existe un valor por defecto, puede pulsar Enter para aceptarlo si lo desea.\n"

echo -e "\n"
echo -e "${C_SUBTITULO}--- 1.1 Solicitud de Parámetros de Ruta ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------${RESET}"

# 1. Carpeta del Proyecto
read_prompt "Introduce el nombre del DIRECTORIO del proyecto (por defecto: djau): " PROJECT_FOLDER "djau"
INSTALL_DIR="/opt"
FULL_PATH="$INSTALL_DIR/$PROJECT_FOLDER"

echo -e "La ruta completa de instalación serà: ${NEGRITA}'$FULL_PATH'${RESET}."
echo -e "\n"
sleep 1

# 2. Carpeta de Datos Privados
read_prompt "Introduce el nombre del DIRECTORIO para datos privados (por defecto: djau-dades-privades): " DADES_PRIVADES "djau-dades-privades"
PATH_DADES_PRIVADES="$INSTALL_DIR/$DADES_PRIVADES"

echo -e	"La ruta completa de datos privados serà: ${NEGRITA}'$PATH_DADES_PRIVADES'${RESET}."
echo -e "\n"
sleep 1

echo -e "\n"
echo -e "${C_SUBTITULO}--- 1.2 Solicitud y Validación de Usuario de la Aplicación ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------${RESET}"


# 3. Usuario de la Aplicación
read_prompt "Introduce el nombre del USUARIO DE LINUX que instalará la aplicación (debe existir y tener sudo) (por defecto: djau): " APP_USER "djau"

# Verifica si el usuario existe antes de continuar (Verificación crucial)
if id -u "$APP_USER" >/dev/null 2>&1; then
    # El usuario SÍ existe (Comando id -u tuvo éxito, código de salida 0)
    echo -e "${C_EXITO}✅ Usuario '$APP_USER' verificado y disponible en el sistema.${RESET}"
else
    # El usuario NO existe (Comando id -u falló, código de salida > 0)
    echo -e "${C_ERROR}❌ ERROR: El usuario '$APP_USER' no existe en el sistema.${RESET}"
    echo -e "${C_INFO}ℹ️ Por favor, cree el usuario antes de continuar y asegúrese de que esté en el grupo 'sudoers'.${RESET}"
    exit 1
fi
sleep 2

# ----------------------------------------------------------------------
# 2. CONFIGURACIÓN DE POSTGRESQL Y SUDOERS
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}========================================================="
echo -e "${C_CAPITULO}--- 2. CONFIGURACIÓN DE SEGURIDAD (Permisos NOPASSWD) ---"
echo -e "${C_CAPITULO}=========================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- Configurando Permisos NOPASSWD para PostgreSQL ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------${RESET}"

PSQL_PATH="/usr/bin/psql"
PGDUMP_PATH="/usr/bin/pg_dump"

SUDOERS_RULE="/etc/sudoers.d/90-djau-psql"
PSQL_RULE="$APP_USER ALL=(postgres) NOPASSWD: $PSQL_PATH, $PGDUMP_PATH"

# Conceder a djau permiso para ejecutar 'psql' y 'pg_dump' como 'postgres' sin contraseña
printf "%s\n" "$PSQL_RULE" | sudo tee $SUDOERS_RULE > /dev/null

# Asegurar los permisos seguros para el archivo sudoers
sudo chmod 0440 $SUDOERS_RULE

echo -e "${C_EXITO}✅ Permisos NOPASSWD configurados para '$APP_USER' para psql y pg_dump.${RESET}"
sleep 2

# ----------------------------------------------------------------------
# 3. INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA Y CREACIÓN DE CARPETAS
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================="
echo -e "${C_CAPITULO}--- 3. INSTALACIÓN DE DEPENDENCIAS Y PREPARACIÓN DE RUTAS ---"
echo -e "${C_CAPITULO}=============================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 3.1 Instalando dependencias del sistema (Python, Git, PostgreSQL, etc). Ahora no se instalará el servidor web ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------------------------------------------------------------------------${RESET}"

# 1. Actualizar la lista de paquetes
echo -e "${C_INFO}ℹ️ Actualizando la lista de paquetes (apt-get update)...${RESET}"
apt-get update
echo -e "\n"

# 2. Actualizar los paquetes existentes
echo -e "${C_INFO}ℹ️ Actualizando el sistema (apt-get upgrade -y)...${RESET}"
apt-get upgrade -y

if [ $? -ne 0 ]; then
    echo -e "\n"
    echo -e "${C_ERROR}❌ ERROR: Fallo al actualizar los paquetes existentes (apt-get upgrade).${RESET}"
    echo -e "${C_INFO}⚠️ Este fallo puede indicar dependencias rotas o problemas de sistema, pero puede ser un error de red temporal.${RESET}"
    echo -e "\n"
    
    # Pregunta de continuación
    read_prompt "¿Desea continuar igualmente con la instalación de dependencias? (sí/NO - Enter para NO): " CONTINUE_ACTION "no"
    
    RESPONSE_LOWER=$(echo "$CONTINUE_ACTION" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$RESPONSE_LOWER" != "sí" ]] && [[ "$RESPONSE_LOWER" != "si" ]]; then
        echo -e "${C_ERROR}🛑 Instalación cancelada por el usuario.${RESET}"
		echo -e "\n"
        exit 1
    fi
    echo -e "\n"
fi
echo -e "\n"

# 3. Instalar las dependencias necesarias (Solo se ejecuta si el usuario continuó o no hubo errores)

echo -e "${C_INFO}ℹ️ Instalando dependencias del sistema. Esto puede tardar unos minutos...${RESET}"
echo -e "\n"

# -----------------------------------------------------------------
# NÚCLEO DE LA APLICACIÓN DJANGO Y HERRAMIENTAS DE PYTHON
# -----------------------------------------------------------------
APT_DESC="Núcleo Django y Python"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y \
	python3 \
    python3-venv \
    python3-dev \
    lib32z1-dev \
    libxml2-dev \
    libxslt-dev \
    python3-lxml \
    python3-libxml2 \
    libgl1 \
    libglib2.0-0t64

check_install "$APT_DESC"
	
# -----------------------------------------------------------------
# GESTIÓN DE CÓDIGO
# -----------------------------------------------------------------	
APT_DESC="Gestión de Código (git)"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y git
check_install "$APT_DESC"

# -----------------------------------------------------------------
# GESTOR DE BASE DE DATOS Y UTILIDADES DE ADMINISTRACIÓN
# -----------------------------------------------------------------
APT_DESC="Gestor de Base de Datos (PostgreSQL)"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y postgresql
check_install "$APT_DESC"

# -----------------------------------------------------------------
# UTILIDADES DE ADMINISTRACIÓN
# -----------------------------------------------------------------
APT_DESC="Utilidades de administración"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y \
    nano \
    htop \
    btop \
    ncdu

check_install "$APT_DESC"

# -----------------------------------------------------------------
# SEGURIDAD Y CONFIGURACIÓN DEL SISTEMA
# -----------------------------------------------------------------
APT_DESC="Seguridad, Cron y Locale (fail2ban, locales, haveged)"
echo -e "${C_INFO}ℹ️ $APT_DESC${RESET}"
apt-get install -y \
    cron \
    fail2ban \
    locales \
    haveged # Generador de Entropía (crucial para openssl en VPS)

check_install "$APT_DESC"

# NOTA: btop no está siempre en los repositorios por defecto de Debian/Ubuntu. 
# Si falla, se puede quitar o el usuario lo instalará por su cuenta.

echo -e "\n"
echo -e "${C_EXITO}✅ Todas las dependencias del sistema instaladas y sistema actualizado correctamente.${RESET}"
echo -e "\n"
sleep 2

echo -e "${C_SUBTITULO}--- 3.2 Configurando Fail2Ban ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------${RESET}"

# Copia de la configuración por defecto a local para evitar cambios en la original
if [ ! -f /etc/fail2ban/jail.local ]; then
    echo -e "${C_INFO}ℹ️ Creando jail.local para configuración local...${RESET}"
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

echo -e "${C_INFO}ℹ️ Esperando 5 segundos para que Fail2Ban inicie completamente el socket...${RESET}"
sleep 5
echo -e "\n"

# Reiniciar para asegurar que la configuración está activa
sudo systemctl restart fail2ban

echo -e "${C_EXITO}✅ Fail2Ban instalado y servicio reiniciado. Protegiendo SSH y otros servicios.${RESET}"
echo -e "\n"
echo -e "${C_INFO}ℹ️ Puede verificar el estado del sistema en cualquier momento con:${RESET}"
echo -e "\n"
echo -e "${C_INFO}sudo systemctl status fail2ban${RESET}"
sudo systemctl status fail2ban | grep Active
echo -e "\n"
sleep 2
echo -e "${C_INFO}sudo fail2ban-client status${RESET}"
sudo fail2ban-client status
echo -e "\n"
sleep 2
echo -e "${C_INFO}sudo fail2ban-client status sshd${RESET}"
sudo fail2ban-client status sshd
echo -e "\n"
sleep 2
#Tarda mucho tiempo en acabar. Parece que el proceso ha fallado y se ha quedado bloqueado.
#echo -e "${C_INFO}sudo tail -f /var/log/fail2ban.log${RESET}"
#sudo tail -f /var/log/fail2ban.log
#echo -e "\n"
sleep 2

echo -e "${C_SUBTITULO}--- 3.3 Creación de directorios para el proyecto DJANGO-AULA y para los datos privados del proyecto ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------------------------------------------${RESET}"


# Directorio del proyecto
mkdir -p "$FULL_PATH"
if [ ! -d "$FULL_PATH" ]; then
    echo -e "${C_ERROR}❌ ERROR: No se pudo crear el directorio del proyecto '$FULL_PATH'. Saliendo.${RESET}"
	echo -e "\n"
    exit 1
fi

# Directorio de datos privados
mkdir -p "$PATH_DADES_PRIVADES"
if [ ! -d "$PATH_DADES_PRIVADES" ]; then
    echo -e "${C_ERROR}❌ ERROR: No se pudo crear el directorio de datos privados '$PATH_DADES_PRIVADES'. Saliendo.${RESET}"
	echo -e "\n"
    exit 1
fi
echo -e "${C_EXITO}✅ Directorios creados: '$FULL_PATH' y '$PATH_DADES_PRIVADES'.${RESET}"
echo -e "\n"
sleep 2

echo -e "${C_SUBTITULO}--- 3.4 Asignación de Permisos de Archivos ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------${RESET}"

# Permisos para el directorio del proyecto (propiedad del usuario de la app)
chown -R "$APP_USER":"$APP_USER" "$FULL_PATH"
echo -e "${C_EXITO}✅ Permisos para '$FULL_PATH' asignados al usuario '$APP_USER'.${RESET}"
echo -e "\n"

sleep 2

echo -e "${C_SUBTITULO}--- 3.5 Generando y configurando el Locale (ca_ES.utf8) ---${RESET}"
echo -e "${C_SUBTITULO}-----------------------------------------------------------${RESET}"

# 1. Asegurar que el locale ca_ES.utf8 esté descomentado en /etc/locale.gen
echo -e "${C_INFO}ℹ️ Descomentando 'ca_ES.utf8' en /etc/locale.gen...${RESET}"
# Usa sed para quitar el '#' al inicio de la línea, si existe.
# NOTA: Usamos 'UTF-8' con guion para coincidir con el formato del archivo.
sudo sed -i '/^# *ca_ES.UTF-8 UTF-8/s/^# *//' /etc/locale.gen

# 2. Generar todos los locales activos
echo -e "${C_INFO}ℹ️ Ejecutando locale-gen (Generará todos los locales activos)...${RESET}"
sudo locale-gen

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al generar los locales. Esto puede ser un error crítico para Django.${RESET}"
fi

# 3. Forzar la configuración del sistema
echo -e "\n"
echo -e "${C_INFO}ℹ️ Configurando el locale del sistema a 'ca_ES.UTF-8'...${RESET}"
sudo update-locale LANG=ca_ES.UTF-8

# 4. Verificación de éxito
if locale -a | grep -q -i "ca_es.utf8"; then
    echo -e "${C_EXITO}✅ Locale 'ca_ES.utf8' asegurado y configurado correctamente.${RESET}"
else
    echo -e "${C_ERROR}❌ ADVERTENCIA CRÍTICA: El locale 'ca_ES.utf8' no se pudo generar. Revise manualmente /etc/locale.gen.${RESET}"
fi

sleep 2


# ----------------------------------------------------------------------
# 4. CLONACIÓN DEL REPOSITORIO 
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}====================================================="
echo -e "${C_CAPITULO}--- 4. CLONACIÓN DEL REPOSITORIO DE LA APLICACIÓN ---"
echo -e "${C_CAPITULO}=====================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 4.1 Clonando Repositorio como usuario '$APP_USER' ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------------${RESET}"

REPO_URL="https://github.com/rafatecno1/django-aula.git"
#REPO_URL="https://github.com/ctrl-alt-d/django-aula.git"	#repositorio original del proyecto

# Usamos sudo -u como el usuario de la aplicación para clonar o actualizar

echo -e "\n"

# 1. COMPROBAR SI EL DIRECTORIO YA EXISTE
if [ -d "$FULL_PATH" ] && [ "$(ls -A "$FULL_PATH")" ]; then
    
	# Directorio existe y no está vacío -> Proceder a actualizar (pull)
	echo -e "${C_INFO}ℹ️ El directorio '$FULL_PATH' ya existe y se usará para la instalación automatizada de DJANGO-AULA para producción.${RESET}"

	# 1. Descartar todos los cambios locales para evitar el error de fusión
	echo -e "${C_INFO}⚠️ ADVERTENCIA: Intentando actualizar el repositorio y se descartarán los cambios locales no confirmados (git reset --hard) para asegurar la actualización.${RESET}"
	echo -e "${C_INFO}⚠️ No se debe actualizar de esta forma una instalación ya existente en un entorno para desarrolladores, que debería encontrarse en otro directorio diferente.${RESET}"

	echo -e "\n"
	sudo -u "$APP_USER" git -C "$FULL_PATH" reset --hard 
	# Nota: La rama local debe coincidir con la remota. Asumimos 'main' o 'master'.

	# 2. Realizar la descarga y actualización forzada
	sudo -u "$APP_USER" git -C "$FULL_PATH" pull "$REPO_URL"
    
    if [ $? -ne 0 ]; then
        echo -e "${C_ERROR}❌ ERROR: Fallo al actualizar el repositorio en '$FULL_PATH'.${RESET}"
        echo "Asegúrese de que no hay conflictos locales no resueltos."
        echo -e "\n"
        exit 1
    fi
    echo -e "${C_EXITO}✅ Repositorio actualizado con éxito en '$FULL_PATH'.${RESET}"
    
else
    
    # Directorio NO existe o está vacío -> Proceder a clonar
    echo -e "${C_INFO}Clonando $REPO_URL en $FULL_PATH. Esto puede tardar un rato...${RESET}"
    
    # Clonar el repositorio como el usuario de la aplicación
    sudo -u "$APP_USER" git clone "$REPO_URL" "$FULL_PATH"
    
    if [ $? -ne 0 ]; then
        echo -e "${C_ERROR}❌ ERROR: Fallo al clonar el repositorio '$REPO_URL'.${RESET}"
        echo "Compruebe la URL, conexión a internet o permisos del usuario '$APP_USER'."
        echo -e "\n"
        exit 1
    fi
    echo -e "${C_EXITO}✅ Repositorio clonado en '$FULL_PATH'.${RESET}"
fi

echo -e "\n"

sleep 3

# -------------------------------------------------------------------------------------------------
# CREACIÓN DEL ARCHIVO config_vars.sh CON LAS VARIABLES COMUNES PER LA INSTALACIÓN DE LA APLICACIÓN
# -------------------------------------------------------------------------------------------------

SETUP_DIR="$FULL_PATH/setup_djau"
CONFIG_FILE="$SETUP_DIR/config_vars.sh"

echo -e "${C_SUBTITULO}--- 4.2 Creación del archivo${RESET} ${CIANO}config_vars.sh${RESET} ${C_SUBTITULO}en el directorio${RESET} ${CIANO}$SETUP_DIR${RESET} ${C_SUBTITULO} ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------------------------${RESET}"

cat << EOF > "$CONFIG_FILE"

export APP_USER="$APP_USER"
export PROJECT_FOLDER="$PROJECT_FOLDER"
export FULL_PATH="$FULL_PATH"
export SETUP_DIR="$SETUP_DIR"
export PATH_DADES_PRIVADES="$PATH_DADES_PRIVADES"

EOF

chown -R "$APP_USER":"$APP_USER" "$CONFIG_FILE"

# ----------------------------------------------------------------------
# 5. DELEGACIÓN AL SCRIPT DE CONFIGURACIÓN DE DJANGO
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}==============================================================="
echo -e "${C_CAPITULO}--- 5. INICIO DE LA CONFIGURACIÓN ESPECÍFICA DE DJANGO-AULA ---"
echo -e "${C_CAPITULO}===============================================================${RESET}"
echo -e "\n"

echo -e "--- A partir de ahora el usuario ${C_INFO}'$APP_USER'${RESET} ejecutarà autmáticamente el script ${C_INFO}setup_djau.sh${RESET}."
echo -e "    Este script se encuentra en ${C_INFO}'$SETUP_DIR'${RESET}."
echo -e "\n"

# Transfiere la ejecución al script de configuración de Django DENTRO del repositorio clonado
cd "$SETUP_DIR"
chmod +x setup_djau.sh
chmod +x setup_apache.sh
chmod +x setup_cron.sh
chmod +x functions.sh 
chown "$APP_USER":"$APP_USER" functions.sh

echo -e "${C_INFO}ℹ️  **ATENCIÓN:**${RESET} La instalación no es desatendida. Haurà de proporcionar datos para configurar la Base de Datos y la Aplicación."
echo -e "\n"

read -p "Presione una tecla para continuar" -n1 -s

# Ejecuta el script de configuración de Django, pasando la ruta privada como argumento
sudo -u "$APP_USER" bash setup_djau.sh

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo en el script de configuración de Django (setup_djau.sh). Revisa los logs anteriores.${RESET}"
	echo -e "\n"
    exit 1
fi


echo -e "\n\n"
echo -e "${C_PRINCIPAL}==========================================================="
echo -e "${C_PRINCIPAL}--- FASE 1 COMPLETADA (install_djau.sh i setup_djau.sh) ---"
echo -e "${C_PRINCIPAL}===========================================================${RESET}"
echo -e "\n"

echo -e "${C_INFO}--- SIGUIENTE FASE: FASE 2 - CONFIGURACIÓN DEL SERVIDOR WEB APACHE ---${RESET}"
echo -e "\n"

echo -e "Para continuar con la configuración del servidor web Apache, ${NEGRITA}ejecute los siguientes comandos (Copiar/Pegar)${RESET}:"
echo -e "\n"

echo "   1. Cambie al directorio del proyecto:"
echo -e "      \$ ${C_SUBTITULO} cd \"$SETUP_DIR\"${RESET}"
echo -e "\n"

echo "   2. Ejecute el script de configuración del servidor web Apache (DEBE SER con sudo):"
echo -e "      \$ ${C_SUBTITULO} sudo bash setup_apache.sh${RESET}"
echo -e "\n"

echo "¡Puede proceder con la configuración del servidor web Apache!"
echo -e "\n"

