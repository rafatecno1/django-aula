# django-aula: Gestió Escolar - Software de Gestión de Centros Educatius

Gestió de presència, incidències i més per a Instituts, Escoles i Acadèmies.

![Imgur](http://i.imgur.com/YlCRTap.png)

**[Llicència i Crèdits](LICENSE)** | **EL PROGRAMA NO TÉ CAP GARANTIA, UTILITZEU-LO SOTA LA VOSTRA RESPONSABILITAT.**

# 📋 Índex de Continguts

- [1. Característiques Principals i Valor Afegit](#id1)
- [2. Instal·lació i Desplegament de Django-Aula](#id2)
   * [🚀 2.1 **Instal·lació Automatitzada de Django-Aula amb Scripts** (Mètode Prioritari)](#id21)
   * [⚙️ 2.2 Desplegament Manual (Mètode Legat)](#id22)
- [3. Entorn de demostració o Demo de Django-Aula (Quick Demo)](#id3)
   * [🐳 3.1 Instal·lació de Docker i Docker Compose](#id31)
   * [🐳 3.2 **Instal·lació ràpida de la Demo amb Docker**](#id32)
   * [💻 3.3 Instal·lació manual de la Demo](#id33)
   * [🐳 3.4 Guía per la construcció de la imatge de la Demo de Django-Aula amb Docker](#id34)
- [4. Manual per la càrrega de dades, l'administració i el manteniment](#id4)
- [5. Contribució i Suport](#id5)
   * [Vols col·laborar-hi com a #DEV?](#id-dev)
   * [Necessites ajuda o vols reportar un error?](#id-error)

---

<a name="id1"></a>
## 1. Característiques Principals i Valor Afegit

Django-Aula és un sistema integral dissenyat per alleugerir la càrrega de treball del personal i millorar la gestió acadèmica i de convivència.

➡️ **[Llegir totes les CARACTERÍSTIQUES (perfil de gestió)](docs/USER_MANUAL/caracteristicas.md)**

El programa cobreix tots els aspectes clau de la gestió diària del centre: **Presència**, **Incidències**, **Actuacions**, **Sortides** i **Portal de Famílies**.

➡️ **[Llegir totes les FUNCIONALITATS (detall tècnic i pantalles)](docs/USER_MANUAL/funcionalidades.md)**

El sistema s'instal·la en un entorn Linux, preferiblement Debian 13, Ubuntu Server 24.04 LTS o superior, o derivats de la mateixa base.

---

<a name="id2"></a>
## 2. Instal·lació i Desplegament de Django-Aula

<a name="id21"></a>
### 🚀 2.1 Instal·lació Automatitzada de Django-Aula amb Scripts (Mètode Prioritari)

S'aha automatitzat el procés complet de desplegament en un servidor, ja sigui una màquina virtual com un servidor VPS, amb el sistema operatiu (Debian/Ubuntu) per garantir una instal·lació neta i funcional en pocs minuts.

➡️ **[GUIA COMPLETA D'INSTAL·LACIÓ AUTOMATITZADA](docs/INSTALL_AUTOMATIC_DJAU_SCRIPTS.md)**

<a name="id22"></a>
### ⚙️ 2.2 Desplegament Manual (Mètode Legat)

Per a instal·lacions sense scripts d'automatització, completalment manuals i guiades pas a pas, on s'explica tot el que s'ha de fer per instal·lar Django-Aula, podeu consultar el procediment manual que ha estat la base per la creació del procediment d'instal·lació automatitzat. De fet, aquesta guia manual podria servir, fins i tot, per adaptar la instal·lació de django-aula a distribucions de Linux diferents de les basades en Debian (com Ubuntu)

[Instruccions de Desplegament Manual](docs/MANUAL_LEGACY/instalacion.md)

---


<a name="id3"></a>
## 3. Entorn de demostració o Demo de Django-Aula (Quick Demo)

L'entorn de demostració, conegut com Demo Django-Aula o Quick Demo, és una versió funcional del sistema i que es pot posar en funcionament en molts pocs minuts, sobretot si es tria l'opció de fer-ho amb Docker.

Diposa de dades ficiticies (usuaris, professors i horaris) que ens faciliten veure l'aspecte visual i funcional de Django-Aula per si interessa utilitzar-ho com a sistema de gestió d'aula.

La Demo de l'aplicatiu Django-Aula es pot desplegar en múltiples escenaris, com ara:

* Màquina aïllada o virtual d'accés restringit, amb o sense escriptori gràfic.
* Màquina virtual amb accés des de qulsevol ordinador d'una xarxa local interna.
* Instal·lació en un servidor públic amb accés lliure des d'Internet.

A nivell informatiu, les dades fictícies que l'entorn de demostració portarà precarregades són:

| Rol | Usuaris |
| :--- | :--- |
| **Professors** | `M0 ,M5 ,T0 ,T1 ,T3` |
| **Tutors** | `M2 ,M3 ,M4 ,M7 ,T2 ,T4 ,T5` |
| **Direcció** | `M1 ,M6, T1` |
| **Alumnat rang** | `almn1 - almn229` |


Actualment hi ha dues maneres d'instal·lar la Demo de Django-Aula:

* Instal·lació automatitzada amb docker **(recomanada)**
* Instal·lació manual sense docker


<a name="id31"></a>
### 🐳 3.1 Instal·lació de Docker i Docker Compose

La instal·lació de la Demo amb Docker és el procediment més ràpid amb diferència i s'ha adaptat per poder ser instal·lat en qualsevol tipus de màquina amb sisema operatiu Debian i derivats.

Però per per instal·lar la Demo, **el primer pas imprescindible és instal·lar l'entorn de Docker i Docker Compose**.

**La instal·lació de l'entorn de Docker es pot fer** de forma manual o, preferiblement, **amb un script completament automatitzat** que deixa el sistema preparat per instal·lar la Demmo en molt pocs minuts, sempre amb un usuari amb permisos de `sudo`.

```bash
wget -q -O install_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_docker.sh && chmod +x install_docker.sh && sudo ./install_docker.sh
```

➡  **[Instruccions per instal·lar l'entorn de Docker i Docker Compose](docs/INSTALL_ENTORN_DOCKER.md)**.


<a name="id32"></a>
### 🐳 3.2 Instal·lació ràpida de la Demo amb Docker

Aquest mètode només precisa diposar de quatre arxius per fer el desplegament. Els arxus son:

* **docker-compose.yml**: arxiu que descarrega i configura la Demo
* **.env**: variables internes per la base de dades Postgres (es manté per compatibilitat)
* **Makefile**: Facilita el desplegament amb l'ús d'ordres senzilles.
* **dades_demo.sql**: Dades precarregades per emplenar la base de dades de la Demo.

Es molt interessant crear un directori, dins el directori de l'usuari instal·lador, on s'instal·larà la Demo, per tal de separar la instal·lació d'altre programari que s'hagi volgut instal·lar.

**El procés automatitzat**, que descarregarà els arxius necessaris i desplegarà la Demo , **comença amb la descàrrega i execució automàtica del script anomenat `install_quick_demo_docker.sh`** amb la següent ordre:

```bash
wget -q -O install_quick_demo_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh && chmod +x install_quick_demo_docker.sh && bash ./install_quick_demo_docker.sh
```

Un cop executada la comanda anterior, el script pren el control i desplega automàticament tota la Demo mitjançant Docker, sempre i quan s'hagi instal·lat prèviament l'entorn Docker i docker-compose.

Per tenir més informació del procés es recomana consultar:

➡  **[Instal·lació ràpida de la Demo amb Docker](docs/INSTALL_DEMO_DOCKER.md)**.


<a name="id33"></a>
### 💻 3.3 Instal·lació manual de la Demo

La instal·lació manual de la Demo de Django-Aula és molt més lenta que l'automatitzada amb docker però és pot veure, pas a pas, què cal fer per desplegar-la.

➡️ **[Instruccions per a crear la Quick_Demo](docs/INSTALL_DEMO_MANUAL)**.


<a name="id34"></a>
### 🐳 3.4 Guía per la construcció de la imatge de la Demo de Django-Aula amb Docker

**Aquesta guia** reuneix el coneixement adquirit i **serveix per crear la imatge que, actualment, fa el desplegamet de la Demo amb docker** de forma ràpida. No és el mètode per instal·lar la Demo basada en Docker, però s'inclou a l'índex com a base de coneixement.

**Serveix per crear exclusivament l'entorn de desenvolupament de la imatge Demo amb Docker i per a proves** 


➡  **[Guía per la construcció de la imatge de la Demo de Django-Aula amb Docker](docs/CONSTRUCCIO_IMATGE_DEMO_DOCKER.md)**.

---

<a name="id4"></a>
## 4. Manual per la càrrega de dades, l'administració i el manteniment

Un cop feta la instal·lació de l'aplicatiu hi ha una extensa documentació sobre la posada en marxa, la càrrega inicial de dades (SAGA, Horaris), l'actualització i la gestió de final de curs:

➡️ **[MANUAL DE L'ADMINISTRADOR (Càrrega de dades i Manteniment)](docs/USER_MANUAL/README.md)**


<a name="id5"></a>
## 5. Contribució i Suport

<a name="id-dev"></a>
### Vols col·laborar-hi com a #DEV?

* Aquestes són les [issues prioritàries](https://github.com/ctrl-alt-d/django-aula/issues?q=is%3Aissue%20state%3Aopen%20label%3APrioritari).
* [FAQs (Preguntes Freqüents)](https://github.com/ctrl-alt-d/django-aula/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3AFAQ+)

<a name="id-error"></a>
### Necessites ajuda o vols reportar un error?

* Utilitza el [Formulari d'ajuda/Issues](https://github.com/ctrl-alt-d/django-aula/issues/new/choose).
