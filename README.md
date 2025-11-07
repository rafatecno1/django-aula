# django-aula: Gestió Escolar - Software de Gestión de Centros Educatius

Gestió de presència, incidències i més per a Instituts, Escoles i Acadèmies.

![Imgur](http://i.imgur.com/YlCRTap.png)

**[Llicència i Crèdits](LICENSE)** | **EL PROGRAMA NO TÉ CAP GARANTIA, UTILITZEU-LO SOTA LA VOSTRA RESPONSABILITAT.**

# 📋 Índex de Continguts

- [1. Característiques Principals i Valor Afegit](#1-caracteristiques-principals-i-valor-afegit)
- [2. Instal·lació i Desplegament de Django-Aula](#2-instal·lacio-i-desplegament-de-django-aula)
  - [2.1 Instal·lació Automatitzada de Django-Aula amb Scripts (Mètode Prioritari)](#21-instal·lacio-automatitzada-de-django-aula-amb-scripts-metode-prioritari)
  - [2.2 Desplegament Manual (Mètode Legat)](#22-desplegament-manual-metode-legat)
- [3. Entorn de demostració o Demo de Django-Aula (Quick Demo)](#3-entorn-de-demostracio-o-demo-de-django-aula-quick-demo)
  - [3.1 Instal·lació manual de la Demo de Django-Aula (Quick_Demo)](#31-instal·lacio-manual-de-la-demo-de-django-aula-quick_demo)
  - [3.2 Guia d'Instal·lació de Docker i Docker Compose](#32-guia-dinstal·lacio-de-docker-i-docker-compose)
    - [3.2.1 Instal·lació ràpida de la Demo amb Docker (QUICK_DEMO)](#321-instal·lacio-rapida-de-la-demo-amb-docker-quick_demo)
    - [3.2.2 Guia per la construcció de la imatge de la Demo de Django-Aula amb Docker](#322-guia-per-la-construccio-de-la-imatge-de-la-demo-de-django-aula-amb-docker)
- [4. Manual per la càrrega de dades, l'administració i el manteniment](#4-manual-per-la-carrega-de-dades-ladministracio-i-el-manteniment)
- [5. Contribució i Suport](#5-contribucio-i-suport)
  - [Vols col·laborar-hi com a #DEV?](#vols-col·laborar-hi-com-a-dev)
  - [Necessites ajuda o vols reportar un error?](#necessites-ajuda-o-vols-reportar-un-error)


---

## 1. Característiques Principals i Valor Afegit

Django-Aula és un sistema integral dissenyat per alleugerir la càrrega de treball del personal i millorar la gestió acadèmica i de convivència.

➡️ **[Llegir totes les CARACTERÍSTIQUES (perfil de gestió)](docs/USER_MANUAL/caracteristicas.md)**

El programa cobreix tots els aspectes clau de la gestió diària del centre: **Presència**, **Incidències**, **Actuacions**, **Sortides** i **Portal de Famílies**.

➡️ **[Llegir totes les FUNCIONALITATS (detall tècnic i pantalles)](docs/USER_MANUAL/funcionalidades.md)**

El sistema s'instal·la en un entorn Linux, preferiblement Debian 13 o Ubuntu Server 24.04 LTS o superior.

---



## 2. Instal·lació i Desplegament de Django-Aula

### 🚀 2.1 Instal·lació Automatitzada de Django-Aula amb Scripts (Mètode Prioritari)

S'aha automatitzat el procés complet de desplegament en un servidor, ja sigui una màquina virtual com un servidor VPS, amb el sistema operatiu (Debian/Ubuntu) per garantir una instal·lació neta i funcional en pocs minuts.

➡️ **[GUIA COMPLETA D'INSTAL·LACIÓ AUTOMATITZADA](docs/INSTALL_AUTOMATIC_DJAU_SCRIPTS.md)**

### ⚙️ 2.2 Desplegament Manual (Mètode Legat)

Per a instal·lacions sense scripts d'automatització, completalment manuals i guiades pas a pas, o s'explica tot el que s'ha de fer per instal·lar Django-Aula o, fins i tot, per adaptar la instal·lació a distribucions de Linux diferents de les basades en Debian (com Ubuntu), podeu consultar el procediment manual que ha estat la base per la creació del procediment d'instal·lació automatitzat.

[Instruccions de Desplegament Manual](docs/MANUAL_LEGACY/instalacion.md)

---



## 3. Entorn de demostració o Demo de Django-Aula (Quick Demo)

L'entorn de demostració, conegut com Demo Django-Aula o Quick Demo, és una versió funcional del sistema i que es desplega en molts minuts, en funció de l'opció que s'escolli. Diposa de dades ficiticies (usuaris, professors i horaris) que ens faciliten veure l'aspecte visual i funcional de Django-Aula.

A nivell informatiu, les dades fictícies que l'entorn de demostració portarà precarregades són:

| Rol | Usuaris |
| :--- | :--- |
| **Professors** | `M0 ,M5 ,T0 ,T1 ,T3` |
| **Tutors** | `M2 ,M3 ,M4 ,M7 ,T2 ,T4 ,T5` |
| **Direcció** | `M1 ,M6, T1` |
| **Alumnat rang** | `almn1 - almn229` |



Actualment hi ha dues maneres d'instal·lar la Demo de Django-Aula, cadascuna d'elles amb els seus punts forts i febles:

* **Instal·lació manual**
* **Instal·lació automatitzada amb docker** (recomanada)




### 💻 3.1 Instal·lació manual de la Demo de Django-Aula (Quick_Demo)

La instal·lació manual de la Demo de Django-Aula és més lenta que l'automatitzada amb docker però és molt més flexible.

Aquest tipus d'instal·lació possibilita crear una Demo de l'aplicatiu Django-Aula per a múltiples escenaris, com ara:

* Màquina virtual d'accés restringit, amb o sense escriptori gràfic.
* Màquina virtual amb accés des de qulsevol ordinaor d'una xarxa interna.
* Instal·lació en un servidor públic amb accés lliure des d'Internet.

➡️ **[Instruccions per a crear la Quick_Demo](docs/INSTALL_DEMO_MANUAL)**.




### 🐳 3.2 Guia d'Instal·lació de Docker i Docker Compose

La instal·lació de la Demo amb Docker és el procediment més ràpid amb diferència però, tot i ser funcional, l'accés dels usuaris observadors a la Demo es troba limitat, _de moment_, a tenir accés a la màquina física o virtual on s'ha instal·lat.

Per instal·lar la Demo, **el primer pas imprescindible és instal·lar l'entorn de Docker i Docker Compose**.

➡  **[Instruccions per instal·lar l'entorn de Docker i Docker Compose](docs/INSTALL_ENTORN_DOCKER.md)**.


#### 🐳 3.2.1 Instal·lació ràpida de la Demo amb Docker (QUICK_DEMO)

Aquest mètode només precisa diposar de tres arxius per fer el desplegament un dels quals, de fet, és opcional, però molt útil. Els arxus son:

* **docker-compose.yml**: arxiu que descarrega i configura la Demo
* **.env**: variables internes per la base de dades Postgres (es manté per compatibilitat)
* **Makefile** (opcional): Facilita el desplegament amb l'ús d'ordres senzilles.

Es recomana crear un directori, dins el directori de l'usuari instal·lador, on s'instal·larà la Demo.

**El procés automatitzat**, que descarregarà els tres arxius necessaris, **comença amb la descàrrega i execució automàtica del script anomenat `install_quick_demo_docker.sh`** amb la següent ordre:

```bash
wget -q -O install_quick_demo_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh && chmod +x install_quick_demo_docker.sh && bash ./install_quick_demo_docker.sh
```

Un cop feta la descarrega del script iniciador amb l'ordre anterior, s'executarà de forma autònoma i s'encarregarà de descarregar els arxius correctes de la carpeta `docker` del repositori per instal·lar els tres arxius que s'encarregaran de crear la Demo de Django-Aula.

Per tenir més informació del procés es recomana consultar:

➡  **[Instal·lació ràpida de la Demo amb Docker](docs/INSTALL_DEMO_DOCKER.md)**.



#### 🐳 3.2.2 Guía per la construcció de la imatge de la Demo de Django-Aula amb Docker

**Aquesta guia** reuneix el coneixement adquirit i **serveix per crear la imatge que, actualment, fa el desplegamet de la Demo amb docker** de forma ràpida i no és el mètode recomanat per instal·lar la Demo basada en Docker.

**Serveix per crear exclusivament l'entorn de desenvolupament de la imatge Demo amb Docker i per a proves** 


➡  **[Guía per la construcció de la imatge de la Demo de Django-Aula amb Docker](docs/CONSTRUCCIO_IMATGE_DEMO_DOCKER.md)**.

---

## 4. Manual per la càrrega de dades, l'administració i el manteniment

Tota l'extensa documentació sobre la posada en marxa, la càrrega inicial de dades (SAGA, Horaris), l'actualització i la gestió de final de curs es troba aquí:

➡️ **[MANUAL DE L'ADMINISTRADOR (Càrrega de dades i Manteniment)](docs/USER_MANUAL/README.md)**


## 5. Contribució i Suport

### Vols col·laborar-hi com a #DEV?

* Aquestes són les [issues prioritàries](https://github.com/ctrl-alt-d/django-aula/issues?q=is%3Aissue%20state%3Aopen%20label%3APrioritari).
* [FAQs (Preguntes Freqüents)](https://github.com/ctrl-alt-d/django-aula/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3AFAQ+)

### Necessites ajuda o vols reportar un error?

* Utilitza el [Formulari d'ajuda/Issues](https://github.com/ctrl-alt-d/django-aula/issues/new/choose).
