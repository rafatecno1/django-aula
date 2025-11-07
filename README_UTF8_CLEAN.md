# django-aula: Gesti Escolar - Software de Gestin de Centros Educatius

Gesti de presncia, incidncies i ms per a Instituts, Escoles i Acadmies.

![Imgur](http://i.imgur.com/YlCRTap.png)

**[Llicncia i Crdits](LICENSE)** | **EL PROGRAMA NO T CAP GARANTIA, UTILITZEU-LO SOTA LA VOSTRA RESPONSABILITAT.**

#  ndex de Continguts

- [1. Caracterstiques Principals i Valor Afegit](#1-caracteristiques-principals-i-valor-afegit)
- [2. Installaci i Desplegament de Django-Aula](#2-installacio-i-desplegament-de-django-aula)
  - [2.1 Installaci Automatitzada de Django-Aula amb Scripts (Mtode Prioritari)](#21-installacio-automatitzada-de-django-aula-amb-scripts-mtode-prioritari)
  - [2.2 Desplegament Manual (Mtode Legat)](#22-desplegament-manual-mtode-legat)
- [3. Entorn de demostraci o Demo de Django-Aula (Quick Demo)](#3-entorn-de-demostraci-o-demo-de-django-aula-quick-demo)
  - [3.1 Installaci manual de la Demo de Django-Aula (Quick_Demo)](#31-installacio-manual-de-la-demo-de-django-aula-quick_demo)
  - [3.2 Guia d'Installaci de Docker i Docker Compose](#32-guia-dinstallacio-de-docker-i-docker-compose)
    - [3.2.1 Installaci rpida de la Demo amb Docker (QUICK_DEMO)](#321-installacio-rapida-de-la-demo-amb-docker-quick_demo)
    - [3.2.2 Guia per la construcci de la imatge de la Demo de Django-Aula amb Docker](#322-guia-per-la-construccio-de-la-imatge-de-la-demo-de-django-aula-amb-docker)
- [4. Manual per la crrega de dades, l'administraci i el manteniment](#4-manual-per-la-crrega-de-dades-ladministracio-i-el-manteniment)
- [5. Contribuci i Suport](#5-contribuci-i-suport)
  - [Vols collaborar-hi com a #DEV?](#vols-collaborar-hi-com-a-dev)
  - [Necessites ajuda o vols reportar un error?](#necessites-ajuda-o-vols-reportar-un-error)


---

## 1. Caracterstiques Principals i Valor Afegit

Django-Aula s un sistema integral dissenyat per alleugerir la crrega de treball del personal i millorar la gesti acadmica i de convivncia.

 **[Llegir totes les CARACTERSTIQUES (perfil de gesti)](docs/USER_MANUAL/caracteristicas.md)**

El programa cobreix tots els aspectes clau de la gesti diria del centre: **Presncia**, **Incidncies**, **Actuacions**, **Sortides** i **Portal de Famlies**.

 **[Llegir totes les FUNCIONALITATS (detall tcnic i pantalles)](docs/USER_MANUAL/funcionalidades.md)**

El sistema s'installa en un entorn Linux, preferiblement Debian 13 o Ubuntu Server 24.04 LTS o superior.

---


## 2. Installaci i Desplegament de Django-Aula

###  2.1 Installaci Automatitzada de Django-Aula amb Scripts (Mtode Prioritari)

S'aha automatitzat el procs complet de desplegament en un servidor, ja sigui una mquina virtual com un servidor VPS, amb el sistema operatiu (Debian/Ubuntu) per garantir una installaci neta i funcional en pocs minuts.

 **[GUIA COMPLETA D'INSTALLACI AUTOMATITZADA](docs/INSTALL_AUTOMATIC_DJAU_SCRIPTS.md)**

###  2.2 Desplegament Manual (Mtode Legat)

Per a installacions sense scripts d'automatitzaci, completalment manuals i guiades pas a pas, o s'explica tot el que s'ha de fer per installar Django-Aula o, fins i tot, per adaptar la installaci a distribucions de Linux diferents de les basades en Debian (com Ubuntu), podeu consultar el procediment manual que ha estat la base per la creaci del procediment d'installaci automatitzat.

[Instruccions de Desplegament Manual](docs/MANUAL_LEGACY/instalacion.md)

---



## 3. Entorn de demostraci o Demo de Django-Aula (Quick Demo)

L'entorn de demostraci, conegut com Demo Django-Aula o Quick Demo, s una versi funcional del sistema i que es desplega en molts minuts, en funci de l'opci que s'escolli. Diposa de dades ficiticies (usuaris, professors i horaris) que ens faciliten veure l'aspecte visual i funcional de Django-Aula.

A nivell informatiu, les dades fictcies que l'entorn de demostraci portar precarregades sn:

| Rol | Usuaris |
| :--- | :--- |
| **Professors** | `M0 ,M5 ,T0 ,T1 ,T3` |
| **Tutors** | `M2 ,M3 ,M4 ,M7 ,T2 ,T4 ,T5` |
| **Direcci** | `M1 ,M6, T1` |
| **Alumnat rang** | `almn1 - almn229` |



Actualment hi ha dues maneres d'installar la Demo de Django-Aula, cadascuna d'elles amb els seus punts forts i febles:

* **Installaci manual**
* **Installaci automatitzada amb docker** (recomanada)




###  3.1 Installaci manual de la Demo de Django-Aula (Quick_Demo)

La installaci manual de la Demo de Django-Aula s ms lenta que l'automatitzada amb docker per s molt ms flexible.

Aquest tipus d'installaci possibilita crear una Demo de l'aplicatiu Django-Aula per a mltiples escenaris, com ara:

* Mquina virtual d'accs restringit, amb o sense escriptori grfic.
* Mquina virtual amb accs des de qulsevol ordinaor d'una xarxa interna.
* Installaci en un servidor pblic amb accs lliure des d'Internet.

 **[Instruccions per a crear la Quick_Demo](docs/INSTALL_DEMO_MANUAL)**.




###  3.2 Guia d'Installaci de Docker i Docker Compose

La installaci de la Demo amb Docker s el procediment ms rpid amb diferncia per, tot i ser funcional, l'accs dels usuaris observadors a la Demo es troba limitat, _de moment_, a tenir accs a la mquina fsica o virtual on s'ha installat.

Per installar la Demo, **el primer pas imprescindible s installar l'entorn de Docker i Docker Compose**.

  **[Instruccions per installar l'entorn de Docker i Docker Compose](docs/INSTALL_ENTORN_DOCKER.md)**.


####  3.2.1 Installaci rpida de la Demo amb Docker (QUICK_DEMO)

Aquest mtode noms precisa diposar de tres arxius per fer el desplegament un dels quals, de fet, s opcional, per molt til. Els arxus son:

* **docker-compose.yml**: arxiu que descarrega i configura la Demo
* **.env**: variables internes per la base de dades Postgres (es mant per compatibilitat)
* **Makefile** (opcional): Facilita el desplegament amb l's d'ordres senzilles.

Es recomana crear un directori, dins el directori de l'usuari installador, on s'installar la Demo.

**El procs automatitzat**, que descarregar els tres arxius necessaris, **comena amb la descrrega i execuci automtica del script anomenat `install_quick_demo_docker.sh`** amb la segent ordre:

```bash
wget -q -O install_quick_demo_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh && chmod +x install_quick_demo_docker.sh && bash ./install_quick_demo_docker.sh
```

Un cop feta la descarrega del script iniciador amb l'ordre anterior, s'executar de forma autnoma i s'encarregar de descarregar els arxius correctes de la carpeta `docker` del repositori per installar els tres arxius que s'encarregaran de crear la Demo de Django-Aula.

Per tenir ms informaci del procs es recomana consultar:

  **[Installaci rpida de la Demo amb Docker](docs/INSTALL_DEMO_DOCKER.md)**.



####  3.2.2 Gua per la construcci de la imatge de la Demo de Django-Aula amb Docker

**Aquesta guia** reuneix el coneixement adquirit i **serveix per crear la imatge que, actualment, fa el desplegamet de la Demo amb docker** de forma rpida i no s el mtode recomanat per installar la Demo basada en Docker.

**Serveix per crear exclusivament l'entorn de desenvolupament de la imatge Demo amb Docker i per a proves** 


  **[Gua per la construcci de la imatge de la Demo de Django-Aula amb Docker](docs/CONSTRUCCIO_IMATGE_DEMO_DOCKER.md)**.

---

## 4. Manual per la crrega de dades, l'administraci i el manteniment

Tota l'extensa documentaci sobre la posada en marxa, la crrega inicial de dades (SAGA, Horaris), l'actualitzaci i la gesti de final de curs es troba aqu:

 **[MANUAL DE L'ADMINISTRADOR (Crrega de dades i Manteniment)](docs/USER_MANUAL/README.md)**


## 5. Contribuci i Suport

### Vols collaborar-hi com a #DEV?

* Aquestes sn les [issues prioritries](https://github.com/ctrl-alt-d/django-aula/issues?q=is%3Aissue%20state%3Aopen%20label%3APrioritari).
* [FAQs (Preguntes Freqents)](https://github.com/ctrl-alt-d/django-aula/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3AFAQ+)

### Necessites ajuda o vols reportar un error?

* Utilitza el [Formulari d'ajuda/Issues](https://github.com/ctrl-alt-d/django-aula/issues/new/choose).
