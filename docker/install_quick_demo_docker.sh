#!/bin/bash
# -------------------------------------------------------------
# Script per a la instal·lació ràpida de la Demo Docker de django-aula.
# Descarrega els fitxers de configuració essencials.
# -------------------------------------------------------------

# Informació del Repositori i Ubicació
REPO="rafatecno1/django-aula"
BRANCA="master"
URL_BASE="https://raw.githubusercontent.com/${REPO}/refs/heads/${BRANCA}/docker"

echo "⚙️ Iniciant instal·lació ràpida de Docker Demo..."

# --- 1. Definició dels Fitxers ---

# Fitxers originals a descarregar (dins la carpeta 'docker/')
FILES_TO_DOWNLOAD=(
    "docker-compose.demo.automatica.yml"
    "Makefile.demo.automatica"
    ".env.demo.automatica"
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
        echo "     [OK] Fitxer ${ORIGIN_FILE} descarregat correctament i reanomenat com ${DEST_FILE}."
    else
        echo "     [ERROR] No s'ha pogut descarregar ${ORIGIN_FILE}."
        exit 1
    fi
done

# --- 3. Passos Post-Instal·lació ---

echo "✅ Fitxers de configuració de la Demo Docker descarregats correctament:"
ls -l docker-compose.yml Makefile .env

echo "ℹ️ Propers passos:"
echo "1. Les credencials del fitxer **.env** per aquesta instal·lació no s'han de modificar."
echo "2. Executeu **make serve** (requereix Docker i Docker Compose instal·lats)."
echo "3. Executeu **make logs**, per comprovar els logs de funcionament dels contenidors."

exit 0
