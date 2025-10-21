#!/bin/bash
# setup_cron.sh
# Configura las tareas programadas (CRON) para la aplicación Django-Aula.
# DEBE EJECUTARSE con privilegios de root (sudo bash setup_cron.sh)
# Asume que se ejecuta desde el directorio del proyecto (/opt/djau)

# ----------------------------------------------------------------------
# 1. DEFINICIONES Y VERIFICACIÓN INICIAL
# ----------------------------------------------------------------------

echo -e "\n"
echo "======================================================================="
echo "--- ⏱️ FASE 4: TAREAS PROGRAMADAS Y MANTENIMIENTO setup_cron.sh ⏱️ ---"
echo "======================================================================="
echo -e "\n"

# Verificación de usuario (solo informativa)

if [ "$(id -u)" -ne 0 ]; then
    echo "❌ ADVERTENCIA: Este script debe ejecutarse con 'sudo bash setup_cron.sh' para modificar las tareas programadas en crontab."
    sleep 3
fi

echo "======================================================================"
echo "--- 📝 1. PREPARACIÓN DEL ENTORNO Y CARGA DE VARIABLES COMPARTIDAS ---"
echo "======================================================================"
echo -e "\n"

# Càrrega de variables comunes

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

echo -e "\n"

# Definiciones de Variables Clave que no existen en config_vars.sh

#PROJECT_FOLDER=$(basename "$PWD") # Obtiene el nombre del directorio actual (ej: djau)
#FULL_PATH="/opt/$PROJECT_FOLDER"
#APP_USER="djau" # El usuario de la aplicación
#DB_USER="djau2025" # Usuario de la Base de Datos (del ejemplo)
#DB_NAME="djau2025" # Nombre de la Base de Datos (del ejemplo)

LOG_DIR="$FULL_PATH/log" # Directorio para guardar logs


# ----------------------------------------------------------------------
# 2. CREACIÓN DEL SCRIPT DE BACKUP 
# ----------------------------------------------------------------------

echo "==============================================================================================================="
echo "--- 📝 2. CREACIÓN Y CONFIGURACIÓN DEL SCRIPT QUE HARÁ LAS COPIAS DE SEGURIDAD DE LA BASE DE DATOS (BACKUP) ---"
echo "================================================================================================================"
echo -e "\n"

NOM_SCRIPT_BACKUP="backup-bd-djau.sh"
BACKUP_SCRIPT="$FULL_PATH/$NOM_SCRIPT_BACKUP"
BACKUP_DIR="$FULL_PATH/djauBK/"

echo "--- 2.1 Creando el directorio de backups ---"
mkdir -p "$BACKUP_DIR"
chown "$APP_USER":"$APP_USER" "$BACKUP_DIR"
echo "✅ Directorio para las copias de seguridad (backup) '$BACKUP_DIR' creado."
echo -e "\n"
sleep 3


echo "--- 2.2 Creando el archivo '$BACKUP_SCRIPT' ---"
cat << EOF > "$BACKUP_SCRIPT"
#!/bin/bash
# Script de backup de PostgreSQL (Necesita permisos NOPASSWD para pg_dump instalados con el script install_app.sh)

# Variables de entorno
export PGDATABASE="$DB_NAME"
export PGUSER="$DB_USER"

