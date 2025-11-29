# ⚙️ Configuració Avançada de DjAu

Aquest document detalla les opcions de configuració avançada del Django-Aula (DjAu) que defineixen el comportament de l'aplicació en qüestions de política interna (seguretat, disciplina, gestió de dades i mòduls).

---

## 1. Configuració per Fitxer (settings_local.py)

Aquestes variables es gestionen mitjançant l'arxiu de configuració local. En el procés d'instal·lació, es poden afegir automàticament al final del fitxer, **comentades** (amb el símbol `#`), per defecte.

> **Ruta del Fitxer:** `aula/settings_local.py`

### Instruccions d'Ús

1. **Editeu** l'arxiu `aula/settings_local.py` amb permís de *root*.
2. Localitzeu el bloc `# --- PARAMETRITZACIONS AVANÇADES DE DJAU ---` al final del fitxer.
3. Per activar o modificar una funcionalitat, **descomenteu** la línia (`# VARIABLE = Valor` a `VARIABLE = Valor`) i ajusteu el valor segons les necessitats.
4. **Apliqueu els canvis:** Cal **reiniciar el servidor Apache/WSGI** perquè la nova configuració tingui efecte (`sudo systemctl restart apache2`).

### Catàleg de Variables Avançades (settings_local.py)

#### 1.1. Seguretat i Accés

| Variable | Descripció | Valor Per Defecte |
| :--- | :--- | :--- |
| `LIMITLOGIN` | Límit d'intents de connexió fallits abans que el compte quedi bloquejat. | `5` |
| `CUSTOM_TIMEOUT` | Temps d'inactivitat (en segons) abans de tancar la sessió. | `900` (15 min) |
| `CUSTOM_TIMEOUT_GROUP` | Permet definir un temps d'espera diferent segons el grup d'usuaris (p. ex., consergeria o professors). | `Comentat` |

#### 1.2. Gestió d'Incidències i Faltes

| Variable | Descripció | Valor Per Defecte |
| :--- | :--- | :--- |
| `CUSTOM_TIPUS_INCIDENCIES` | Si **True**, activa la classificació d'incidències per tipus. | `False` |
| `CUSTOM_RETARD_PROVOCA_INCIDENCIA` | Si **True**, cada retard registrat genera automàticament una incidència. | `False` |
| `CUSTOM_PERIODE_CREAR_O_MODIFICAR_INCIDENCIA` | Nombre de dies que es permet crear o modificar una incidència antiga. | `90` |
| `CUSTOM_INCIDENCIES_PROVOQUEN_EXPULSIO` | Si **True**, l'acumulació d'incidències pot obligar a l'expulsió. | `True` |
| `CUSTOM_PERIODE_MODIFICACIO_ASSISTENCIA` | Nombre de dies que es permet als professors modificar l'assistència ja registrada. | `90` |
| `CUSTOM_DIES_PRESCRIU_INCIDENCIA` | Dies que una incidència ha de transcórrer per prescriure. | `30` |
| `CUSTOM_DIES_PRESCRIU_EXPULSIO` | Dies que una expulsió ha de transcórrer per prescriure. | `90` |
| `CUSTOM_NOMES_TUTOR_POT_JUSTIFICAR` | Si **True**, només el tutor pot justificar absències dels seus alumnes. | `True` |
| `CUSTOM_FALTES_ABSENCIA_PER_CARTA` | Faltes d'absència no justificades (en dies) per tal de generar la carta base. | `15` |
| `CUSTOM_FALTES_ABSENCIA_PER_TIPUS_CARTA` | Permet definir el límit de faltes per a cada **tipus** de carta. | `Comentat` |
| `CUSTOM_FALTES_ABSENCIA_PER_NIVELL_NUM_CARTA` | Permet definir el límit de faltes segons el **nivell** i el número de carta. Invalida l'opció anterior si s'activa. | `Comentat` |

#### 1.3. Mòduls i Funcionalitat

| Variable | Descripció | Valor Per Defecte |
| :--- | :--- | :--- |
| `CUSTOM_MODUL_SORTIDES_ACTIU` | Activa el mòdul de gestió de sortides i activitats. | `True` |
| `CUSTOM_SORTIDES_OCULTES_A_FAMILIES` | Si **True**, s'oculten les sortides a les famílies (útil si la gestió es fa amb una plataforma externa). | `False` |
| `CUSTOM_MODUL_MATRICULA_ACTIU` | Activa el mòdul de matrícula. | `False` |
| `CUSTOM_QUOTES_ACTIVES` | Si **True**, activa l'ús de quotes (pagaments) al sistema. | `False` |
| `CUSTOM_FAMILIA_POT_MODIFICAR_PARAMETRES` | Si **True**, les famílies poden modificar els seus paràmetres personals. | `False` |
| `CUSTOM_FAMILIA_POT_COMUNICATS` | Si **True**, permet a la família enviar comunicats. | `False` |
| `CUSTOM_RULETA_ACTIVADA` | Activa el filtre per mostrar la ruleta d'alumnes a la pantalla de passar llista. | `True` |
| `CUSTOM_PORTAL_FAMILIES_TUTORIAL` | Indica la descripció i l'adreça del tutorial per a les famílies. | `Comentat` |

#### 1.4. Rutes de Documents i GPD

Permet definir la ubicació dels fitxers estàtics de text legal (amb marques HTML) que s'utilitzen al peu de pàgina, en pagaments o en la matrícula.

* `CONDICIONS_MATRICULA`
* `INFORGPD`
* `POLITICA_COOKIES`
* `POLITICA_RGPD`
* `DADES_FISCALS_FILE`
* `POLITICA_VENDA_FILE`

---

## 2. 🗄️ Configuració per Base de Dades (Admin)

Aquests paràmetres són valors de configuració sensibles o molt específics per a les integracions que es guarden directament a la Base de Dades (BBDD). **NO s'han d'afegir a `settings_local.py`**.

### Com es Configura?

La seva configuració i gestió es realitza a través de la **interfície d'administració de DjAu** (ruta `/admin/`). Cal buscar el mòdul corresponent.

### Paràmetres Típics de BBDD

| Paràmetre | Mòdul | Descripció |
| :--- | :--- | :--- |
| `ParametreKronowin.passwd` | `Extkronowin` | Contrasenya per defecte dels nous usuaris importats. |
| `ParametreSaga.grups estatics` | `Extsaga` | Llista de grups que no han de ser modificats durant la sincronització SAGA. |
| `Sortides TPVs` | `Sortides` | Configuració dels codis de comerç i *keys* per als Terminals de Punt de Venda (TPV) de pagament online. |
| `ParametreEsfera.grups estatics` | `ExtEsfera` | Llista de grups que no han de ser modificats durant la sincronització Esfera. |

Aquesta documentació ofereix una visió completa i professional de totes les opcions de configuració del DjAu.
