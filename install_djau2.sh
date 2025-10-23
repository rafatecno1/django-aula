#!/bin/bash
# install_djau.sh
# ...

# ----------------------------------------------------------------------
# CARGA DE LIBRERÍA DE FUNCIONES Y VARIABLES DE COLOR
# ----------------------------------------------------------------------

# 1. Definir la URL remota de la librería de funciones (Ajusta esta URL)
FUNCTIONS_URL="https://raw.github.com/rafatecno1/django-aula/refs/heads/master/setup_djau/functions.sh"
FUNCTIONS_FILE="./functions.sh"

echo -e "\n"
echo "ℹ️ Descargando librería de funciones compartidas ($FUNCTIONS_FILE)..."

# 2. Descargar la librería de funciones usando wget
# La opción '-O' (mayúscula) fuerza la salida al archivo local especificado.
# La opción '-q' (quiet) suprime la salida detallada.
wget -q -O "$FUNCTIONS_FILE" "$FUNCTIONS_URL"

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Fallo al descargar el archivo de funciones desde $FUNCTIONS_URL. Saliendo."
    # No podemos usar las variables de color aquí porque aún no se han cargado.
    exit 1
fi

# 3. Cargar la librería de funciones
source "$FUNCTIONS_FILE"

# Ahora las variables de color ($C_EXITO, $C_ERROR, etc.) y read_prompt están disponibles.
echo -e "${C_EXITO}✅ Librería de funciones cargada con éxito. Comenzando la instalación...${RESET}"
echo -e "\n"

# ... (El resto del script principal, install_djau.sh, continúa aquí)