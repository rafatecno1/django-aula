# Instal·lació ràpida de la Demo de Django-Aula amb Docker (QUICK_DEMO)

Aquest document explica com posar en funcionament, de la manera més ràpida i fàcil, una Demo de Django-Aula.

Cal recordar que el primer pas és instal·lar l'entorn de Docker i docker-compose i és una fase imprescindible si no s'ha fet abans:

  👉 **[Guia per la instal·lació de Docker i docker-compose](INSTALL_ENTORN_DOCKER.md)**  (Es pot obviar si ja s'ha fet)

La Demo, desplegada amb Docker, utilitza una imatge preparada per crear un contenidor amb les **dades de demostració precàrregades**, el que permet un estalvi de temps molt important.

La Demo pot ser instal·lada tant a una màquina aïllada de cap xarxa, com a una màquina en xarxa local com a un servidor públic que tingui un domini o subdomini associat.

**Només cal descarregar i executar un arxiu (script) d'instal·lació per posar-la en marxa**.

---

# Ìndex

- [1. Descàrrega i execució del script per posar en marxa la Demo](#id1)
- [2. Funcionament del script automatitzat per la instal·lació de la Demo](#id2)
   - [2.1 Què fa l'automatització?](#id21)
   - [2.2 Arxius descarregats amb la instal·lats i la seva funció](#id22)
- [3. informació sobre l'arxiu `Makefile` i les ordres disponibles](#id3)
- [4. Accés a la Demo un cop instal·lada i en correcte funcionament](#id4)
   - [4.1 Sistemes operatius que disposin d'un entorn gràfic local](#id41)
   - [4.2 Màquina virtualitzada amb xarxa NAT configurada](#id42)
   - [4.3 Màquina virtualitzada amb xarxa bridge configurada o servidor públic (VPS)](#id43)

---

<a name="id1"></a>
## 1. Descàrrega i execució del script per posar en marxa la Demo

Es recomana crear un directori, dins el directori de l'usuari instal·lador, on es descarregarà el script i on es guardaran els arxius necessaris per desplegar la Demo de Django-Aula. Per exemple `demo-djau.docker`:

```bash
mkdir demo-djau-docker
cd demo-djau-docker
```

Un cop creat el directori on s'instal·larà la Demo només caldrà descarregar el script automatitzat d'instal·lació. Amb la comanda següent no només es descarrega l'arxiu sinó que començarà a executar-se automàticament:

```bash
wget -q -O install_quick_demo_docker.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh && chmod +x install_quick_demo_docker.sh && bash ./install_quick_demo_docker.sh
```

<a name="id2"></a>
## 2. Funcionament del script automatitzat per la instal·lació de la Demo

<a name="id21"></a>
### 2.1 Què fa l'automatització?

El script automatitzat du a terme vàries tasques, que són:

1 - Descarregar els arxius necessaris des del repositori del projecte, reanomenar-los, i situar-los o han d'estar per poder fer el desplegament dels contenidors de Docker.  

2 - Instal·lar la comanda `make` si no es troba instatal·lada en el sistema. Si fos el cas, demanarà la contrasenya per activar el permís de `sudo`.  

3 - Facilitar l'edició de l'arxiu *.env* per configurar el tipus de màquina on es vol instal·lar la Demo mitjançant la llista *ALLOWED_HOSTS*:  
  - **Màquina aïllada o virtualitzada amb xarxa NAT**: No caldrà afegir res a la llisa. Per defecte la Demo se serveix en *localhost:8000* (127.0.0.1:8000)  
  - **Màquina en xarxa local o virtualitzada amb xarxa bridge:** Caldrà afegir l'IP de la màquina a la xarxa local.
  - **Servidor públic (VPS)**: Caldrà afegir l'IP pública del servidor i, si se'n diposa, el domini i/o subdominis que estiguin apuntant a aquesta IP pública.  

4 - Amb els arxius descarregats i configurats, posar en marxa els dos contenidors necessaris pel funcionament de la Demo, un per la pròpia Demo, anomenat demo_web, i un altre per la base de dades PostgreSQL, anomenat demo_db.  

5 - Comprovar que el contenidor PostgreSQL estigui llest i que ha pogut llegir l'arxiu de dades precarrergades *sql* descarregat del repositori.  

6 - Mostrar l'estat dels contenidors desplegats per comprovar que estan funcionant correctament.
  
<a name="id22"></a>
### 2.2 Arxius descarregats amb la instal·lats i la seva funció

Per tal de tenir els arxius correctament situats i ordenats, el script descarrega, reanomena i reubica quatre fitxers, tres dels quals se situaran a l'arrel del directori que s'hagi creat, menter que l'arxiu *sql* es situarà a un altre directori específic.

Els arxius són:

1 - `docker-compose.yml`  
2 - `.env`  
3 - `Makefile`  
4 - `dades_demo.sql`  


Aquesta instal·lació us proporciona els següents fitxers, ubicats al vostre directori de treball:

| Fitxer | Funció | Annotacions |
| :--- | :--- | :--- |
| **`docker-compose.yml`** | Defineix els serveis **web** (Django-Aula) i **db** (PostgreSQL). | Utilitza la imatge oficial de PostgreSQL i la imatge de la Demo. |
| **`.env`** | Conté les credencials de la base de dades i la llista *ALLOWED_HOSTS*. | **No cal modificar la secció de la base de dades**. En canvi pot ser necessari afegir IP i/o dominis a la llista *ALLOWED_HOSTS*. |
| **`Makefile`** | Simplifica la gestió dels contenidors amb ordres curtes. | Inclou les comandes essencials de serve, stop, down i logs. |
| **`dades_demo.sql`** | Conté les dades que emplenaran la base de dades de PostgreSQL. | És l'únic arxiu que es situarà dins un directori específic, que és el llegirà el contenidor *demo_db*. |

<a name="id3"></a>
## 3. informació sobre l'arxiu `Makefile` i les ordres disponibles

El fitxer `Makefile` simplifica la interacció amb els contenidors de Docker. Les comandes disponibles per a aquesta instal·lació són:

| Comanda | Funció | Ordre Subjacent |
| :--- | :--- | :--- |
| **`make serve`** | Posa en marxa els serveis (Web i DB) en segon pla (detached). | `docker compose up -d` |
| **`make stop`** | Atura els serveis sense eliminar els contenidors ni les dades. | `docker compose stop` |
| **`make down`** | Atura els serveis, elimina els contenidors i **elimina permanentment la base de dades** | `docker compose down -v` |
| **`make logs`** | Mostra els logs de tots dos serveis en temps real. | `docker compose logs -f` |

**Detall de les ordres del `Makefile`**

Per a referència, les ordres exactes del Makefile són:

```makefile
serve:
	@echo "=> Running demo services (detached)"
	@docker compose -f docker-compose.yml up -d

stop:
	@echo "=> Stopping demo services"
	@docker compose -f docker-compose.yml stop

down:
	@echo "=> Stopping demo services and deleting DB"
	@docker compose -f docker-compose.yml down -v

logs:
	@echo "=> Showing logs (Press Ctrl+C to exit)"
	@docker compose -f docker-compose.yml logs -f
```

<a name="id4"></a>
## 4. Accés a la Demo un cop instal·lada i en correcte funcionament

Un cop execut l'arxiu d'instal·lació automatitzada i amb els quatre arxius necessaris descarregats, ja s'ha executat la comanda `make serve` i l'aplicació estarà accessible en el port **8000** fent servir el servidor per a proves de Django.

Per accedir-hi dependrà del tipus de màquina on hagim desplegat la Demo.

<a name="id41"></a>
### 4.1 Sistemes operatius que disposin d'un entorn gràfic local

Si el sistema operatiu on s'executa Docker té entorn gràfic, podeu accedir directament amb el seu propi navegador escrivint l'url:

```
http://localhost:8000 o també http://127.0.0.1:8000
```

<a name="id42"></a>
### 4.2 Màquina virtualitzada amb xarxa NAT configurada

Si hem desplegat la Demo dins una màquina virtual (VM) amb **xarxa NAT** cal fer un mapeig de ports. Suposant que el mapeig ha consistit en assignar el port `127.0.0.1` de la màquina anfitriona (*host*) per a que apunti a la IP de la màquina virtualitzada (*guest*) es podrà accedir a la Demo amb un navegador d'internet des de la màquina anfitriona *host*:

```
http://127.0.0.1:8000
```     

<a name="id43"></a>
### 4.3 Màquina virtualitzada amb xarxa bridge configurada o servidor públic (VPS)

Amb una màquina virtualitzada amb Xarxa Bridge, tinguin o no IP Estàtica, haurem hagut d'afegir l'IP de la màquina virtual a l'arxiu `.env`, preferíblement fent servir el script automatitzat, però sempre ho podem fer manualment. 

L'arxiu *.env* facilita afegir la IP perquè el que realment fa és afegir l'IP de la màquina a l'arxiu `demo.py` que es troba dins el contenidor *demo_web*. Afegir la IP manualment a la llista `ALLOWED_HOSTS` és molt més complicat dins un contenidor i sobretot **temporal**, perquè si detenim el contenidor i el tornem a aixecar, el canvi efectuat es perdria.

Suposant que la IP de la màquina virtualitzada fos la 192.168.18.168

Des d'un navegador de qualsevol màquina de la xarxal local interna s'hauria de poder accedir a la Demo escrivint l'url:

```
http://192.168.18.168:8000
```

Si fos un VPS amb un domini o subdomini com *demo.djau.elteudomini.cat*, escriuríem, des del qualsevol dispositiu connectat a internet, com per exemple un mòbil, el següent:

```
http://demo.djau.elteudomini.cat:8000
```   


> **IMPORTANT:** Aquesta Demo Docker corre amb un servidor de proves de Django, pensat pel desenvolupament de l'aplicatiu, i és molt limitat. No està preparat ni per acceptar connexions segures de tipus https ni per fer front a atacs de hackers. La seva perdurabilitat en el temps no es pot assegurar.


