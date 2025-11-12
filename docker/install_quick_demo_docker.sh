#!/bin/bash
# -------------------------------------------------------------
# Instal·lació ràpida de la Demo Docker de django-aula
# Descarrega els fitxers essencials i prepara la base de dades.
# -------------------------------------------------------------

# --- 1. Informació del repositori ---
REPO="rafatecno1/django-aula"
BRANCA="master"
URL_BASE="https://raw.githubusercontent.com/${REPO}/refs/heads/${BRANCA}/docker"
SQL_URL="https://raw.githubusercontent.com/${REPO}/refs/heads/${BRANCA}/docker/demo-initdb/dades_demo.sql"

clear
echo -e "⚙️  Iniciant instal·lació ràpida de la Demo en Docker...\n"

# --- 2. Fitxers a descarregar ---
FILES_TO_DOWNLOAD=(
    "docker-compose.demo.automatica.yml"
    "Makefile.demo.automatica"
    "env.demo.automatica"
)
DEST_FILES=(
    "docker-compose.yml"
    "Makefile"
    ".env"
)

# --- 3. Descarregar fitxers de configuració ---
for i in "${!FILES_TO_DOWNLOAD[@]}"; do
    ORIGIN="${FILES_TO_DOWNLOAD[$i]}"
    DEST="${DEST_FILES[$i]}"
    URL="${URL_BASE}/${ORIGIN}"

    echo "  -> Descarregant ${ORIGIN} com a ${DEST}..."
    if wget -q -O "${DEST}" "${URL}"; then
        echo "     ✅ Fitxer ${DEST} descarregat correctament."
    else
        echo "     ❌ Error en descarregar ${ORIGIN}."
        exit 1
    fi
    echo
done

# --- 4. Descarregar el fitxer SQL ---
echo "  -> Comprovant i preparant el fitxer de dades demo..."
mkdir -p dades-demo-sql

if [ ! -f "dades-demo-sql/dades_demo.sql" ]; then
    echo "     Descarregant dades_demo.sql..."
    if wget -q -O "dades-demo-sql/dades_demo.sql" "${SQL_URL}"; then
        echo "     ✅ dades_demo.sql descarregat correctament."
    else
        echo "     ❌ No s'ha pogut descarregar dades_demo.sql"
        exit 1
    fi
else
    echo "     ℹ️  El fitxer dades_demo.sql ja existeix. No es torna a descarregar."
fi

chmod 644 dades-demo-sql/dades_demo.sql
echo

# --- 5. Comprovar la presència dels fitxers ---
echo "✅ Fitxers preparats correctament:"
ls -lah docker-compose.yml Makefile .env dades-demo-sql/dades_demo.sql
echo

# --- 6. Instal·lar make si cal ---
echo "🔧 Comprovant que 'make' estigui instal·lat..."
if ! command -v make &> /dev/null; then
    echo "   Instal·lant 'make'..."
    sudo apt-get update -y && sudo apt-get install -y make
else
    echo "   ✅ 'make' ja està disponible."
fi

# --- 7. Missatge final ---
echo
echo "🚀 Instal·lació completada!"
echo
echo "ℹ️  Instruccions per posar en marxa la Demo:"
echo "1️⃣  Executeu: make serve"
echo "     -> Això crearà i iniciarà els contenidors 'demo_db' i 'demo_web'."
echo
echo "2️⃣  Per veure els logs: make logs"
echo "3️⃣  Per aturar la demo: make stop"
echo
echo "📦  Els fitxers de la base de dades es troben a ./dades-demo-sql/"
echo "     i s'importaran automàticament al primer inici del contenidor Postgres."
echo

exit 0
