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
echo -e "\n"

# 1. CARGAR LIBRERÍA DE FUNCIONES (Contiene tambien las variables de color)
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

# Verificación de usuario (solo informativa)

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${C_ERROR}❌ ADVERTENCIA: Este script debe ejecutarse con 'sudo bash setup_cron.sh' para modificar las tareas programadas en crontab.${RESET}"
    sleep 3
fi


# ----------------------------------------------------------------------
# 1. CREACIÓN DEL SCRIPT DE BACKUP 
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}============================================================================================================"
echo -e "${C_CAPITULO}--- 1. CREACIÓN Y CONFIGURACIÓN DEL SCRIPT QUE HARÁ LAS COPIAS DE SEGURIDAD DE LA BASE DE DATOS (BACKUP) ---"
echo -e "${C_CAPITULO}============================================================================================================${RESET}"
echo -e "\n"

NOM_SCRIPT_BACKUP="backup-bd-djau.sh"
BACKUP_SCRIPT="$FULL_PATH/$NOM_SCRIPT_BACKUP"
BACKUP_DIR="$FULL_PATH/djauBK/"


echo -e "${C_SUBTITULO}--- 1.1 Creando el directorio de backups ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------${RESET}"

mkdir -p "$BACKUP_DIR"
chown "$APP_USER":"$APP_USER" "$BACKUP_DIR"
echo -e "${C_EXITO}✅ Directorio para las copias de seguridad (backup)${RESET} ${C_INFO}$BACKUP_DIR ${C_EXITO}creado.${RESET}"
echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 1.2 Creando el archivo${RESET} ${CIANO}$BACKUP_SCRIPT${RESET} ${C_SUBTITULO}---${RESET}"
echo -e "${C_SUBTITULO}----------------------------------------------------------${RESET}"

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
echo -e "${C_EXITO}✅ Script de backup creado${RESET} ${C_INFO}$BACKUP_SCRIPT${RESET} ${C_EXITO}y permisos asignados a${RESET} ${C_INFO}$APP_USER.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 2. GENERACIÓN DE TAREAS CRON
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}================================================="
echo -e "${C_CAPITULO}--- 2. GENERACIÓN DE TAREAS PROGRMADAS (CRON) ---"
echo -e "${C_CAPITULO}=================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 2.1 Directorio de logs${RESET} ${CIANO}$LOG_DIR${RESET} ${C_SUBTITULO}creado ---${RESET}"
echo -e "${C_SUBTITULO}---------------------------------------------------${RESET}"

# Crear el directorio de logs si no existe, y darle permisos a www-data y djau
mkdir -p "$LOG_DIR"
chown "$APP_USER":www-data "$LOG_DIR"
chmod 775 "$LOG_DIR"

echo -e "${C_EXITO}✅ Directorio de logs${RESET} ${C_INFO}$LOG_DIR${RESET} ${C_EXITO}creado y permisos asignados a${RESET} ${C_INFO}$APP_USER${RESET} ${C_EXITO}y${RESET} ${C_INFO}www-data.${RESET}"
echo -e "\n"
sleep 3

# =====================================================================
# CREACIÓN DE ARCHIVOS TEMPORALES SEPARADOS PARA CRONTAB
# =====================================================================

CRONTAB_FILE_APP_USER="/tmp/crontab_${PROJECT_FOLDER}_$APP_USER.tmp"
CRONTAB_FILE_WWW_DATA="/tmp/crontab_${PROJECT_FOLDER}_www-data.tmp"

# --- 2.2 Archivo Temporal para el usuario de la aplicación ($APP_USER) ---
echo -e "${C_SUBTITULO}--- 2.2 Generando archivo temporal para el usuario '$APP_USER' ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------${RESET}"

cat <<- CRONEOF_APP > "$CRONTAB_FILE_APP_USER"
# =================================================================
# TAREAS PROGRAMADAS PARA DJANGO-AULA ($PROJECT_FOLDER)
# USUARIO: $APP_USER
# 
# FORMATO CRON: minuto (0-59) hora (0-23) dia_mes (1-31) mes (1-12) dia_semana (0-7, 0=7=Dom)
# =================================================================

# Tarea 1: Backup de Base de Datos (Ejecución cada 20 minutos)
# Utiliza el script '$BACKUP_SCRIPT' generado en el paso 1.
	0,20,40 * * * * $BACKUP_SCRIPT >> $LOG_DIR/backup.log 2>&1

