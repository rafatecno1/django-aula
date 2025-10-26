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

# --------------------------------------------------
# COMPRUEBA LA INSTALACIÓN DE PAQUEGES E INFORMA SI HA
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