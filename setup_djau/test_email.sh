#!/bin/bash
# test_email.sh
# Permite probar la configuración de envío de correo SMTP cargada en settings_local.py
# DEBE EJECUTARSE desde el directorio raíz del proyecto (djau/).

clear

# ----------------------------------------------------------------------
# CARGA DE VARIABLES Y FUNCIONES COMUNES A LOS SCRIPTS DE AUTOMATIZACIÓN
# ----------------------------------------------------------------------
echo -e "\n"
echo -e "Ejecutando script test_email.sh."
echo -e "\n"

echo -e "${C_SUBTITULO}--- Cargando variables y funciones comunes para la instalación ---${RESET}"
echo -e "${C_SUBTITULO}------------------------------------------------------------------${RESET}"
echo -e "\n"

echo -e "Leyendo functions.sh y config_vars.sh."
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
	echo -e "\n"
    exit 1
fi

# Asegurarse de que el entorno virtual exista
VENV_PATH="$FULL_PATH/venv"

if [ ! -d "$VENV_PATH" ]; then
    echo -e "${C_ERROR}❌ ERROR: El entorno virtual de Python no se encuentra en $VENV_PATH.${RESET}"
    echo -e "Asegúrese de ejecutar este script desde el directorio raíz del proyecto y de haber ejecutado 'setup_djau.sh' alguna vez con anterioridad."
    exit 1
fi

echo -e "\n"
echo -e "${C_CAPITULO}====================================================================="
echo -e "${C_CAPITULO}--- VERIFICACIÓN DE CORREO ELECTRÓNICO (SMTP) ---${RESET}"
echo -e "${C_CAPITULO}=====================================================================${RESET}"
echo -e "\n"

# 1. Solicitar la dirección de correo destino
read_prompt "Introduzca la dirección de correo electrónico DESTINO para la prueba: " DESTINO_EMAIL

#if [ -z "$DESTINO_EMAIL" ]; then
#    echo -e "${C_INFO}ℹ️ Dirección de destino vacía. Cancelando prueba de correo.${RESET}"
#    exit 0
#fi

echo -e "\n${C_INFO}ℹ️ Enviando correo de prueba a ${NEGRITA}$DESTINO_EMAIL${RESET} usando la configuración de settings_local.py...${RESET}"

# 2. Activar el entorno virtual para la ejecución de Python
cd "$FULL_PATH"
source venv/bin/activate
#source "$VENV_PATH/bin/activate"

# 3. Código Python incrustado para la prueba

PYTHON_SCRIPT_EMAIL="temp_test_email.py"

cat << EOF_PYTHON > "$PYTHON_SCRIPT_EMAIL"
from django.core.mail import send_mail
from django.conf import settings
import sys

# La dirección del remitente ya está cargada desde settings.
remitente = settings.DEFAULT_FROM_EMAIL
# Capturamos la variable de shell DESTINO_EMAIL con f-string (seguro en Heredoc)
destinatario = ['${DESTINO_EMAIL}']

try:
    enviado = send_mail(
        'Prueba de Correo DjAu - Instalación Automatizada',
        'Este es un correo de prueba. Si lo recibe, la configuración SMTP es correcta.',
        remitente,
        destinatario,
        fail_silently=False, # Crucial para capturar excepciones
    )

    if enviado == 1:
        print('✅ ÉXITO: El correo se ha enviado correctamente. Revise la bandeja de entrada y la carpeta de SPAM.')
        sys.exit(0)
    else:
        # Esto ocurre si el servidor acepta la conexión pero rechaza el mensaje (p.ej., filtro de spam)
        print('❌ ERROR: El envío devolvió 0. El servidor SMTP pudo haber rechazado la conexión silenciosamente.')
        sys.exit(1)
except Exception as e:
    # Captura errores de conexión, autenticación, etc.
    print('❌ ERROR CRÍTICO DURANTE EL ENVÍO:')
    print(f'Tipo de error: {type(e).__name__}')
    print(f'Mensaje: {e}')
    print('Revise la configuración de EMAIL_HOST y EMAIL_HOST_PASSWORD en settings_local.py.')
    sys.exit(1)

EOF_PYTHON

# 4. Ejecutar el script temporal y capturar el código de salida
# Redirigimos la salida de error (2>&1) para que los mensajes de Python se muestren al usuario.
python manage.py shell < "$PYTHON_SCRIPT_EMAIL"
EXIT_CODE=$?

# 5. Limpieza y Desactivación
rm "$PYTHON_SCRIPT_EMAIL"
deactivate

# 6. Mostrar el resultado de la ejecución del comando Python
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${C_EXITO}✅ Prueba de correo finalizada con éxito.${RESET}"
else
    echo -e "${C_ERROR}❌ Prueba de correo fallida. Revise los errores anteriores.${RESET}"
fi

echo -e "\n"