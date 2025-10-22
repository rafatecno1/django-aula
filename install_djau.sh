#!/bin/bash
# install_djau.sh
# Script Maestro de Instalación de la Aplicación Django-Aula.
# Se encarga de la configuración del sistema, usuarios y permisos.
# DEBE EJECUTARSE con privilegios de root (p. ej., sudo bash install_app.sh).

# Definiciones de Color ANSI (ejemplo para la visualización)
#RESET='\e[0m'
#VERDE='\e[32m'
#AZUL='\e[34m'
#NEGRITA='\e[1m'
#C_TITULO="${NEGRITA}${AZUL}"
#C_ACCION="${NEGRITA}${VERDE}"
#C_INFO="${VERDE}"



# --------------------------------------------------
# VARIABLES DE COLOR Y ESTILO ANSI
# --------------------------------------------------

RESET='\e[0m'
NEGRITA='\e[1m'

# Colores básicos
AZUL='\e[34m'
VERDE='\e[32m'
ROJO='\e[31m'
CIANO='\e[36m'
AMARILLO='\e[33m'
MAGENTA='\e[35m'

# Estilos compuestos (para uso en los scripts)
C_EXITO="${NEGRITA}${VERDE}"       # Éxito y confirmaciones (✅)
C_ERROR="${NEGRITA}${ROJO}"        # Errores y fallos (❌)
C_PRINCIPAL="${NEGRITA}${AZUL}"   # Fases principales (FASE 1, FASE 2)
C_CAPITULO="${NEGRITA}${CIANO}"     # Títulos de Capítulo (1. DEFINICIÓN...)
C_SUBTITULO="${NEGRITA}${MAGENTA}" # Títulos de Subcapítulo (1.1, 1.2)
C_INFO="${NEGRITA}${AMARILLO}"     # Información importante (INFO, ATENCIÓN)



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

# -----------------------------------------------------------------------------------
# FUNCION DE AYUDA
# Se encuentra tambien en el archivo functions.sh para poder reutilizarla en el resto
# de los sripts pero ahora no está disponible hasta que no se clone el repositorio.
# -----------------------------------------------------------------------------------

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
                echo -e "${C_EXITO}☑️ Valor por defecto usado: '$DEFAULT_VALUE'${RESET}"
				echo -e "\n"
                break
            else
                # A.2) Si NO hay valor por defecto, el campo es obligatorio.
                echo -e "${C_ERROR}❌ ERROR: Este campo no puede dejarse en blanco.${RESET}\n"
                # Vuelve a iterar el bucle (while true)
            fi
        else
            # B) Si hay entrada del usuario, usarla y salir.
            eval "$VAR_NAME='$INPUT_VALUE'"
            echo -e "${C_EXITO}☑️ Valor introducido: '$INPUT_VALUE'${RESET}"
			echo -e "\n"
            break
        fi
    done
}


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
echo -e "\n"

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
echo -e "\n"


# 3. Usuario de la Aplicación
read_prompt "Introduce el nombre del USUARIO de la aplicación (debe existir y tener sudo) (por defecto: djau): " APP_USER "djau"

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

echo -e "\n"
echo -e "${C_CAPITULO}========================================================="
echo -e "${C_CAPITULO}--- 2. CONFIGURACIÓN DE SEGURIDAD (Permisos NOPASSWD) ---"
echo -e "${C_CAPITULO}=========================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- Configurando Permisos NOPASSWD para PostgreSQL ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------${RESET}"
echo -e "\n"


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

echo -e "\n"
echo -e "${C_CAPITULO}============================================================="
echo -e "${C_CAPITULO}--- 3. INSTALACIÓN DE DEPENDENCIAS Y PREPARACIÓN DE RUTAS ---"
echo -e "${C_CAPITULO}=============================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 3.1 Instalando dependencias del sistema (Python, Git, PostgreSQL, etc). Ahora no se instalará el servidor web ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------------------------------------------------------------------------${RESET}"
echo -e "\n"

# 1. Actualizar la lista de paquetes
echo -e "${C_INFO}ℹ️ Actualizando la lista de paquetes (apt update)...${RESET}"
echo -e "\n"
apt update
echo -e "\n"

