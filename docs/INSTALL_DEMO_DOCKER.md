# 🐳 Instal·lació i Gestió de la Demo Ràpida amb Docker (QUICK_DEMO)

Aquest document detalla el procés complet per iniciar la Demo Ràpida de Django-Aula mitjançant Docker. Aquesta demo utilitza una imatge amb les dades de demostració precàrregades, de manera que només cal executar un parell d'ordres per posar-la en marxa.

---

## 1. Instal·lació i Descàrrega dels Arxius de Configuració

L'entorn de la Demo es basa en tres fitxers a l'arrel del directori de treball (`docker-compose.yml`, `.env`, i `Makefile`). El següent *script* s'encarrega de descarregar i anomenar correctament aquests fitxers des del repositori:

Es recomana crear una carpeta on es descarregarà el script i on es guardaran els arxius necessaris per desplegar la Demo de Django-Aula.

**Comanda d'instal·lació automatitzada:**

```bash
wget -q -O install_quick_demo_docker.sh [https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh](https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/docker/install_quick_demo_docker.sh) && chmod +x install_quick_demo_docker.sh && bash ./install_quick_demo_docker.sh
```

## 2. Arxius instal·lats i la seva funció

Aquesta instal·lació us proporciona els següents fitxers, ubicats al vostre directori de treball:

| Fitxer | Funció | Annotacions |
| :--- | :--- | :--- |
| **`docker-compose.yml`** | Defineix els serveis **web** (Django-Aula) i **db** (PostgreSQL). | Utilitza la imatge pública i precàrregada amb les dades per a la Demo. |
| **`.env`** | Conté les credencials de la base de dades. | **No cal modificar-lo** per a aquesta Demo. |
| **`Makefile`** | Simplifica la gestió dels contenidors amb ordres curtes. | Inclou les comandes essencials de serve, stop, down i logs. |

## 3. Gestió de la Demo amb `Makefile`

El fitxer `Makefile` simplifica la interacció amb els contenidors de Docker. Les comandes disponibles per a aquesta instal·lació són:

| Comanda `make` | Funció | Ordre Subjacent |
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


## 4. Accés a la Demo

Un cop executada la comanda `make serve`, l'aplicació estarà accessible de les següents maneres (per defecte, el port mapejat és el **8000**):

1.  **En sistemes operatius que disposin d'un entorn gràfic local (o VM amb NAT):**

    Si el sistema operatiu on s'executa Docker té entorn gràfic, podeu accedir directament amb `localhost`:

    ```
    http://localhost:8000
    ```

    * Si tenim una màquina virtual (VM) amb **xarxa NAT** i heu fet un mapeig de ports, de tal manera que el port `127.0.0.1` de la màquina *host* apunti a la IP de la màquina virtual *guest* podràs accedir a la Demo amb un navegador des de la màquina anfitriona (*host*):

        ➡️ `http://127.0.0.1:8000`

2.  **En Entorns amb Xarxa Bridge o IP Estàtica (Només per a accedir mitjançant la Xarxa Local):**

    * Si estàs instal·lant la Demo de Django-Aula a una màquina virtual amb **xarxa bridge** i la tens configurada tal i com s'explica a l'arxiu [INSTAL·LACIÓ MANUAL DE LA DEMO](INSTALL_MANUAL_DEMO.md), tindrà una IP estàtica configurada (p. ex., `192.168.18.140`). En aquest cas, també hauries de poder accedir des qualsevol ordinador de la xarxa interna utilitzant:

        ➡️ `http://192.168.18.140:8000`

> **IMPORTANT:** Aquesta Demo Docker està limitada a `localhost` i la IP del contenidor. Per a un desplegament en un servidor públic (VPS) amb xarxa *bridge*, es recomana la [Instal·lació de la Demo de forma manual en un VPS](INSTALL_MANUAL_DEMO.md) per poder configurar correctament la llista `ALLOWED_HOSTS` de Django.