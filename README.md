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
## Introducció

### Característiques Principals i Valor Afegit

Django-Aula és un sistema integral dissenyat per alleugerir la càrrega de treball del personal docent d'un centre educatiu, millorant la gestió acadèmica i de convivència, al mateix temps que possibilita mantenir informades les famílies.

El programa cobreix tots els aspectes clau de la gestió diària del centre educatiu: **Presència**, **Incidències**, **Actuacions**, **Sortides** i **Portal de Famílies**. Per a més detalls:

➡️ **[Sobre les CARACTERÍSTIQUES generals](docs/USER_MANUAL/caracteristicas.md)**

➡️ **[Sobre les FUNCIONALITATS concretes, amb captures de pantalla](docs/USER_MANUAL/funcionalidades.md)**



<a name="requisits"></a>
## Requisits del sistema operatiu per instal·lar Django-Aula

Django-Aula s'instal·la en un servidor amb sistema operatiu Linux i està adaptat per Debian 13, Ubuntu Server 24.04 LTS o superior, o derivats de la mateixa base.

Per qualsevol tipus d'instal·lació, ja sigui per un ús real o per l'entorn de demostració, ès altament recomanable haver creat un usuari amb permisos de *SUDO*. [El procés està documentat.](docs/USUARI_SUDO.md)

---

<a name="quickdemo"></a>
## 🐳 Desplegament d'una Demostració de Django-Aula (Quick Demo) amb Docker

L'entorn de demostració, conegut com Demo, és una versió funcional del sistema i que es pot posar en funcionament en molts pocs minuts. Disposa de dades ficiticies (usuaris, professors, alumnat i un horari mínim) que faciliten observar l'aspecte visual i interaccionar, des de diferents rols, amb les funcionalitats de l'aplicatiu real Django-Aula.

El desplegament de la Demo s'ha automatitzat amb l'execució de dues comandes i consta de dues passes consecutives:


### 1a - Instal·lació automàtica de Docker i Docker Compose

```bash
wget -q -O install_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_docker.sh && chmod +x install_docker.sh && sudo ./install_docker.sh
```

### 2a - Instal·lació automàtica de la Demo de Django-Aula

Es recomana crear un subdirectori dins el directori de l'usuari instal·lador per instal·lar la Demo, en aquest exemple `demo-djau-docker`:

```bash
mkdir demo-djau-docker && cd demo-djau-docker && \
wget -q -O install_quick_demo_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh && \
chmod +x install_quick_demo_docker.sh && \
bash ./install_quick_demo_docker.sh
```

No obstant: Es recomana llegir la informació, molt més detallada del procés, segons el tipus de màquina (no virtualitzada, virtualitzada o servidor d'accés públic) on s'instal·larà la Demo. També hi haurà qui estarà interessat en dur a terme la instal·lació manual, tant de l'entorn de docker com de la Demo. Per tots aquests casos es recomana consultar els següents documents:


➡️ **[Instal·lació de l'entorn de Docker i Docker Compose](docs/INSTALL_ENTORN_DOCKER.md)**.

➡️ **[Instal·lació ràpida de la Demo amb Docker](docs/INSTALL_DEMO_DOCKER.md)**.

➡️ **[Instal·lació manual de la Demo (sense Dcoker)](docs/INSTALL_DEMO_MANUAL)**.


<a name="produccio"></a>
## 🚀 Instal·lació de Django-Aula per ús real a un Centre Educatiu i càrrega de dades (Entorn de Producció)

### 1a part. Procés d'instal·lació.

Si vol instal·lar Django-Aula per fer-lo servir a un centre educatiu cal un servidor de producció, ja sigui un servidor públic (VPS) o un servidor local (xarxa local), que pot ser una màquina real o una màquina virtual (VM). Per tots aquests casos hi ha dues opcions:

* **Mètode Prioritari i recomanat: Desplegament completament automatitzat** amb scripts.  
    ➡️ **[GUIA COMPLETA D'INSTAL·LACIÓ AUTOMATITZADA](docs/INSTALL_AUTOMATIC_DJAU_SCRIPTS.md)**

* Mètode Clàssic: Desplegament manual pas a pas.  
    ➡️ **[Instruccions de Desplegament Manual](docs/MANUAL_LEGACY/instalacion.md)**

### 2 part. Procés de càrrega de dades

Després de la instal·lació el sistema estarà preparat per rebre les dades del centre educatiu (alumnat, docents, aules, horaris, etc).

➡️ **[Instruccions per la càrrega de dades del centre educatiu](docs/USER_MANUAL/README.md)**.

---

<a name="doc_manteniment"></a>
## 📚 Equip Desenvolupador i Suport Tècnic


* **Vols col·laborar-hi com a #DEV?**  
Aquestes són les [Issues prioritàries](https://github.com/ctrl-alt-d/django-aula/issues?q=is%3Aissue%20state%3Aopen%20label%3APrioritari)
* **Pregüntes d'ús freqüent**.  
[FAQs](https://github.com/ctrl-alt-d/django-aula/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3AFAQ+)
* **Has trobat errors? Necessites ajuda?** Utilitza el Formulari per demanar ajuda o comunicar errors (*Issues*)  
[Issues/Formularis d'ajuda](https://github.com/ctrl-alt-d/django-aula/issues/new/choose)

---

