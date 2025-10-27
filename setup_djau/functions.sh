#!/bin/bash
# functions.sh
# Contiene funciones y variables de estilo comunes

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


# --------------------------------------------------
# PREGUNTA AL USUARIO Y COMPRUEBA QUE NO DEJA LA 
# RESPUESTA EN BLANCO Y SI HAY UNA RESPUESTA POR DEFECTO
# --------------------------------------------------

# Ejemplo: read_prompt "De qué color tienes el pelo?" COLOR_PELO "Azul" 

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



# ======================================================================
# Función: read_email_confirm
# Pide una dirección de correo, valida su formato con una regex simple.
#
# Uso: read_email_confirm "Mensaje de la solicitud: " VAR_NAME "valor_por_defecto"
# El correo validado se guarda en la variable de Bash con nombre $VAR_NAME.
# ======================================================================
read_email_confirm() {
    local PROMPT_MSG="$1"
    local OUTPUT_VAR_NAME="$2"
    local DEFAULT_VALUE="$3"
    local EMAIL_REGEX="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    local INPUT_VALUE=""
    local C_ERROR=$(tput setaf 1) # Rojo
    local C_INFO=$(tput setaf 6)  # Cian
    local RESET=$(tput sgr0)      # Reset
    local EMAIL_VALID=0 # 0=Inválido, 1=Válido

    while [ $EMAIL_VALID -eq 0 ]; do
        # Construir el mensaje del prompt (incluyendo el valor por defecto si existe)
        local CURRENT_PROMPT="$PROMPT_MSG"
        if [ -n "$DEFAULT_VALUE" ]; then
            CURRENT_PROMPT="$PROMPT_MSG (por defecto: $DEFAULT_VALUE): "
        fi
        
        # Leer la entrada del usuario
        read -r -p "$CURRENT_PROMPT" INPUT_VALUE

        # Si el usuario presiona Enter y hay valor por defecto, usarlo.
        if [ -z "$INPUT_VALUE" ] && [ -n "$DEFAULT_VALUE" ]; then
            INPUT_VALUE="$DEFAULT_VALUE"
        fi

        # 1. Comprobar si está vacío (no permitido en este caso)
        if [ -z "$INPUT_VALUE" ]; then
            echo -e "${C_ERROR}❌ ERROR: El correo electrónico no puede estar vacío. Inténtelo de nuevo.${RESET}"
            continue
        fi

        # 2. Comprobar el formato con la regex (se usa =~ en Bash)
        if [[ "$INPUT_VALUE" =~ $EMAIL_REGEX ]]; then
            EMAIL_VALID=1
        else
            echo -e "${C_ERROR}❌ ERROR: El formato del correo ('$INPUT_VALUE') no parece válido. Debe ser: usuario@dominio.ext. Inténtelo de nuevo.${RESET}"
        fi
    done

    # Asignar el valor validado a la variable de salida
    eval "$OUTPUT_VAR_NAME=$(printf %q "$INPUT_VALUE")"
}



# ======================================================================
# Función: read_password_confirm
# Pregunta una contraseña y la repetición, validando que coincidan y no estén vacías.
#
# Uso: read_password_confirm "Mensaje de la primera solicitud: " VAR_NAME
# La contraseña validada se guarda en la variable de Bash con nombre $VAR_NAME.
# ======================================================================

read_password_confirm() {
    local PROMPT_MSG="$1"
    local OUTPUT_VAR_NAME="$2"
    local PASSWD=""
    local PASSWD2=""
    local C_ERROR=$(tput setaf 1) # Rojo, asumiendo que ya tienes C_ERROR definido
    local RESET=$(tput sgr0)      # Reset, asumiendo que ya tienes RESET definido

    while true; do
        # Solicitud de la primera contraseña
        read -sp "$PROMPT_MSG" PASSWD
        echo

        # Solicitud de la repetición de contraseña
        read -sp "Repita la CONTRASEÑA: " PASSWD2
        echo -e "\n"

        if [ -z "$PASSWD" ] || [ -z "$PASSWD2" ]; then
            echo -e "${C_ERROR}❌ ERROR: La contraseña no puede dejarse en blanco. Inténtelo de nuevo.${RESET}\n"
        elif [ "$PASSWD" != "$PASSWD2" ]; then
            echo -e "${C_ERROR}❌ ERROR: Las contraseñas no coinciden. Inténtelo de nuevo.${RESET}\n"
        else
            # Asignar el valor final de la contraseña a la variable de salida
            # 'eval' es necesario para asignar dinámicamente el valor a una variable cuyo nombre es una cadena.
            # Se usa 'printf %q' para sanitizar el valor y evitar inyección de shell con 'eval'.
            eval "$OUTPUT_VAR_NAME=$(printf %q "$PASSWD")"
            break
        fi
    done
}


# --------------------------------------------------
# COMPRUEBA LA INSTALACIÓN DE PAQUETES E INFORMA SI HA
# HABIDO UN ERROR O SI LOS PAQUETES SE HAN INSTALADO CORRECTAMENTE
# --------------------------------------------------

# Ejemplo: check_install "Núcleo Django y Python"

check_install() {
    # $1: Descripción de los paquetes a instalar
	
    local DESC_MSG="$1" # Guarda el primer argumento (la descripción)
    local EXIT_CODE=$? # Almacena el código de salida del comando anterior

    if [ "$EXIT_CODE" -ne 0 ]; then
        echo -e "\n"
        echo -e "${C_ERROR}❌ ERROR CRÍTICO: Fallo en la instalación de: ${DESC_MSG}${RESET}"
        echo -e "${C_INFO}ℹ️ El último comando devolvió el código de error $EXIT_CODE.${RESET}"
        echo -e "${C_INFO}ℹ️ No es posible continuar. Revise la conexión, el log y ejecute el script de nuevo.${RESET}"
        echo -e "\n"
        exit 1
    else
	    echo -e "\n"
        echo -e "${C_EXITO}✅ Instalación: '${DESC_MSG}' completada con éxito.${RESET}"
    fi
    echo -e "\n"
	sleep 2
}