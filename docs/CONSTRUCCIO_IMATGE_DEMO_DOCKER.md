# ?? Gu¨ªa per la construcci¨® de la imatge de la Demo de Django-Aula amb Docker

**Aquesta guia** reuneix el coneixement adquirit i **serveix per crear la imatge que, actualment, fa el desplegamet de la Demo amb docker** de forma r¨¤pida i no ¨¦s el m¨¨tode recomanat per instal¡¤lar la Demo basada en Docker.

**Serveix per crear exclusivament l'entorn de desenvolupament de la imatge Demo amb Docker i per a proves** 

---
# ¨ªndex
  - [1. Requisits](#1-Requisits)
  - [2. Instruccions de funcionament](#2-Instruccions-de-funcionament)
    - [2.1 Pas 1: Preparaci¨® (Clonar i Configurar Entorn)](#21-Pas-1-Preparaci¨®-Clonar-i-Configurar-Entorn)
      - [2.1.1. Clona el repositori (inclou Makefile, Dockerfile, docker-compose.yaml i env.example)](#211-Clona-el-repositori-inclou-Makefile-Dockerfile-docker-composeyaml-i-envexample)
      - [2.1.2. C¨°pia dels arxius necessaris per construir la imatge de la demo de Docker](#212-C¨°pia-dels-arxius-necessaris-per-construir-la-imatge-de-la-demo-de-Docker)
      - [2.1.3 Edici¨® (opcional) del fitxer de variables d'entorn](#213-Edici¨®-opcional-del-fitxer-de-variables-dentorn)
      - [2.1.4. Ajustar la ubicaci¨® d'alguns arxius](#214-Ajustar-la-ubicaci¨®-dalguns-arxius)
    - [2.2 Pas 2: Construir la imatge i Iniciar l'Entorn](#22-Pas-2-Construir-la-imatge-i-Iniciar-lEntorn)
      - [2.2.1 Construir la imatge per la Demo de django-aula](#221-Construir-la-imatge-per-la-Demo-de-django-aula)
      - [2.2.2 Iniciar l'entorn i servir la Demo (runserver)](#222-Iniciar-lentorn-i-servir-la-Demo-runserver)
    - [2.3 Pas 3: Carregar les Dades de Demostraci¨®](#23-Pas-3-Carregar-les-Dades-de-Demostraci¨®)
    - [2.4 Pas 4: Acc¨¦s a la Demo de Django-Aula](#24-Pas-4-Acc¨¦s-a-la-Demo-de-Django-Aula)

---

## 1. Requisits

* **Sistema Operatiu:** Ubuntu Server 22.04 LTS o Debian 13.
* **Acc¨¦s:** Es requereix un usuari amb acc¨¦s a `sudo`.  
  ?? **[Documentaci¨® per crear un nou usuari amb permisos de `sudo`](USUARI_SUDO.md)** 

## 2. Instruccions de funcionament

El projecte fa servir l'arxiu `Makefile` com a capa d'abstracci¨®. Aix¨° significa que en lloc d'escriure comandes llargues de `docker compose`, s'utilitzen targets senzills de `make` que executen les instruccions complexes de fons. Algunes d'aquests instruccions s¨®n:

| Comanda `make` | Qu¨¨ fa realment (Comanda `docker-compose`) | Prop¨°sit |
| :--- | :--- | :--- |
| **`make build`** | `docker compose -f docker-compose.demo.yml build --no-cache web` | Construeix la imatge que utilitzar¨¤ el contenidor per la Demo de Django-Aula). |
| **`make start`** | `docker compose -f docker-compose.demo.yml up` | Construeix i inicia els contenidors (Web per Django-Aula i DB per PostgreSQL). |
| **`make serve`** | `docker compose -f docker-compose.demo.yml up -d` | Construeix i inicia els contenidors, com make start, per¨° deixant el terminal operatiu. |
| **`make stop`** | `docker compose -f docker-compose.demo.yml stop` | Atura el funcionament dels contenidors Web i DB en funcionament. |
| **`make down`** | `docker compose -f docker-compose.demo.yml down -v` | Atura i elimina els contenidors i la xarxa, ideal per netejar l'entorn. |
| **`make load_demo_data`** | `docker compose -f docker-compose.demo.yml exec web python manage.py loaddemodata` | Carrega les dades de demostraci¨® al contenidor DB de l'aplicaci¨®. |


### 2.1 Pas 1: Preparaci¨® (Clonar i Configurar Entorn)

#### 2.1.1. Clona el repositori (inclou Makefile, Dockerfile, docker-compose.yaml i env.example)

La seg¨¹ent comanda clonar¨¤ el repositori i crear¨¤ una carpeta anomenada `django-aula`.

```bash
git clone https://github.com/ctrl-alt-d/django-aula.git django-aula
cd django-aula
```

Dins el repositori trobarem el directori `docker` que cont¨¦ tots els arxius relacionats amb aquest entorn. Haurem de copiar els que necessitem al directori arrel del projecte clona, segons el pas anterior `django-aula`.


#### 2.1.2. C¨°pia dels arxius necessaris per construir la imatge de la demo de Docker

Necessitem que al directori arrel del projecte hi hagi els seg¨¹ents arxius:
- **Dockerfile**: El creador de la imatge de la Demo de Django-Aula.
- **.dockerignore**: Dins d'aquest arxiu s'explicita quins arxius del repositori clonat es volen excloure de la imatge de la Demo que generar¨¤ l'arxiu Dockerfile.
- **docker-compose.yml**: S'encarrega de descarregar el contenidor de la Demo, si existeix, o de crear-lo, aixi com d'aixecar d'altres contenidors necessaris, com el de PostgreSQL, i d'enlla?ar-los.
- **Makefile**: Arxiu opcional facilitador, per¨° molt ¨²til, que permet, amb comandes senzilles, fer operacions essencials com posar en execuci¨® els contenidors, detenir-los, o d'altres.
- **.env**: Arxiu que guarda els noms en variables d'entorn que necessitar¨¤ PostgreSQL per crear i guestionar la base de dades de la Demo.

Tots aquests arxius es troben dins la carpeta `docker` per¨° all¨¤ tenen d'altres noms. Per crear una nova imatge de la Demo de Django-Aula necessitarem copiar els seg¨¹ents arxius, canviar-los el nom i deixar-los al directori arrel del projecte:

```bash
cp docker/Dockerfile.demo.manual Dockerfile
cp docker/.dockerignore.demo.manual .dockerignore
cp docker/docker-compose.demo.manual.yml docker-compose.demo.yml
cp docker/Makefile.demo.manual Makefile
cp docker/env.example .env
```

#### 2.1.3 Edici¨® (opcional) del fitxer de variables d'entorn

L'arxiu `.env`, copiat a partir de l'arxiu d'exemple, cont¨¦ les variables de connexi¨® a la base de dades (PostgreSQL).

Per fer proves pots utilitzar les credencials existents per defecte ('secret'), per¨° si la intenci¨® ¨¦s crear realment un nou contenidor Demo millorat, el millor ¨¦s editar les variables i canviar els seus valors. 

```bash
nano .env
```

#### 2.1.4. Ajustar la ubicaci¨® d'alguns arxius

En el proc¨¦s de creaci¨® del contenidor Django-Aula:demo existent i allotjat en Docker-Hub hem vist que era necessari copiar temoralment un seguit d'arxius que al repositori es troben a un directori a un altre directori diferent.

Concretament, el proc¨¦s que fallava era l'¨²ltim, el de la c¨¤rrega de les dades que es feia amb l'ordre `make load_demo_data` que ¨¦s el que s'encarrega d'emplenar la base de dades en PostgreSQL amb les dades fict¨ªcies de la Demo. Aquesta c¨°pia, que ara per ara cal fer ¨¦s temporal, i nom¨¦s serveix per crear la imatge que far¨¤ servir el contenidor Web (Django-Aula), d'aquesta forma tot es trobar¨¤ on ara mateix la Demo programada per l'equip de desenvolupament espera trobar aquests arxius.

```bash
mkdir static
cp -r demo/static-web/demo static/
```
Despr¨¦s d'aquesta operaci¨® hauria d'haver el directori `./static/demo`a l'arrel de projecte amb, b¨¤sicament, un seguit d'arxius d'imatges i un arxiu html.


### 2.2 Pas 2: Construir la imatge i Iniciar l'Entorn

#### 2.2.1 Construir la imatge per la Demo de django-aula

Per construir la imatge farem servir la comanda `make build`, definida a l'arxiu `Makerfile`

```bash
make build
```

#### 2.2.2 Iniciar l'entorn i servir la Demo (runserver)

Per iniciar l'entorn i poder servir tant la Demo de Django-Aula com la base de dades de PostgreSQL, que ara est¨¤ bu?da, es pot fer de dues maneres:

* Si es vol deixar el terminal sense acc¨¦s a la l¨ªnia de comandaments per¨° que ens mostri la informaci¨® de l'inici del servidor i del que est¨¤ passant:
   ```bash
   make start 
   ```
* Si es vol tenir un terminal amb acc¨¦s a la l¨ªnia de comandaments per¨° que NO ens mostri la informaci¨® de l'inici del servidor i del que est¨¤ passant:
   ```bash
   make serve 
   ```

### 2.3 Pas 3: Carregar les Dades de Demostraci¨®

Per carregar les dades necessitem un terminal operatiu. Si hem fet servir `make serve`, ja el tindrem, per¨° si hem fet servir `make start` haurem d'obrir un altre terminal amb SSH per poder procedir a la c¨¤rrega de les dades.

Amb un terminal operatiu podem comprovar si els contenidors s'han creat i es troben actius amb `docker ps`. Si tot ¨¦s correcte es poden carregar les dades de demostraci¨® de la Demo de django-aula:

```bash
make load_demo_data
```
A t¨ªtol informatiu, la comanda anterior executa `python manage.py loaddemodata` dins del contenidor 'web'.


**Opcional:**  Abans haviem creat una carpeta anomenada `static` i hi haviem copiat tot un seguit d'arxius per generar la imatge, per¨° que un cop generada, ja no serveixen. **Si no hem de constuir cap imatge nova m¨¦s**, els podriem esborrar amb:

```bash
rm -rf static
```

### 2.4 Pas 4: Acc¨¦s a la Demo de Django-Aula

Si tot ha anat b¨¦, l'aplicaci¨® s'executar¨¤ dins del contenidor web, i el port a fer servir ser¨¤ el port 8000 perqu¨¨ l'arxiu `docker-compose.yaml` els ha mapejat i els ha fet coincidir:

* Si tenim escriptori gr¨¤fic, podem escriure al navegador, l'IP 127.0.0.1. Si tenim una m¨¤quina virtual amb xarxa NAT i hem fet un mapeat de ports, de tal manera que el port 127.0.0.1 de la m¨¤quina _host_ apunti a la IP de la m¨¤quina virtual _guest_ podr¨¤s accedir a la Demo amb un navegador des de la m¨¤quina anfitrionia (host):

  ?? http://127.0.0.1:8000

* Si est¨¤s instal¡¤lant la demo de Django-Aula a una m¨¤quina virtual amb xarxa bridge i la tens configurada tal i com s'explica a l'arxiu [INSTAL¡¤LACI¨® MANUAL DE LA DEMO](INSTALL_MANUAL_DEMO.md), tindr¨¤ una IP est¨¤tica configurada (p. ex., 192.168.18.140). En aquest cas tamb¨¦ hauries de poder accedir des qualsevol ordinador de la xarxa interna utilitzant:

  ?? http://192.168.18.140:8000