ara=\`/bin/date +\%Y\%m\%d\%H\%M\`
hora=\`/bin/date +\%H\`
dia=\`/bin/date +\%d\`
mes=\`/bin/date +\%Y\%m\`
directori="$BACKUP_DIR"
copia="\${directori}bdd-ara-\${ara}.sql"
extensio=".bz2"

# Asegurar que el directorio existe
mkdir -p "\$directori"

# Realizar el dump de la base de datos
# NOTA: pg_dump necesita que el usuario $APP_USER tenga NOPASSWD para 'pg_dump' que ya se configuró en el script install_djau.sh
/usr/bin/pg_dump > "\$copia"

# Comprimir el archivo
/bin/bzip2 "\$copia"

# Crear los enlaces (copias) rotativas
cat "\${copia}\${extensio}" > "\${directori}bdd-hora-\${hora}.sql\${extensio}" 
cat "\${copia}\${extensio}" > "\${directori}bdd-dia-\${dia}.sql\${extensio}" 
cat "\${copia}\${extensio}" > "\${directori}bdd-mes-\${mes}.sql\${extensio}" 

# Eliminar el backup temporal
rm "\$copia\${extensio}"
EOF

# Asignar propietario y permisos de ejecución
chown "$APP_USER":"$APP_USER" "$BACKUP_SCRIPT"
chmod +x "$BACKUP_SCRIPT"
echo "✅ Script de backup creado ($BACKUP_SCRIPT) y permisos asignados a '$APP_USER'."
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 3. INSTALACIÓN DE TAREAS CRON
# ----------------------------------------------------------------------

echo "================================================================="
echo "--- 🚀 3. GENERACIÓN DE TAREAS CRON PARA LOS USUARIOS ---"
echo "================================================================="
echo -e "\n"

# Crear el directorio de logs si no existe, y darle permisos a www-data y djau
mkdir -p "$LOG_DIR"
chown "$APP_USER":www-data "$LOG_DIR"
chmod 775 "$LOG_DIR"

echo "--- 3.1 Directorio de logs ($LOG_DIR) creado ---"
sleep 3

# La sintaxis de los comandos en crontab cambia ligeramente para adaptarse a la ejecución directa
CRONTAB_FILE="/tmp/crontab_${PROJECT_FOLDER}.tmp"

# Crear el contenido del crontab
# NOTA: Se usa el comando 'bash -c' para que CRON interprete correctamente las barras invertidas
# y las variables de fecha (`date`).
# setup_cron.sh - Bloque de Generación de Crontab (Asegúrate de usar TAB para la indentación)

cat <<- CRONEOF > "$CRONTAB_FILE"
# =================================================================
# TAREAS PROGRAMADAS PARA DJANGO-AULA ($PROJECT_FOLDER)
# =================================================================

# Tarea 1: Backup de Base de Datos (EJECUTADO COMO USUARIO '$APP_USER')
	0,20,40 * * * * $BACKUP_SCRIPT >> $LOG_DIR/backup.log 2>&1

# Tarea 2: Notificación a familias
# EJECUTADO COMO USUARIO www-data
	42 8,9,10,11,12,13,14,15,16,17,18,19,20,21 * * 1-5 bash -c "$FULL_PATH/scripts/notifica_families.sh >> $LOG_DIR/notifica_families_\`date +\%Y_\%m_\%d\`.log 2>&1"

# Tarea 3: Preescritura de incidencias
# EJECUTADO COMO USUARIO www-data
	41 00 * * 1-5 bash -c "$FULL_PATH/scripts/preescriu_incidencies.sh >> $LOG_DIR/prescriu_incidencies_\`date +\%Y_\%m_\%d\`.log 2>&1"

# Tarea 4: Sincronización de presencia
# EJECUTADO COMO USUARIO www-data
	20,50 * * * 1-5 bash -c "$FULL_PATH/scripts/sortides_sincronitza_presencia.sh >> $LOG_DIR/sincro_presencia_\`date +\%Y_\%m_\%d\`.log 2>&1"

# Tarea 5: Aviso a tutores de faltas
# EJECUTADO COMO USUARIO www-data
	30 2 * * 2,4,6 bash -c "$FULL_PATH/scripts/avisa_tutor_faltes.sh >> $LOG_DIR/avisa_tutor_faltes_\`date +\%Y_\%m_\%d\`.log 2>&1"

CRONEOF
# ...
echo "--- 3.2 Archivo temporal para Crontab generado para '$APP_USER' y 'www-data' ---"
sleep 3

# ----------------------------------------------------------------------
# 4. INSTALAR CRONTAB
# ----------------------------------------------------------------------

echo -e "\n"
echo "================================================================="
echo "--- 🚀 4. INSTALACIÓN DE TAREAS CRON PARA CADA USUARIO ---"
echo "================================================================="
echo -e "\n"

echo "--- 4.1 Instalando crontab para el usuario '$APP_USER' (Backup) ---"

# Leemos sólo la tarea 1
head -n 6 "$CRONTAB_FILE" | tail -n 2 | crontab -u "$APP_USER" -

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al instalar la tarea de backup para '$APP_USER'."
else
    echo "✅ Tarea de backup instalada en crontab de '$APP_USER'."
fi
echo -e "\n"
sleep 3

echo "--- 4.2 Instalando crontab para el usuario 'www-data' (Scripts) ---"
# Leemos las tareas 2, 3, 4, 5 (las líneas restantes)
tail -n +8 "$CRONTAB_FILE" | crontab -u www-data -

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al instalar las tareas para 'www-data'."
else
    echo "✅ Tareas de scripts instaladas en crontab de 'www-data'."
fi
sleep 3

# Limpieza
rm "$CRONTAB_FILE"

echo -e "\n"
echo "================================================================="
echo "--- 🟢 CONFIGURACIÓN DE CRON FINALIZADA 🟢 ---"
echo "La instalación de las tareas programadas han sido completadas."
echo "================================================================="
echo -e "\n"
echo "Para comprobar si las tareas han quedado instaladas teclee:"
echo "    $ sudo crontab -u djau -l"
echo "    $ sudo crontab -u www-data -l"
echo -e "\n\n"


# Definiciones de Color (se asume que están definidas al inicio del script)
RESET='\e[0m'
VERDE='\e[32m'
NEGRITA='\e[1m'
C_EXITO="${NEGRITA}${VERDE}"

echo -e "\n"
echo -e "${C_EXITO}===============================================================${RESET}"
echo -e "${C_EXITO}--- 🎉 ENHORABUENA: ¡INSTALACIÓN DE DJANGO-AULA COMPLETADA! ---${RESET}"
echo -e "${C_EXITO}===============================================================${RESET}"
echo -e "\n"
echo -e "${NEGRITA}Si ha seguido las 4 fases en el orden correcto, la aplicación ha quedado instalada con éxito.${RESET}"
echo -e "\n"
echo "DJANGO-AULA ya está configurada y lista para recibir los datos de su centro educativo."
echo -e "\n"
echo -e "${NEGRITA}➡️ SIGUIENTE PASO: Carga de Datos y Configuración Final${RESET}"
echo -e "   Consulte las instrucciones detalladas en la Wiki del proyecto:"
echo -e "   ${VERDE}https://github.com/ctrl-alt-d/django-aula/tree/master/docs/Wiki${RESET}"
echo -e "\n"
echo -e "${C_EXITO}===================================================================================${RESET}"
echo -e "\n"