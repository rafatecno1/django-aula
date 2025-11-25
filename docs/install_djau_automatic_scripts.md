# Guia d'Instal·lació Automatitzada de Django-Aula (Mètode Preferent)

Aquesta guia detalla el procés d'instal·lació automatitzada de **Django-Aula** que consisteix en **tres fases consecutives** automatitzades dissenyades per a desplegaments ràpids, nets i robustos en entorns de servidor..

Cada fase consecutiva s'executa mitjançant un script específic i és imprescindible seguir-les en l’ordre correcte.

**Per començar el procés d'instal·lació, l'usuari instal·lador només caldrà complir els requisitis previs i que es descarregui i executi el primer script**, tal i com s'explica a la Fase 1. 

| Fase | Descripció | Script |
|------|-------------|--------|
| **Fase 1** | Instal·lació base de Django-Aula i configuració inicial | `install_djau.sh` |
| **Fase 2** | Instal·lació i configuració del servidor web Apache | `setup_apache.sh` |
| **Fase 3** | Automatització de tasques periòdiques (CRON) | `setup_cron.sh` |

---

## Índex

- [1. Requisits i Preparació Prèvia](#id1)  
   - [1.1 Requisits de Servidor](#id11)  
   - [1.2 Configuració de Correu i DNS](#id12)  
- [2. Fases d’Instal·lació Automatitzada](#id2)  
   - [2.1 Fase 1: Instal·lació i Configuració de Django-Aula](#id21)  
   - [2.2 Fase 2: Instal·lació del Servidor Web Apache](#id22)  
   - [2.3 Fase 3: Automatització de Tasques (CRON)](#id23)

---

<a name="id1"></a>
## 1. Requisits i Preparació Prèvia

Abans d'iniciar la instal·lació, és imprescindible preparar l'entorn amb la informació i els permisos necessaris.

<a name="id11"></a>
### 1.1 Requisits de Servidor

* **Sistema Operatiu:** Ubuntu Server 22.04 LTS o Debian 13.  
* **Accés:** SSH amb privilegis `root` o un usuari amb accés a `sudo`.  
  👉 **[Documentació per crear un nou usuari amb permisos de `sudo`](USER_MANUAL/ajuda-install/usuari_sudo.md)**  

És altament recomanable:  
👉 **[Configurar el servidor per garantir un mínim de seguretat (Usuaris, Root sense SSH, Claus d’accés, Fail2Ban)](USER_MANUAL/ajuda-install/seguretat_ssh.md)**

<a name="id12"></a>
### 1.2 Configuració de Correu i DNS

L'aplicació necessita una adreça de correu per a l'enviament de notificacions i la gestió de sessions.

* **Compte de Correu:** Cal crear un compte dedicat i obtenir una **contrasenya d’aplicació** (*App Password*) si s’utilitza un servei com Google o Microsoft.  
  👉 **[Guia per a la creació de Compte de Correu i Contrasenya d'Aplicació](USER_MANUAL/ajuda-install/config_correu.md)**

* **Dominis i DNS:** La configuració dels registres DNS dependrà del tipus de servidor:
  * **Servidor intern privat, sense accés a Internet:** Accés per IP interna o nom de la màquina dins la xarxa.  
  * **Servidor extern públic (típicament un VPS):** El domini principal (`$DOMAIN_NAME`) i el `www.` han d'apuntar a l'IP pública del servidor.  

  👉 **[Guia per a la creació dels registres DNS per redirigir les visites al servidor públic i per a la instal·lació de certificats Let's Encrypt](USER_MANUAL/ajuda-install/registres_dns.md)**

---

<a name="id2"></a>
## 2. Fases d’Instal·lació Automatitzada

L’aplicació s’instal·la i es configura mitjançant l’execució seqüencial de diferents scripts interactius.

---

<a name="id21"></a>
### 2.1 Fase 1: Instal·lació i Configuració de Django-Aula (`install_djau.sh` + `setup_djau.sh`)

El primer script, `install_djau.sh`, realitza la preparació inicial del sistema: instal·la totes les dependències necessàries (`Python`, `PostgreSQL`, etc.), crea els directoris i ajusta els permisos de l’usuari amb el qual es fa la instal·lació (per defecte, usuari `djau`).  

També clona el repositori de Django-Aula i instal·la altres eines administratives, especialment **Fail2Ban**, per a protegir l'accés per força bruta al servidor fent servir el servei SSH o d'altres.

**Començament de la instal·lació:**

Des del directori del compte d'usuari creat amb permisos `sudo` cal executar la següent instrucció, que descarregarà i executarà, només, el script `install_djau.sh`.

```bash
wget -q -O install_djau.sh https://raw.githubusercontent.com/rafatecno1/django-aula/refs/heads/master/install_djau.sh && chmod +x install_djau.sh && sudo ./install_djau.sh
```

#### Execució de `install_djau.sh`

Durant l'execució, es demanarà:

* Nom del **directori d'instal·lació** de l'aplicatiu **Django-Aula**.  
* Nom del **directori** per desar-hi les **dades privades** de l’alumnat.  
* Nom de l’**usuari de Linux que instal·larà** (usuari amb permisos `sudo`) **Django-Aula**.  

Un cop finalitzat l'execució del primer script, s’executarà el segon, anomenat `setup_djau.sh`, de forma automàtica.

#### Execució automàtica de `setup_djau.sh`

Aquest script configura l’entorn de Python, instal·la els requeriments específics, personalitza Django-Aula per al centre educatiu i prepara la base de dades `PostgreSQL`.

La tasca principal d'aquest script automatitzar la personalització, mitjançant preguntes a l'usuari, d'un arxiu molt important anomenat `settings_local.py`, que es troba dins el directori `aula`. Dit això, un cop creat i personalitzat, sempre es pot editar manualment a posteriori.

Durant aquest procés es demanaran dades com:

* **Base de dades:** nom i usuari administrador.  
* **Dades del centre:** nom, localitat i codi.  
* **Domini:** nom del domini/subdomini i tipus d’instal·lació (xarxa local interna “INT” o servidor públic a internet “PUB”).  
* **Correu electrònic:** adreça i contrasenya d’aplicació per SMTP, així com l’adreça visible per al destinatari.  
* **Superusuari Django-Aula:** correu i contrasenya per al superusuari `admin`.  

Un cop finalitzada l'execució d'aquest script es dona l'opció d'executar el script `test_email.sh` per provar l’enviament de correu prèviament configurat. Aquest script llegeix les dades de l'arxiu `settings_local.py` i es pot executar manualment sempre que es vulgui fer una prova d'enviament de correu. 

---

<a name="id22"></a>
### 2.2 Fase 2: Instal·lació del Servidor Web Apache (`setup_apache.sh`)

Django-Aula fa servir el servidor web **Apache**, per tant, aquest script instal·la i configura el servidor web, activa el tallafocs **UFW** i gestiona la creació de certificats, autofirmats o amb **Let's Encrypt** (si es tracta d’una instal·lació pública).

**Execució:**

Suposant que Django-Aula s'ha instal·lat en un directori anomenat `djau`, caldrà accedir al directori `setup_djau` del projecte i executar, amb permisos `sudo`, la següent instrucció. La informació precisa de la ubicació del script es proporcionarà a la finalització del scrip `install_djau.sh` de la Fase 1.

```bash
cd /opt/djau/setup_apache
sudo ./setup_apache.sh
```

El script prepara els fitxers de configuració (Virtual Hosts) segons el tipus d’instal·lació triat:

* **Servidor Intern (HTTP):** sense certificats.  
* **Servidor Públic (HTTPS)** amb **certificats auto-firmant:** ràpid però no de confiança per als navegadors.  
* **Servidor Públic (HTTPS)** amb **certificats reconeguts de Let's Encrypt:** opció recomanada.  

**Configuració Let's Encrypt (recomanada):**

Caldrà contestar un seguit de preguntes que el script `Certbot` ens farà per poder generar els certificats pel nostre domini o subdomini.

Algunes d'aquestes preguntes seran:
  
* Una adreça de correu vàlida.  
* Confirmació per habilitar HTTPS en ambdós dominis (amb i sense `www`).  
* Escollir l’opció “2” per redirigir automàticament el trànsit HTTP cap a HTTPS.  

Els certificats de Let's Encrypt caduquen als 90 dies de la seva generació, però Certbot s'encarrega automàticament de programar l'**autorrenovació dels certificats** si falta menys d'un mes per la caducitat dels certificats existents. En aquest cas procedeix, de forma automàtica a la autorenovació dels certificats.

Un cop generats els certificats per Let's Encrypt sense errades, el script `setup_apache.sh` **tenim la possibilitat de fer dues proves opcionals**:
* Comrovar si Cetbot ha programat correctament l'autorenovació dels certificats en el sistema, per estar-ne segurs de que s'autorenovaran.
* Fer una simulació de renovació dels certificats

---

<a name="id23"></a>
### 2.3 Fase 3: Automatització de Tasques (CRON) (`setup_cron.sh`)

Django-Aula requereix dur a terme tasques periòdiques automatitzades.  
Aquest script modifica el fitxer de sistema `crontab` per programar-les, inclosa la còpia de seguretat automàtica de la base de dades `PostgreSQL`.

**Execució:**

De nou, suposarem que Django-Aula s'ha instal·lat en un directori anomenat `djau`. Caldrà assegurar-nos que ja ens trobem al directori `setup_djau` del projecte i executar, amb permisos `sudo`, la següent instrucció.

```bash
cd /opt/djau/setup_apache
sudo ./setup_cron.sh
```

En finalitzar, el script informa de les tasques programades i dels horaris d’execució.  

Un cop completada la **Fase 3**, el servidor estarà totalment operatiu.  
Podeu accedir a l’aplicació mitjançant el domini que s'hagi configurat, típicament quelcom com:

```
https://djau.elteudomini.cat]
```