# 2. Actualizar los paquetes existentes
echo -e "${C_INFO}ℹ️ Actualizando el sistema (apt upgrade -y)...${RESET}"
echo -e "\n"
apt upgrade -y

if [ $? -ne 0 ]; then
    echo -e "\n"
    echo -e "${C_ERROR}❌ ERROR: Fallo al actualizar los paquetes existentes (apt upgrade).${RESET}"
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
echo -e "${C_INFO}ℹ️ Instalando dependencias requeridas...${RESET}"

apt install -y python3 python3-venv libxml2-dev libxslt-dev python3-lxml python3-libxml2 python3-dev lib32z1-dev git libgl1 libglib2.0-0t64 postgresql

if [ $? -ne 0 ]; then
    echo -e "\n"
    echo -e "${C_ERROR}❌ ERROR: Fallo CRÍTICO en la instalación de dependencias del sistema (apt install).${RESET}"
    echo -e "${C_INFO}ℹ️ No es posible continuar sin estos paquetes. Revise la conexión, el log y ejecute el script de nuevo.${RESET}"
	echo -e "\n"
    exit 1
fi

echo -e "\n"
echo -e "${C_EXITO}✅ Dependencias del sistema instaladas y sistema actualizado correctamente.${RESET}"
echo -e "\n"
sleep 2


echo -e "${C_SUBTITULO}--- 3.2 Creación de directorios para el proyecto DJANGO-AULA y para los datos privados del proyecto ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------------------------------------------${RESET}"
echo -e "\n"


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

echo -e "${C_SUBTITULO}--- 3.3 Asignación de Permisos de Archivos ---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------${RESET}"
echo -e "\n"


# Permisos para el directorio del proyecto (propiedad del usuario de la app)
chown -R "$APP_USER":"$APP_USER" "$FULL_PATH"
echo -e "${C_EXITO}✅ Permisos para '$FULL_PATH' asignados al usuario '$APP_USER'.${RESET}"

echo -e "\n"
sleep 2

# ----------------------------------------------------------------------
# 4. CLONACIÓN DEL REPOSITORIO 
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}====================================================="
echo -e "${C_CAPITULO}--- 4. CLONACIÓN DEL REPOSITORIO DE LA APLICACIÓN ---"
echo -e "${C_CAPITULO}=====================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 4.1 Clonando Repositorio como usuario '$APP_USER' ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------------${RESET}"
echo -e "\n"

REPO_URL="https://github.com/rafatecno1/django-aula.git"
#REPO_URL="https://github.com/ctrl-alt-d/django-aula.git"	#repositorio original del proyecto

# Usamos sudo -u para clonar como el usuario de la aplicación

echo -e "${C_INFO}Clonando $REPO_URL en $FULL_PATH. Esto puede tardar un rato...${RESET}"
echo -e "\n"

sudo -u "$APP_USER" git clone "$REPO_URL" "$FULL_PATH"
if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al clonar el repositorio '$REPO_URL'.${RESET}"
    echo "Comprueba que la URL sea correcta, que haiga conexión a internet, o que el usuario '$APP_USER' tenga permisos de red."
	echo -e "\n"
    exit 1
fi
echo -e "\n"
echo -e "${C_EXITO}✅ Repositorio clonado en '$FULL_PATH'.${RESET}"
echo -e "\n"
sleep 3

# -------------------------------------------------------------------------------------------------
# CREACIÓN DEL ARCHIVO config_vars.sh CON LAS VARIABLES COMUNES PER LA INSTALACIÓN DE LA APLICACIÓN
# -------------------------------------------------------------------------------------------------

SETUP_DIR="$FULL_PATH/setup_djau"
CONFIG_FILE="$SETUP_DIR/config_vars.sh"

echo -e "${C_SUBTITULO}--- 4.2 Creación del archivo${RESET} ${CIANO}config_vars.sh${RESET} ${C_SUBTITULO}en el directorio${RESET} ${CIANO}$SETUP_DIR${RESET} ${C_SUBTITULO} ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------------------------${RESET}"
echo -e "\n"

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

echo -e "\n"
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



echo -e "\n"
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

