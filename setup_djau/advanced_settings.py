# --- PARAMETRITZACIONS AVANÇADES DE DJAU (Per ser descomentades i personalitzades) ---
# Aquestes variables permeten sobreescriure les configuracions per defecte definides a settings.py.
# Els valors aquí reflectits són els valors per defecte de l'aplicació o els més recomanats.

# Importa os per a rutes (necessari per a rutes de fitxers)
import os
location = lambda x: os.path.join(PROJECT_DIR, x)

# ------------------------------------------------------------------------------------
# 1. SEGURETAT I ACCÉS
# ------------------------------------------------------------------------------------

# Quantitat màxima de logins errònis abans de bloquejar l'usuari (sobreescriu el 3 de common.py)
LIMITLOGIN = 5

# Temps màxim d'inactivitat (en segons) abans de tancar la sessió.
CUSTOM_TIMEOUT = 900 # 15 minuts

# Timeout per grup d'usuaris (sobreescriu CUSTOM_TIMEOUT si l'usuari és del grup)
CUSTOM_TIMEOUT_GROUP = {
    # "consergeria": 4 * 60 * 60,  # 4h
    # "professors": 15 * 60,  # 15'
}


# ------------------------------------------------------------------------------------
# 2. GESTIÓ D'INCIDÈNCIES I FALTES
# ------------------------------------------------------------------------------------

# Si True, cada retard registrat genera automàticament una incidència.
CUSTOM_RETARD_PROVOCA_INCIDENCIA = False

# Defineix el tipus d'incidència que genera un retard si l'opció anterior és True.
# CUSTOM_RETARD_TIPUS_INCIDENCIA = {"tipus": "Incidència", "es_informativa": False}

# Frase de la incidència generada automàticament per un retard.
# CUSTOM_RETARD_FRASE = "Ha arribat tard a classe."

# Nombre de dies que es permet crear o modificar una incidència antiga.
CUSTOM_PERIODE_CREAR_O_MODIFICAR_INCIDENCIA = 90

# Si True, les incidències d'un cert tipus poden provocar una expulsió.
CUSTOM_INCIDENCIES_PROVOQUEN_EXPULSIO = True

# Nombre de dies que es permet modificar l'assistència (per correcció de professors).
CUSTOM_PERIODE_MODIFICACIO_ASSISTENCIA = 90

# Dies que una incidència ha de prescriure.
CUSTOM_DIES_PRESCRIU_INCIDENCIA = 30

# Dies que una expulsió ha de prescriure.
CUSTOM_DIES_PRESCRIU_EXPULSIO = 90

# Si True, només el tutor pot justificar faltes dels seus alumnes.
CUSTOM_NOMES_TUTOR_POT_JUSTIFICAR = True

# Faltes d'absència no justificades (en dies) per tal de generar carta base.
CUSTOM_FALTES_ABSENCIA_PER_CARTA = 15

# Faltes d'absència no justificades (en dies) per generar carta segons el seu tipus.
# CUSTOM_FALTES_ABSENCIA_PER_TIPUS_CARTA = {"tipus1": 20}

# Permet configurar el nombre de faltes per nivell i tipus de carta.
# CUSTOM_FALTES_ABSENCIA_PER_NIVELL_NUM_CARTA = {
#     u"ESO": [10, 15, 20],
# }


# ------------------------------------------------------------------------------------
# 3. MÒDULS I FUNCIONALITAT
# ------------------------------------------------------------------------------------

# Activa el mòdul de gestió de sortides i activitats.
CUSTOM_MODUL_SORTIDES_ACTIU = True

# Si True, s'oculten les sortides a les famílies (útil si pagueu per una altra via).
CUSTOM_SORTIDES_OCULTES_A_FAMILIES = False

# Activa el mòdul de matrícula.
CUSTOM_MODUL_MATRICULA_ACTIU = False

# Si True, permet que la família pugui modificar els seus paràmetres a l'aplicació.
CUSTOM_FAMILIA_POT_MODIFICAR_PARAMETRES = False

# Si True, permet a la família enviar comunicats.
CUSTOM_FAMILIA_POT_COMUNICATS = False

# Si True, activa el mòdul de presència setmanal (graella amb faltes).
CUSTOM_MODUL_PRESENCIA_SETMANAL_ACTIU = False

# Si False, desactiva la comprovació de "és presència" en el control (només per a configuració avançada)
CUSTOM_NO_CONTROL_ES_PRESENCIA = False

# ------------------------------------------------------------------------------------
# 4. PAGAMENTS I COMERÇ ELECTRÒNIC
# ------------------------------------------------------------------------------------

# Si True, permet realitzar pagaments online (requereix configuració Redsys/entitat)
CUSTOM_SORTIDES_PAGAMENT_ONLINE = False
# Entorn Redsys: True per a real, False per a proves.
CUSTOM_REDSYS_ENTORN_REAL = False 
# Preu mínim per una sortida per activar el pagament online.
CUSTOM_PREU_MINIM_SORTIDES_PAGAMENT_ONLINE = 1 

# ------------------------------------------------------------------------------------
# 5. DIVERSOS
# ------------------------------------------------------------------------------------

# Permet definir l'estructura de nivells del centre.
# CUSTOM_NIVELLS = {
#     "ESO": ["ESO"],
#     "BTX": ["BTX"],
#     # ...
# }

# Permet als tutors tenir accés als informes de seguiment de faltes i incidències.
CUSTOM_TUTORS_INFORME = False

# Activa el filtre per mostrar la ruleta d'alumnes a la pantalla de passar llista.
CUSTOM_RULETA_ACTIVADA = True
