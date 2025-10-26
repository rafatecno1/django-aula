#!/bin/bash
# test_email.sh
# Permite probar la configuración de envío de correo SMTP cargada en settings_local.py
# DEBE EJECUTARSE desde el directorio raíz del proyecto (djau/).

# Cargar variables comunes y funciones
source "./functions.sh"
source "./config_vars.sh" # Contiene FULL_PATH, PROJECT_FOLDER, etc.
cd ..

# Asegurarse de que el entorno virtual exista
VENV_PATH="$FULL_PATH/venv"
if [ ! -d "$VENV_PATH" ]; then
    echo -e "${C_ERROR}❌ ERROR: El entorno virtual de Python no se encuentra en $VENV_PATH.${RESET}"
    echo -e "Asegúrese de ejecutar este script desde el directorio raíz del proyecto y de haber ejecutado 'setup_djau.sh'."
    exit 1
fi

echo -e "\n"
echo -e "${C_CAPITULO}====================================================================="
echo -e "${C_CAPITULO}--- VERIFICACIÓN DE CORREO ELECTRÓNICO (SMTP) ---${RESET}"
echo -e "${C_CAPITULO}=====================================================================${RESET}"
echo -e "\n"

# 1. Solicitar la dirección de correo destino
read_prompt "Introduzca la dirección de correo electrónico DESTINO para la prueba: " DESTINO_EMAIL

if [ -z "$DESTINO_EMAIL" ]; then
    echo -e "${C_INFO}ℹ️ Dirección de destino vacía. Cancelando prueba de correo.${RESET}"
    exit 0
fi

echo -e "\n${C_INFO}ℹ️ Enviando correo de prueba a ${NEGRITA}$DESTINO_EMAIL${RESET} usando la configuración de settings_local.py...${RESET}"

# 2. Activar el entorno virtual para la ejecución de Python
source "$VENV_PATH/bin/activate"

# 3. Código Python incrustado para la prueba
python -c "
from django.core.mail import send_mail
from django.conf import settings
import sys

# La dirección del remitente ya está cargada desde settings
remitente = settings.DEFAULT_FROM_EMAIL
destinatario = ['${DESTINO_EMAIL}']

try:
    enviado = send_mail(
        'Prueba de Correo DjAu - Instalación Automatizada',
        'Este es un correo de prueba. Si lo recibe, la configuración SMTP es correcta.',
        remitente,
        destinatario,
        fail_silently=False,
    )

    if enviado == 1:
        print('\n✅ ÉXITO: El correo se ha enviado correctamente.')
        print('Revise la bandeja de entrada y la carpeta de SPAM.')
        sys.exit(0)
    else:
        print('\n❌ ERROR: El envío devolvió 0. El servidor SMTP pudo haber rechazado la conexión silenciosamente.')
        sys.exit(1)
except Exception as e:
    print('\n❌ ERROR CRÍTICO DURANTE EL ENVÍO:')
    print(f'Tipo de error: {type(e).__name__}')
    print(f'Mensaje: {e}')
    print('\nRevise la configuración de EMAIL_HOST y EMAIL_HOST_PASSWORD en settings_local.py.')
    sys.exit(1)
"
# 4. Desactivar el entorno virtual
deactivate

# 5. Mostrar el resultado de la ejecución del comando Python
if [ $? -eq 0 ]; then
    echo -e "${C_EXITO}✅ Prueba de correo finalizada con éxito.${RESET}"
else
    echo -e "${C_ERROR}❌ Prueba de correo fallida. Revise los errores anteriores.${RESET}"
fi

echo -e "\n"
