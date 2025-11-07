# 🐳 Contingut del Directori Docker

Aquest directori conté tots els fitxers creats per gestionar el desplegament de la Demo de Django-Aula i per la creació d'imatges de l'aplicació Django-Aula mitjançant contenidors Docker.

El directori es divideix en fitxers de configuració principals, fitxers de construcció i una subcarpeta amb dades d'inicialització de la base de dades.

---

## ⚙️ 1. Requisit previ. Instal·lació de Docker CE i docker-compose en el sistema operatiu

Segons es descriu a les instruccions principals del repositori, hi ha dues maneres d'instal·lar Docker en el sistema operatiu, la manual i l'automatitzada.

| Nom de l'Arxiu | Descripció | Ús Principal |
| :--- | :--- | :--- |
| `install_docker.sh` | **Script d'instal·lació automatitzada de Docker.** Descarrega i configura tot allò el que cal per instal·lar l'entorn Docker i docker-compose en el sistema. | Instal·lar Docker en el sistema operatiu. |


## 📂 2. Arxius de Configuració de Desplegament Ràpid

Aquests arxius s'utilitzen per a l'**Instal·lació de la Demo** amb Docker de forma automatitzada, tal com s'explica al document principal. Són la base per a un desplegament senzill i automatitzat típic amb Docker.

| Nom de l'Arxiu | Descripció | Ús Principal |
| :--- | :--- | :--- |
| `install_quick_demo_docker.sh` | **Script d'instal·lació automatitzada.** Descarrega, col·loca els arxius de configuració a l'arrel del projecte i els reanomena. | Desplegament actual de la Demo. |
| `docker-compose.demo.automatica.yml` | Fitxer de configuració de serveis (Web + DB) utilitzat per la Demo. | Serà l'arxiu `docker-compose.yml` que desplegarà la Demo. |
| `Makefile.demo.automatica` | Defineix les ordres de gestió simplificades (`serve`, `stop`, `logs`, etc.) per a la Demo. | Serà l'arxiu `Makefile` que facilitarà el desplegament de la Demo. |
| `env.demo.automatica` | Arxiu de variables d'entorn per la base de dades de PostgreSQL que farà servir la Demo. | Serà l'arxiu `.env` que llegirà l'arxiu `docker-compose.yml`. |

---

## ⚙️ 3. Fitxers de Construcció i Entorns de Desenvolupament

| Nom de l'Arxiu | Descripció | Finalitat |
| :--- | :--- | :--- |
| `Dockerfile.demo.manual` | És el fitxer de partida a partir del qual es va construir el *Dockerfile.demo.automatica*. | Es pot utilitzar per crear noves imatges de la Demo. |
| `Dockerfile.demo.automatica` | Defineix com es va construir la imatge per a la Demo actualment desplegable de forma automatitzada . | Utilitzat per crear la imatge pujada al repositori d'imatges *Docker Hub*. |
| `docker-compose.demo.manual.yml` | És el fitxer de partida a partir del qual es va construir el *docker-compose.demo.automatica.yml*. | Ús per a desenvolupadors locals que volen accedir a *shells*, *migrations*, etc. |
| `docker-compose.dev.yml` | Configuració completa dels serveis per a **l'entorn de Desenvolupament** (DEV). (ara en desenvolupament) | Facilitar crear un entorn de desenvolupament de l'aplicació bassat en Docker i pensat per a desenvolupadors locals que volen accedir a *shells*, *migrations*, etc. |
| `Makefile.demo.manual` | És el fitxer de partida a partir del qual es va construir el *Makefile.demo.automatica*. Interacciona amb el fitxer *docker-compose.demo.yml*.| És l'arxiu que facilitarà la creació i desplegament de les noves Demos que es vulguin crear. |
| `Makefile.demo.complet` | Conté conjuntament les instruccions per treballar tant amb la versió manual com la versió *DEV*. | Serveix com a referència i com a base per a entorns de Producció/Desenvolupament. |
| `env.example` | Arxiu de variables d'entorn *sense personalitzar* per la base de dades de PostgreSQL que farà servir la Demo. | Base per crear el fitxer `.env` per crear una imatge de Django-Aula amb Docker. |
| `.dockerignore` | Especifica els fitxers que s'han d'excloure del context de construcció de les imatges. | Optimització i seguretat de la imatge Docker final. |

---

## 🗃️ 4. Dades d'Inicialització de la BBDD

| Nom del Directori | Contingut | Funció |
| :--- | :--- | :--- |
| `demo-initdb/` | Conté el fitxer SQL (`.sql`) amb les dades de demostració precàrregades. | El contenidor de PostgreSQL llegeix aquests fitxers en iniciar-se i omple la base de dades de forma automàtica. |