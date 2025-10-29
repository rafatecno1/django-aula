# django-aula: Gestió Escolar - Software de Gestión de Centros Educatius

Gestió de presència, incidències i més per a Instituts, Escoles i Acadèmies.

![Imgur](http://i.imgur.com/YlCRTap.png)

**[Llicència i Crèdits](LICENSE)** | **EL PROGRAMA NO TÉ CAP GARANTIA, UTILITZEU-LO SOTA LA VOSTRA RESPONSABILITAT.**

### 📋 Índex de Continguts

* [1. Característiques Principals i Valor Afegit](#1-característiques-principals-i-valor-afegit)
* [2. Instal·lació i Desplegament](#2-instal·lació-i-desplegament)
    * [2.1 Instal·lació Ràpida i Automatitzada (Mètode Recomanat)](#-21-instal·lació-ràpida-i-automatitzada-mètode-recomanat)
    * [2.2 Desplegament Manual (Mètode Legat)](#-22-desplegament-manual-mètode-legat)
* [3. Altres mètodes d'instal·lació o desplegament](#3-altres-mètodes-dinstal·lació-o-desplegament)
    * [3.1 Demo Ràpida (Entorn de Prova Pública)](#-31-demo-ràpida-entorn-de-prova-pública)
    * [3.2 Desplegament amb Docker (Entorn de Desenvolupament)](#-32-desplegament-amb-docker-entorn-de-desenvolupament)
* [4. Manual per la càrrega de dades, l'administració i el manteniment](#4-manual-per-la-càrrega-de-dades-ladministració-i-el-manteniment)
* [5. Contribució i Suport](#5-contribució-i-suport)

---

## 1. Característiques Principals i Valor Afegit

Django-Aula és un sistema integral dissenyat per alleugerir la càrrega de treball del personal i millorar la gestió acadèmica i de convivència.

➡️ **[Llegir totes les CARACTERÍSTIQUES (perfil de gestió)](docs/USER_MANUAL/caracteristicas.md)**

El programa cobreix tots els aspectes clau de la gestió diària del centre: **Presència**, **Incidències**, **Actuacions**, **Sortides** i **Portal de Famílies**.

➡️ **[Llegir totes les FUNCIONALITATS (detall tècnic i pantalles)](docs/USER_MANUAL/funcionalidades.md)**

---

## 2. Instal·lació i Desplegament

### 🚀 2.1 Instal·lació Ràpida i Automatitzada (Mètode Recomanat)

Hem automatitzat el procés complet de desplegament en servidors VPS (Ubuntu/Debian) per garantir una instal·lació neta i funcional en pocs minuts.

➡️ **[GUIA COMPLETA D'INSTAL·LACIÓ AUTOMATITZADA](docs/README.md)**

### ⚙️ 2.2 Desplegament Manual (Mètode Legat)

Per a instal·lacions personalitzades, guies pas a pas, o per adaptar la instal·lació a distribucions de Linux diferents de les basades en Debian (com Ubuntu), podeu consultar el procediment manual que ha estat la base del procediment d'instal·lació automatitzat.

[Instruccions de Desplegament Manual](docs/MANUAL_LEGACY/instalacion.md)

## 3. Altres mètodes d'instal·lació o desplegament

### 💻 3.1 Demo Ràpida (Entorn de Prova Pública)

Existeix la possibilitat de crear una Demo de l'aplicatiu Django-Aula de forma ràpida, tant en una màquina virtual que tingui escriptori gràfic, com en un servidor públic.

Aquesta Demo crea docents, alumnat i u horari fictici, de tal forma que permet fer-se una idea del funcionament de Django-Aula.

➡️ **[Instruccions per a crear-ne una Demo Ràpida](docs/QUICK_DEMO.md)**.

### 🐳 3.2 Desplegament amb Docker (Entorn de Desenvolupament)

Si bé **Docker** no és el mètode de desplegament recomanat per a producció, és una eina excel·lent per a entorns de desenvolupament o proves ràpides.

➡  **[Instruccions per fer-ne el desplegament amb Docker](docs/DOCKER.md)**.


## 4. Manual per la càrrega de dades, l'administració i el manteniment

Tota l'extensa documentació sobre la posada en marxa, la càrrega inicial de dades (SAGA, Horaris), l'actualització i la gestió de final de curs es troba aquí:

➡️ **[MANUAL DE L'ADMINISTRADOR (Càrrega de dades i Manteniment)](docs/USER_MANUAL/README.md)**


## 5. Contribució i Suport

### Vols col·laborar-hi com a #DEV?

* Aquestes són les [issues prioritàries](https://github.com/ctrl-alt-d/django-aula/issues?q=is%3Aissue%20state%3Aopen%20label%3APrioritari).
* [FAQs (Preguntes Freqüents)](https://github.com/ctrl-alt-d/django-aula/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3AFAQ+)

### Necessites ajuda o vols reportar un error?

* Utilitza el [Formulari d'ajuda/Issues](https://github.com/ctrl-alt-d/django-aula/issues/new/choose).
