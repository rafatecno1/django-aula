#!/bin/bash
# -------------------------------------------------------------
# Script per a la instal·lació ràpida de la Demo Docker de django-aula.
# Descarrega els fitxers de configuració essencials.
# -------------------------------------------------------------

# Informació del Repositori i Ubicació
REPO="rafatecno1/django-aula"
BRANCA="master"
URL_BASE="https://raw.githubusercontent.com/${REPO}/refs/heads/${BRANCA}/docker"

clear
echo -e "⚙️ Iniciant instal·lació ràpida de la Demo en Docker ...\n"

# --- 1. Definició dels Fitxers ---

# Fitxers originals a descarregar (dins la carpeta 'docker/')
FILES_TO_DOWNLOAD=(
    "docker-compose.demo.automatica.yml"
    "Makefile.demo.automatica"
    "env.demo.automatica"
)

# Fitxers de destinació (a l'arrel del projecte)
DEST_FILES=(
    "docker-compose.yml"
    "Makefile"
    ".env"
)

# --- 2. Descàrrega dels Fitxers (Usant wget) ---

for i in "${!FILES_TO_DOWNLOAD[@]}"; do
    ORIGIN_FILE="${FILES_TO_DOWNLOAD[$i]}"
    DEST_FILE="${DEST_FILES[$i]}"
    FULL_URL="${URL_BASE}/${ORIGIN_FILE}"
    
    echo "  -> Descarregant: ${ORIGIN_FILE} com a ${DEST_FILE}..."
    
    # Ús de wget: -q (mode silenciós), -O (guardar a l'arxiu especificat)
    if wget -q -O "${DEST_FILE}" "${FULL_URL}"; then
        echo "     [OK] -> Fitxer ${ORIGIN_FILE} descarregat correctament. Reanomenat com ${DEST_FILE}."
    else
        echo "     [ERROR] -> No s'ha pogut descarregar ${ORIGIN_FILE}."
        exit 1
    fi
	echo -e "\n"
done

# --- 3. Passos Post-Instal·lació ---

echo "✅ Fitxers de configuració de la Demo Docker descarregats correctament:"
echo -e "\n"
ls -lah docker-compose.yml Makefile .env

echo -e "\n"
echo "ℹ️ Indicacions importants per prosseguir:"
echo "1. Important. Les credencials del fitxer **.env** per aquesta instal·lació no s'han de modificar."
echo "2. Executeu **make serve** per posar en marxa la Demo. Aquesta se servirà per 0.0.0.0:8000"
echo "3. Executeu **make logs**, per comprovar els logs de funcionament dels contenidors."
echo "4. Si us cal detenir els contenidors de la Demo, executeu **make stop**."

exit 0