CRONEOF_APP

echo -e "${C_EXITO}☑️ Archivo temporal para backup${RESET} ${C_INFO}$CRONTAB_FILE_APP_USER${RESET} ${C_EXITO}generado.${RESET}"
echo -e "\n"
sleep 2

# --- 2.3 Archivo Temporal para el usuario www-data ---
echo -e "${C_SUBTITULO}--- 2.3 Generando archivo temporal para el usuario 'www-data' ---${RESET}"
echo -e "${C_SUBTITULO}-----------------------------------------------------------------${RESET}"

cat <<- CRONEOF_WWW > "$CRONTAB_FILE_WWW_DATA"
# =================================================================
# TAREAS PROGRAMADAS PARA DJANGO-AULA ($PROJECT_FOLDER)
# USUARIO: www-data
# 
# FORMATO CRON: minuto (0-59) hora (0-23) dia_mes (1-31) mes (1-12) dia_semana (0-7, 0=7=Dom)
# =================================================================

# Tarea 2: Notificación a familias cada dia de la semana, excepto el Sábado y el Domingo.
#          La notificación se produce en el minuto 42 de cada hora, comenzando a las 8:42h de la mañana y acabando a las 21:42h de la noche.
	42 8,9,10,11,12,13,14,15,16,17,18,19,20,21 * * 1-5 bash -c "$FULL_PATH/scripts/notifica_families.sh >> $LOG_DIR/notifica_families_\`date +\%Y_\%m_\%d\`.log 2>&1"

# Tarea 3: Preescritura de incidencias cada dia de la semana, excepto el Sábado y el Domingo.
#          La preescritura se produce siempre 41 minutos despues de la medianoche.
	41 00 * * 1-5 bash -c "$FULL_PATH/scripts/preescriu_incidencies.sh >> $LOG_DIR/prescriu_incidencies_\`date +\%Y_\%m_\%d\`.log 2>&1"

# Tarea 4: Sincronización de presencia cada 30 minutos, cada dia de la semana, excepto el Sábado y el Domingo.
#          La sincronización de presencia se produce siempre en el minuto 20 y en el minunto 50 de cada hora.
	20,50 * * * 1-5 bash -c "$FULL_PATH/scripts/sortides_sincronitza_presencia.sh >> $LOG_DIR/sincro_presencia_\`date +\%Y_\%m_\%d\`.log 2>&1"

# Tarea 5: Aviso a tutores de faltas (se produce a las 2:30h de la madrugada de los Martes, Jueves y Sábado)
	30 2 * * 2,4,6 bash -c "$FULL_PATH/scripts/avisa_tutor_faltes.sh >> $LOG_DIR/avisa_tutor_faltes_\`date +\%Y_\%m_\%d\`.log 2>&1"

CRONEOF_WWW

echo -e "${C_EXITO}☑️ Archivo temporal para scripts${RESET} ${C_INFO}$CRONTAB_FILE_WWW_DATA ${C_EXITO}generado.${RESET}"
sleep 3

# ----------------------------------------------------------------------
# 3. INSTALACIÓN DE TAREAS CRON
# ----------------------------------------------------------------------

echo -e "\n\n"
echo -e "${C_CAPITULO}======================================================="
echo -e "${C_CAPITULO}--- 3. INSTALACIÓN DE TAREAS CRON PARA CADA USUARIO ---"
echo -e "${C_CAPITULO}=======================================================${RESET}"
echo -e "\n"

echo -e "${C_SUBTITULO}--- 3.1 Instalando crontab para el usuario${RESET} ${CIANO}'$APP_USER'${RESET}${C_SUBTITULO} (Backup) ---${RESET}"
echo -e "${C_SUBTITULO}--------------------------------------------------------------${RESET}"

# Instalación directa del archivo temporal para APP_USER
crontab -u "$APP_USER" "$CRONTAB_FILE_APP_USER"

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar la tarea de backup para '$APP_USER'.${RESET}"
else
    echo -e "${C_EXITO}✅ Tarea de backup instalada en crontab de${RESET} ${C_INFO}$APP_USER${RESET}"
fi
echo -e "\n"
sleep 3

echo -e "${C_SUBTITULO}--- 3.2 Instalando crontab para el usuario${RESET} ${CIANO}'www-data'${RESET}${C_SUBTITULO} (Scripts) ---${RESET}"
echo -e "${C_SUBTITULO}-------------------------------------------------------------------${RESET}"

