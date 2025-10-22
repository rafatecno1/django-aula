#!/bin/bash
# setup_cron.sh
# Configura las tareas programadas (CRON) para la aplicación Django-Aula.
# DEBE EJECUTARSE con privilegios de root (sudo bash setup_cron.sh)
# Asume que se ejecuta desde el directorio del proyecto (/opt/djau)

clear

# ----------------------------------------------------------------------
# CARGA DE VARIABLES Y FUNCIONES COMUNES A LOS SCRIPTS DE AUTOMATIZACIÓN
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "Ejecutando script setup_cron.sh."
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
    exit 1
fi

# Definiciones de Variables Clave que no existen en config_vars.sh
LOG_DIR="$FULL_PATH/log" # Directorio para guardar logs

echo -e "\n"
echo -e "${C_PRINCIPAL}=================================================================="
echo -e "${C_PRINCIPAL}--- FASE 3: TAREAS PROGRAMADAS Y MANTENIMIENTO${RESET} ${CIANO}(setup_cron.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}==================================================================${RESET}"
echo -e "\n"

# Verificación de usuario (solo informativa)

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${C_ERROR}❌ ADVERTENCIA: Este script debe ejecutarse con 'sudo bash setup_cron.sh' para modificar las tareas programadas en crontab.${RESET}"
    sleep 3
fi


# ----------------------------------------------------------------------
# 1. CREACIÓN DEL SCRIPT DE BACKUP 
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}============================================================================================================"
echo -e "${C_CAPITULO}--- 1. CREACIÓN Y CONFIGURACIÓN DEL SCRIPT QUE HARÁ LAS COPIAS DE SEGURIDAD DE LA BASE DE DATOS (BACKUP) ---"
echo -e "${C_CAPITULO}============================================================================================================${RESET}"
echo -e "\n"

NOM_SCRIPT_BACKUP="backup-bd-djau.sh"
BACKUP_SCRIPT="$FULL_PATH/$NOM_SCRIPT_BACKUP"
BACKUP_DIR="$FULL_PATH/djauBK/"


echo -e "${C_SUBTITULO}--- 1.1 Creando el directorio de backups ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------${RESET}"
echo -e "\n"

mkdir -p "$BACKUP_DIR"
chown "$APP_USER":"$APP_USER" "$BACKUP_DIR"
echo -e "${C_EXITO}✅ Directorio para las copias de seguridad (backup) '$BACKUP_DIR' creado.${RESET}"
echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 1.2 Creando el archivo${RESET} $(CIANO)'$BACKUP_SCRIPT'${RESET} ${C_SUBTITULO}---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------${RESET}"
echo -e "\n"

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
echo -e "${C_EXITO}✅ Script de backup creado${RESET} ${C_INFO}($BACKUP_SCRIPT)${RESET} ${C_EXITO}y permisos asignados a${RESET} ${C_INFO}'$APP_USER'.${RESET}"
echo -e "\n"
sleep 3

# ----------------------------------------------------------------------
# 2. GENERACIÓN DE TAREAS CRON
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}================================================="
echo -e "${C_CAPITULO}--- 2. GENERACIÓN DE TAREAS PROGRMADAS (CRON) ---"
echo -e "${C_CAPITULO}=================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 2.1 Directorio de logs${RESET} $(CIANO)($LOG_DIR)${RESET} ${C_SUBTITULO}creado ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------${RESET}"
echo -e "\n"

# Crear el directorio de logs si no existe, y darle permisos a www-data y djau
mkdir -p "$LOG_DIR"
chown "$APP_USER":www-data "$LOG_DIR"
chmod 775 "$LOG_DIR"

echo -e "${C_EXITO}✅ Directorio de logs${RESET} $(CIANO)($LOG_DIR)${RESET} ${C_EXITO}creado y permisos asignados a${RESET} ${C_INFO}'$APP_USER' y www-data.${RESET}"

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
echo -e"\n"
echo -e "${C_EXITO}✅ Archivo temporal para Crontab generado para${RESET} ${C_INFO}'$APP_USER' y www-data.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 3. INSTALAR CRONTAB
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_CAPITULO}======================================================="
echo -e "${C_CAPITULO}--- 3. INSTALACIÓN DE TAREAS CRON PARA CADA USUARIO ---"
echo -e "${C_CAPITULO}=======================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 3.1 Instalando crontab para el usuario${RESET} ${C_INFO}'$APP_USER'${RESET} ${C_SUBTITULO} (Backup) ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------${RESET}"
echo -e "\n"

# Leemos sólo la tarea 1
head -n 6 "$CRONTAB_FILE" | tail -n 2 | crontab -u "$APP_USER" -

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar la tarea de backup para '$APP_USER'.${RESET}"
else
    echo -e "${C_EXITO}✅ Tarea de backup instalada en crontab de '$APP_USER'.${RESET}"
fi
echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 3.2 Instalando crontab para el usuario${RESET} ${C_INFO}'www-data'${RESET} ${C_SUBTITULO} (Scripts) ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------${RESET}"
echo -e "\n"

# Leemos las tareas 2, 3, 4, 5 (las líneas restantes)
tail -n +8 "$CRONTAB_FILE" | crontab -u www-data -

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar las tareas para 'www-data'.${RESET}"
else
    echo -e "${C_EXITO}✅ Tareas de scripts instaladas en crontab de 'www-data'.${RESET}"
fi
sleep 3

# Limpieza
rm "$CRONTAB_FILE"

echo -e "\n"
echo -e "${C_PRINCIPAL}================================================================"
echo -e "${C_PRINCIPAL}--- FASE 3: CONFIGURACIÓN DE CRON FINALIZADA${RESET} ${CIANO}(setup_cron.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}================================================================${RESET}"
echo -e "\n"
echo "Para comprobar si las tareas han quedado instaladas teclee:"
echo -e "    $ ${C_SUBTITULO}sudo crontab -u djau -l${RESET}"
echo -e "    $ ${C_SUBTITULO}sudo crontab -u www-data -l${RESET}"
echo -e "\n\n"

echo -e "\n"
echo -e "${C_EXITO}===============================================================${RESET}"
echo -e "${C_EXITO}--- 🎉 ENHORABUENA: ¡INSTALACIÓN DE DJANGO-AULA COMPLETADA! ---${RESET}"
echo -e "${C_EXITO}===============================================================${RESET}"
echo -e "\n"
echo -e "${NEGRITA}Si ha seguido las 3 fases en el orden correcto, la aplicación ha quedado instalada con éxito.${RESET}"
echo -e "\n"
echo "DJANGO-AULA ya está configurada y lista para recibir los datos de su centro educativo."
echo -e "\n"
echo -e "${NEGRITA}➡️ SIGUIENTE PASO: Carga de Datos y Configuración Final${RESET}"
echo -e "   Consulte las instrucciones detalladas en la Wiki del proyecto:"
echo -e "   ${VERDE}https://github.com/ctrl-alt-d/django-aula/tree/master/docs/Wiki${RESET}"
echo -e "\n"
echo -e "${C_EXITO}===================================================================================${RESET}"
echo -e "\n"