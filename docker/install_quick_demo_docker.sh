#!/bin/bash
# -------------------------------------------------------------
# Script per a la instal·lació ràpida de la Demo Docker de django-aula.
# Descarrega els fitxers de configuració essencials i comprova la base de dades.
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
    sudo apt-get update -y >/dev/null 2>&1 && sudo apt-get install -y make
else
    echo "   ✅ 'make' ja està disponible."
fi


# --- 7. Pregunta pel domini o IP ---

echo
echo "🌍 Si la Demo ha de funcionar en una xarxa local cal definir quina IP té. Si es vol instal·lar en un servidor en internet (VPS) caldrà informar de la seva IP pública y del domini o subdomini, si n'hi ha."
echo -e "\n"
read -p "Vol afegir un domini o IP a **DEMO_ALLOWED_HOSTS** per poer accedir-hi externament a la Demo? (y/n): " REPLY

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "👉 Introdueix els dominis o IPs separats per comes (ex: demo.elteudomini.cat,192.168.1.46): " HOSTS
    if [ -n "$HOSTS" ]; then
        sed -i "s|^DEMO_ALLOWED_HOSTS=.*|DEMO_ALLOWED_HOSTS=${HOSTS}|" .env
        echo "✅ Fitxer .env actualitzat amb DEMO_ALLOWED_HOSTS=${HOSTS}"
    else
        echo "⚠️ No s'ha introduït cap domini/IP. Es manté buit."
    fi
else
    echo "ℹ️ No s'ha modificat DEMO_ALLOWED_HOSTS. Es manté buit."
fi


# --- 8. Posar en marxa els contenidors ---

echo
echo "🕓 Iniciant comprovació..."
echo "   -> Posant en marxa els contenidors (si no ho has fet abans)..."
make serve


# --- 9. Esperar que la base de dades estigui llesta ---


# Comprovant que l'arxiu .env existeix
if [ -f .env ]; then
    set -a
    source .env # carregar DB_USER, etc.
    set +a
else
    echo "⚠️  No s'ha trobat el fitxer .env. No es pot comprovar l'estat de la base de dades."
    exit 1
fi

echo "⌛ Esperant que la base de dades estigui llesta (pot trigar uns segons)..."
TIMEOUT=60
COUNT=0
until docker exec demo_db pg_isready -U "$DB_USER" >/dev/null 2>&1; do
    sleep 2
    ((COUNT+=2))
    if [ $COUNT -ge $TIMEOUT ]; then
        echo "❌ Error: la base de dades no ha respost en $TIMEOUT segons."
        echo "   Revisa els logs amb: docker logs demo_db"
        exit 1
    fi
done
echo "✅ PostgreSQL està llest!"


# --- 10. Comprovació del fitxer SQL ---

echo "🔍 Comprovant si s'ha carregat el fitxer SQL de dades de la demo..."
DB_LOGS=$(docker logs demo_db 2>&1 | grep -E "docker-entrypoint-initdb.d/.*\.sql" | tail -n 1)

if [[ "$DB_LOGS" == *".sql"* ]]; then
        echo "✅ Base de dades inicialitzada correctament!"
        echo "   Fragment del log:"
        echo "   $DB_LOGS"
    else
        echo "⚠️  No s'ha trobat cap evidència que s'hagi executat dades_demo.sql"
        echo "   -> Revisa amb: docker logs demo_db | less"
        echo "   -> o torna a reiniciar amb: make down && make serve"
fi

# --- 11. Missatge final ---

echo -e "\n Instal·lació completada!\n"

echo
echo "--------------------------------------------"
echo "📦  Estat final de la instal·lació"
echo "--------------------------------------------"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo "--------------------------------------------"
echo
echo 
echo "ℹ️ Instruccions disponibles amb la comanda **make** per la Demo:"
echo "   1. Si no està en marxa, executi: make serve"
echo "   2. Per veure els logs:           make logs"
echo "   3. Per detenir la Demo:          make stop"
echo
echo "🌐 Si ha definit IP o dominis a DEMO_ALLOWED_HOSTS, provi ara d'accedir-hi al navegador!"
echo "   (p. ex. http://demo.elteudomini.cat:8000 o http://IP:8000)"
echo