# Instalación directa del archivo temporal para www-data
crontab -u www-data "$CRONTAB_FILE_WWW_DATA"

if [ $? -ne 0 ]; then
    echo -e "${C_ERROR}❌ ERROR: Fallo al instalar las tareas para 'www-data'.${RESET}"
else
    echo -e "${C_EXITO}✅ Tareas de scripts instaladas en crontab de${RESET} ${C_INFO}www-data${RESET}"
fi
sleep 3

# Limpieza de ambos archivos temporales
rm "$CRONTAB_FILE_APP_USER" "$CRONTAB_FILE_WWW_DATA"

clear

echo -e "\n"
echo -e "${C_PRINCIPAL}================================================================"
echo -e "${C_PRINCIPAL}--- FASE 3: CONFIGURACIÓN DE CRON FINALIZADA${RESET} ${CIANO}(setup_cron.sh)${RESET} ${C_PRINCIPAL}---"
echo -e "${C_PRINCIPAL}================================================================${RESET}"
echo -e "\n"
echo "   Para comprobar si las tareas han quedado instaladas teclee:"
echo -e "      $ ${C_SUBTITULO}sudo crontab -u $APP_USER -l${RESET}"
echo -e "      $ ${C_SUBTITULO}sudo crontab -u www-data -l${RESET}"
echo -e "\n"

sleep 5

echo -e "${C_EXITO}===============================================================${RESET}"
echo -e "${C_EXITO}--- 🎉 ENHORABUENA: ¡INSTALACIÓN DE DJANGO-AULA COMPLETADA! ---${RESET}"
echo -e "${C_EXITO}===============================================================${RESET}"
echo -e "\n"
echo "Si ha seguido las 3 fases indicadas en el orden correcto y no ha habido errores en el proceso..."
echo -e "${NEGRITA}La aplicación DJANGO-AULA habrá quedado instalada con éxito.${RESET}. A partir de ahora DJANGO-AULA (DjAu) ya está listo para recibir los datos de su centro educativo."
echo -e "\n"
echo -e "${NEGRITA}➡️ SIGUIENTE PASO: Carga de Datos y Configuración del curso escolar.${RESET}"
echo -e "   Consulte las instrucciones detalladas para todo el proceso de la carga de datos en el apartado correspondiente en GitHub"

# ----------------------------------------------------------------------
# PAS FINAL: ADVERTÈNCIA DE SEGURETAT CRÍTICA
# ----------------------------------------------------------------------

echo -e "\n"
echo -e "${C_TITULO}================================================${RESET}"
echo -e "${C_ERROR}🚨 ALERTA DE SEGURETAT CRÍTICA: MODO DEBUG ACTIU!${RESET}"
echo -e "${C_TITULO}================================================${RESET}"
echo -e "L'aplicatiu DJNGO-AULA s'ha instal·lat amb ${C_ERROR}DEBUG = True${RESET}, visible a l'inici de l'arxiu /aula/settings_local.py."
echo -e "Aquest mode és útil abans de la càrrega de dades pel curs escolar ${C_INFO}(configuració inicial del curs)${RESET}, però també per ${C_INFO}depuració d'errors${RESET} quan l'aplicatiu està funcionant a mig curs."
echo ""
echo "En mode DEBUG:"
echo "* L'aplicatiu només permetrà l'accés a usuaris amb permisos d'administració (o molt elevats)."
echo "* Exposarà informació tècnica sensible si es produeixen errors."
echo ""
echo "🛑 ACCIÓ REQUERIDA PER POSAR EN PRODUCCIÓ:"
echo "----------------------------------------"
echo -e "1. ${C_EXITO}Un cop finalitzada la càrrega inicial de dades, configuració dels usuaris i de totes les particularitats del curs escolar:${RESET}"
echo -e "2. Editi l'arxiu ${C_EXITO}'$FULL_PATH/aula/settings_local.py'${RESET}"
echo "3. Canviï la línia:"
echo -e "   DEBUG = ${C_ERROR}True${RESET}"
echo "   Per:"
echo -e "   DEBUG = ${C_EXITO}False${RESET}"
echo -e "4. ${C_EXITO}Reiniciï el servidor Apache (sudo systemctl restart apache2) o, per a més seguretat, tot el servidor.${RESET}"
echo -e "${C_TITULO}====================================================================================================${RESET}"
echo -e "\n"
