# django-aula: Gestió Escolar - Software de Gestión de Centros Educatius

Gestió de presència, incidències i més per a Instituts, Escoles i Acadèmies.

![Imgur](http://i.imgur.com/YlCRTap.png)

[![Tecnologia](https://img.shields.io/badge/Tecnologia-Django%205.1-092E20.svg?style=for-the-badge&logo=django)](https://www.djangoproject.com/)
[![Database](https://img.shields.io/badge/Database-PostgreSQL-336791.svg?style=for-the-badge&logo=postgresql)](https://www.postgresql.org/)

[![Servei](https://img.shields.io/badge/Served%20with-Docker%20Compose-2496ED.svg?style=for-the-badge&logo=docker)](https://docs.docker.com/compose/)

[![Llicència](https://img.shields.io/badge/Llicència-MIT-2E8B57.svg?style=for-the-badge)](LICENSE)

**[Llicència i Crèdits](LICENSE)** | **EL PROGRAMA NO TÉ CAP GARANTIA, UTILITZEU-LO SOTA LA VOSTRA RESPONSABILITAT.**

---

<a name="introduccio"></a>
## Introducció. Característiques Principals i Valor Afegit

Django-Aula és un sistema integral dissenyat per alleugerir la càrrega de treball del personal docent d'un centre educatiu, millorant la gestió acadèmica i de convivència, al mateix temps que possibilita que manté informades les famílies.

El programa cobreix tots els aspectes clau de la gestió diària del centre educatiu: **Presència**, **Incidències**, **Actuacions**, **Sortides** i **Portal de Famílies**.

➡️ **[Llegir totes les CARACTERÍSTIQUES (perfil de gestió)](docs/USER_MANUAL/caracteristicas.md)**

➡️ **[Llegir totes les FUNCIONALITATS (detall tècnic i pantalles)](docs/USER_MANUAL/funcionalidades.md)**



<a name="requisits"></a>
## Requisits del sistema operatiu

Django-Aula s'instal·la en un servidor amb sistema operatiu Linux, preferiblement Debian 13, Ubuntu Server 24.04 LTS o superior, o derivats de la mateixa base.

És altament recomanable haver creat un usuari amb permisos de SUDO.

---

<a name="quickdemo"></a>
## 🐳 Desplegament d'una Demostració de Django-Aula (Quick Demo) amb Docker

L'entorn de demostració, conegut com Demo, és una versió funcional del sistema i que es pot posar en funcionament en molts pocs minuts.

Diposa de dades ficiticies (usuaris, professors, alumnat i un horari mínim) que ens faciliten veure l'aspecte visual i funcional de l'aplicatiu real Django-Aula.

El desplegament de la Demo està automatitzat amb la descàrrega i execució de dos scritps i consta de dues passes consecutives:


### 1 - Instal·lació automàtica de Docker i Docker Compose

```bash
wget -q -O install_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_docker.sh && chmod +x install_docker.sh && sudo ./install_docker.sh
```

### 2 - Instal·lació automàtica de la Demo de Django-Aula

Es recomana crear un subdirectori dins el directori de l'usuari instal·lador per instal·lar la Demo (ex. demo-djau-docker):

```bash
mkdir demo-djau-docker && cd demo-djau-docker && \
wget -q -O install_quick_demo_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh && \
chmod +x install_quick_demo_docker.sh && \
bash ./install_quick_demo_docker.sh
```

Si vol informació molt més detallada sobre el tipus de màquina (no virtualitzada, virtualitzada o servidor d'accés públic) on es pot instal·lar, com adaptar el procés automatitzat o sobre la instal·lació manual tant de l'entorn de docker com de la Demo, pot consultar els següents documents:


➡️ **[Instal·lació de l'entorn de Docker i Docker Compose](docs/INSTALL_ENTORN_DOCKER.md)**.

➡️ **[Instal·lació ràpida de la Demo amb Docker](docs/INSTALL_DEMO_DOCKER.md)**.

➡️ **[Instal·lació manual de la Demo (sense Dcoker)](docs/INSTALL_DEMO_MANUAL)**.


<a name="produccio"></a>
## 🚀 Instal·lació i càrrega de dades de Django-Aula per ús real a un Centre Educatiu (Entorn de Producció)

### Procés d'instal·lació

Si vol instal·lar Django-Aula per fer-lo servir a un centre educatiu cal un servidor de producció, ja sigui un servidor públic (VPS) o un servidor local (xarxa local), que pot ser una màquina real o una màquina virtual (VM). Per tots aquests casos hi ha dues opcions:

* **Mètode Prioritari: Desplegament completament automatitzat** amb scripts.  
    ➡️ **[GUIA COMPLETA D'INSTAL·LACIÓ AUTOMATITZADA](docs/INSTALL_AUTOMATIC_DJAU_SCRIPTS.md)**

* Mètode Clàssic: Desplegament manual pas a pas.  
    ➡️ **[Instruccions de Desplegament Manual](docs/MANUAL_LEGACY/instalacion.md)**

### Procés de càrrega de dades

Després de la instal·lació el sistema estarà preparat per rebre les dades del centre educatiu (alumnat, docents, aules, horaris, etc).

➡️ **[Instruccions per la càrrega de dades del centre educatiu](docs/USER_MANUAL/README.md)**.

---

<a name="doc_manteniment"></a>
## 📚 Equip Desenvolupador i Suport Tècnic

| Documentació | Enllaç |
| :--- | :--- |
| **Contribució** | ➡️ [Vols col·laborar-hi com a #DEV?](#id-dev) |
| **Ajuda / Errors** | ➡️ [Utilitza el Formulari d'ajuda/Issues](#id-error) |

---

