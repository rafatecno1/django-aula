# ⚙️ Configuració Avançada de DjAu (settings_local.py)

Aquest document detalla les variables de configuració avançada del Django-Aula (DjAu) que defineixen el comportament de l'aplicació en qüestions de política interna del centre (seguretat, disciplina, gestió de dades i mòduls).

Aquestes opcions es troben afegides, per defecte **comentades** (amb el símbol `#`), al final de l'arxiu de configuració local:

> **Ruta del Fitxer:** `aula/settings_local.py`

## 1. Instruccions d'Ús

1. **Editeu** l'arxiu `aula/settings_local.py` amb permís de *root* (p. ex., `sudo nano aula/settings_local.py`).
2. Localitzeu el bloc `# --- PARAMETRITZACIONS AVANÇADES ---` al final del fitxer.
3. Per activar o modificar una funcionalitat, **descomenteu** la línia (`# VARIABLE = Valor` a `VARIABLE = Valor`) i ajusteu el valor segons les decisions de l'Equip Directiu.
4. **Apliqueu els canvis:** Cal **reiniciar el servidor Apache/WSGI** perquè la nova configuració tingui efecte (`sudo systemctl restart apache2`).

---

## 2. Catàleg de Variables Avançades

Les variables estan agrupades per la seva àrea d'impacte.

### 2.1. Seguretat i Accés

| Variable | Descripció | Valor Per Defecte | Impacte |
| :--- | :--- | :--- | :--- |
| `LIMITLOGIN` | **Límit d'intents de connexió fallits.** Nombre d'intents erronis de contrasenya abans que el compte d'usuari quedi automàticament bloquejat (caldrà desbloquejar-lo manualment a l'administració). Sobreescriu el valor base de `3`. | `5` | Controla la política de seguretat contra atacs de força bruta i bloquejos accidentals. |
| `CUSTOM_TIMEOUT` | **Temps d'inactivitat.** Temps (en segons) sense activitat que es permet abans de tancar la sessió de l'usuari. | `900` (15 minuts) | Seguretat i usabilitat. |

### 2.2. Gestió de Disciplina i Absències

| Variable | Descripció | Valor Per Defecte | Impacte |
| :--- | :--- | :--- | :--- |
| `CUSTOM_RETARD_PROVOCA_INCIDENCIA` | Si **True**, cada retard registrat a la Llista generarà automàticament una nova incidència (amb la frase i tipus definits en altres variables). | `False` | Automatització del procés d'incidències per retards. |
| `CUSTOM_NOMES_TUTOR_POT_JUSTIFICAR` | Si **True**, només els usuaris amb rol de Tutor poden justificar les absències dels seus alumnes. | `True` | Restricció de permisos. |
| `CUSTOM_FALTES_ABSENCIA_PER_CARTA` | **Límit d'absències no justificades.** Nombre de dies d'absència no justificada per a un alumne que activa la lògica de notificació per carta. | `15` | Política d'absentisme. |
| `CUSTOM_PERIODE_CREAR_O_MODIFICAR_INCIDENCIA` | Nombre de dies que es pot crear o modificar una incidència antiga. | `90` | Restricció temporal per a l'entrada de dades. |

### 2.3. Mòduls Actius i Dades

| Variable | Descripció | Valor Per Defecte | Impacte |
| :--- | :--- | :--- | :--- |
| `CUSTOM_MODUL_SORTIDES_ACTIU` | Si **True**, activa el mòdul complet per a la gestió de sortides i activitats. | `True` | Activa/Desactiva una funcionalitat major. |
| `CUSTOM_SORTIDES_OCULTES_A_FAMILIES` | Si **True**, les famílies no podran veure les sortides al Portal (útil si es gestionen per una plataforma externa). | `False` | Visibilitat de les activitats. |
| `CUSTOM_MODUL_MATRICULA_ACTIU` | Si **True**, activa el mòdul per a la gestió de la matrícula. | `False` | Activa/Desactiva la funcionalitat de matrícula. |

*(Aquest catàleg és un extracte. El teu `advanced_settings.py` complet conté més variables complexes que també hauran d'estar documentades a fons en aquest estil.)*

