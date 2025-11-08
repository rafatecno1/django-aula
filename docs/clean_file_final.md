# InstalÂ·aciÃ³ manual de la Demo de Django-Aula

Aquesta guia ofereix les **instruccions per instalÂ·lar manualment una instÃ ncia d'un entornt de prova (Demo) de Django-Aula** amb un conjunt de dades fictÃ­cies (usuaris, professors i horaris) per tal de provar-ne les funcionalitats.  
Aquest mÃ¨tode estÃ  dissenyat per a entorns de prova, no de producciÃ³.

---

# Ã­ndex
  - [1. Requisits de Servidor](#1-Requisits-de-Servidor)
  - [2. Usuaris que es crean en la Demo i les seves credencials](#2-Usuaris-que-es-crean-en-la-Demo-i-les-seves-credencials)
  - [3. Instruccions d'InstalÂ·laciÃ³](#3-Instruccions-dInstalÂ·laciÃ³)
    - [3.1 PreparaciÃ³ de l'Entorn](#31-PreparaciÃ³-de-lEntorn)
    - [3.2 ClonaciÃ³ del repositorio i InstalÂ·laciÃ³ de l'AplicaciÃ³](#32-ClonaciÃ³-del-repositorio-i-InstalÂ·laciÃ³-de-lAplicaciÃ³)
    - [3.3 CreaciÃ³ de Dades i ExecuciÃ³](#33-CreaciÃ³-de-Dades-i-ExecuciÃ³)
    - [3.4. AccÃ©s a la Demo amb Entorn GrÃ fic (MÃ quina Local)](#34-AccÃ©s-a-la-Demo-amb-Entorn-GrÃ fic-MÃ quina-Local)
  - [4. Accedir des d'un altre ordinador a la mÃ quina on s'ha instalÂ·lat la Demo](#4-Accedir-des-dun-altre-ordinador-a-la-mÃ quina-on-sha-instalÂ·lat-la-Demo)
    - [4.1 MÃ quina virtual creada amb VirtualBox i configurada amb xarxa NAT](#41-MÃ quina-virtual-creada-amb-VirtualBox-i-configurada-amb-xarxa-NAT)
    - [4.2 MÃ quina virtual creada amb VirtualBox i configurada amb xarxa BRIDGE (pont)](#42-MÃ quina-virtual-creada-amb-VirtualBox-i-configurada-amb-xarxa-BRIDGE-pont)
    - [4.3 InstalÂ·laciÃ³ de la Demo en un servidor pÃºblic amb accÃ©s extern (VPS)](#43-InstalÂ·laciÃ³-de-la-Demo-en-un-servidor-pÃºblic-amb-accÃ©s-extern-VPS)
    - [4.4 Resum de les modificacions de la llista *ALLOWED_HOSTS* de l'arxiu *common.py*](#44-Resum-de-les-modificacions-de-la-llista-ALLOWED_HOSTS-de-larxiu-commonpy)
  - [5 Mantenir l'execucÃ­Ã³ indefinida en el temps del servidor de DemostraciÃ³](#5-Mantenir-lexecucÃ­Ã³-indefinida-en-el-temps-del-servidor-de-DemostraciÃ³)

---

## 1. Requisits de Servidor

* **Sistema Operatiu:** Ubuntu Server 22.04 LTS o Debian 13.
* **AccÃ©s:** Es requereix un usuari amb accÃ©s a `sudo`.  
    **[DocumentaciÃ³ per crear un nou usuari amb permisos de `sudo`](USUARI_SUDO.md)** 


## 2. Usuaris que es crean en la Demo i les seves credencials

Els usuaris de prova creats en el procÃ©s d'instalï¹žlaciÃ³ tenen les segÃ¼ents credencials:

| Rol | Usuaris |
| :--- | :--- |
| **Professors** | `M0 ,M5 ,T0 ,T1 ,T3` |
| **Tutors** | `M2 ,M3 ,M4 ,M7 ,T2 ,T4 ,T5` |
| **DirecciÃ³** | `M1 ,M6, T1` |
| **Alumnat rang** | `almn1 - almn229` |

**Notes Importants sobre la Demo**

- **Contrasenya Ãºnica**: Tots els usuaris de prova (Professors, Tutors, DirecciÃ³) utilitzen la contrasenya: **djAu**.
- ActualitzaciÃ³ de Dades: La base de dades de la Demo es refÃ  automÃ ticament a cada hora amb dades generades de manera aleatÃ²ria.
- Cookies: Aquest programari utilitza cookies estrictament per al manteniment de la sessiÃ³.


---

## 3. Instruccions d'InstalÂ·laciÃ³

Aquestes comandes es poden executar en un entorn Linux, preferiblement Debian 13 o Ubuntu Server 24.04 LTS o superior.

### 3.1 PreparaciÃ³ de l'Entorn

Cal instalÂ·lar les dependÃ¨ncies bÃ siques necessÃ ries del sistema:

```bash
sudo apt-get update
sudo apt-get install python3 python3-venv python3-dev git

# DependÃ¨ncies per a lxml (necessari per a l'anÃ lisi d'XML i HTML)
sudo apt-get install python3-lxml python3-libxml2 libxml2-dev libxslt-dev lib32z1-dev

# Llibreries grÃ fiques (necessÃ ries en alguns entorns de desenvolupament)
sudo apt-get install libgl1 libglib2.0-0t64
```

### 3.2 ClonaciÃ³ del repositorio i InstalÂ·laciÃ³ de l'AplicaciÃ³

```bash
# Crear un directori de treball i clonar el projecte
mkdir djau
cd djau
git clone --single-branch --branch master [https://github.com/ctrl-alt-d/django-aula.git](https://github.com/ctrl-alt-d/django-aula.git) django-aula
cd django-aula

# Crear i activar l'entorn virtual
python3 -m venv venv
source venv/bin/activate

# Instalï¹žlar les dependÃ¨ncies de Python
pip3 install -r requirements.txt
```

### 3.3 CreaciÃ³ de Dades i ExecuciÃ³

Un cop instalÂ·lat, executeu l'script que crea les dades de demostraciÃ³ (professors, alumnes, horaris) i inicia el servidor de desenvolupament incorporat:

```bash
# Crea un conjunt de dades fictÃ­cies per a la Demo
./scripts/create_demo_data.sh

# Inicia el servidor local de Django (mode desenvolupament)
python manage.py runserver
```
Un cop executat `python manage.py runserver` dins l'entorn virtual (venv) veurÃ­em quelcom similar a:

```text
(venv) djau@djau:~/djau/django-aula$ python manage.py runserver
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
octubre 30, 2025 - 02:27:21
Django version 5.1.13, using settings 'aula.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

### 3.4. AccÃ©s a la Demo amb Entorn GrÃ fic (MÃ quina Local)

COm hem vist amb la secciÃ³ anterior, quan s'executa la comanda `python manage.py runserver` l'aplicaciÃ³ es posa en marxa a l'adreÃ§a local del servidor: `http://127.0.0.1:8000`.

Si la Demo s'ha instalÂ·lat en un ordinador, o a una mÃ quina virtua, que disposa d'un **escriptori grÃ fic i un navegador web** podreu accedir-hi directament obrint el navegador i anant a:

**http://127.0.0.1:8000**

![PÃ gina principal servida en 127.0.0.1:8000](assets/demo/pagina_principal_demo.jpg)


## 4. Accedir des d'un altre ordinador a la mÃ quina on s'ha instalÂ·lat la Demo

Si intenteu accedir a la Demo des d'una mÃ quina on no s'hagi instalÂ·lat la Demo no podreu accedir amb la IP `127.0.0.1` 

La primera acciÃ³ Ã©s **canviar la forma d'executar el servior local** de desenvolupament

```bash
# ExecuciÃ³ del servidor amb accÃ©s extern
python manage.py runserver 0.0.0.0:8000
```
La sortida que veurem serÃ  similar a la vista anteriorment:

```text
(venv) djau@djau:~/djau/django-aula$ python manage.py runserver 0.0.0.0:8000
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
octubre 30, 2025 - 02:27:21
Django version 5.1.13, using settings 'aula.settings'
Starting development server at http://0.0.0.0:8000/
Quit the server with CONTROL-C.
```

Engegant el servidor local d'aquesta manera posibilita servir la Demo en qualsevol Ip que estigui configurada en la llista `ALLOWED_HOSTS`.

Per modificar aquesta llista **caldrÃ  accedir i editar l'arxiu `common.py`**, que es troba al directori `django-aula/aula/settings_dir`.

```bash
nano django-aula/aula/settings_dir/common.py
```

### 4.1 MÃ quina virtual creada amb VirtualBox i configurada amb xarxa NAT

Si utilitzeu una mÃ quina virtual amb configuraciÃ³ de xarxa **NAT**, heu de configurar una redirecciÃ³ de ports als parÃ metres de xarxa per tal que redirigeixi el trÃ nsit del *host* al *guest* (mÃ quina virtual):

#### 4.1.1 ConfiguraciÃ³ de RedirecciÃ³ de Ports de la mÃ quina virtual (Host)

| Camp | Valor |
| :--- | :--- |
| **Nom** | `http` |
| **IP Host** | `127.0.0.1` |
| **Port Host** | `8000` |
| **IP Guest** | `10.0.2.15` (TÃ­picament perÃ² cal comprobar-ho amb `ip a`) |
| **Port Guest** | `8000` |

![RedirecciÃ³ de ports a la configuraciÃ³ de xarxa de VirtualBox de la mÃ quina virtual (guest)](assets/demo/redicreccio_ports_vbox_nat.jpg)

#### 4.1.2 ModificaciÃ³ de la llista ALLOWED_HOSTS de la Demo

Per que la Demo respongui desprÃ©s de fer la redirecciÃ³ de ports als parÃ metres de la xarxa NAT de virtualBox, cal editar el fitxer de configuraciÃ³ de Django i afegir l'adreÃ§a IP des de la qual accedireu i que s'h definit en la redirecciÃ³ de ports:

**Modifiqueu la variable `ALLOWED_HOSTS`** dins l'arxiu `common.py`. 

Busqueu la lÃ­nia `ALLOWED_HOSTS = []` i afegiu l'adreÃ§a del host `ALLOWED_HOSTS = ['127.0.0.1']`

Obriu un navegador en la mÃ quina on s'ha instalÂ·lat VirtualBox i podreu escriure:  
**http://127.0.0.1:8000**


### 4.2 MÃ quina virtual creada amb VirtualBox i configurada amb xarxa BRIDGE (pont)

Si volem que la mÃ quina virtual tingui la seva prÃ²pia adreÃ§a IP, gestionada pel gestor DHCP de la xarxa interna local, podem seleccionar el parÃ metre `bridge` en comptes de `NAT`.

Si fem la comanda `IP a` obtindrem l'adreÃ§a IP de la mÃ quina virtual creada (guest).

```bash
djau@djau:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:20:10:17 brd ff:ff:ff:ff:ff:ff
    altname enx080027201017
    inet 192.168.18.163/24 brd 192.168.18.255 scope global dynamic noprefixroute enp0s3
       valid_lft 3371sec preferred_lft 2921sec
    inet6 fe80::350b:3ecd:ef4:a9b5/64 scope link dadfailed tentative
       valid_lft forever preferred_lft forever
``` 

**Modifiqueu la variable `ALLOWED_HOSTS`** dins l'arxiu `common.py`. 

Busqueu la lÃ­nia `ALLOWED_HOSTS = []` i afegiu l'adreÃ§a del host `ALLOWED_HOSTS = ['127.0.0.1', 'IP_DEL_GUEST']`  
En aquest cas d'exemple `ALLOWED_HOSTS = ['127.0.0.1', '192.168.18.163']`

Obriu un navegador en la mÃ quina (host) on s'ha instalÂ·lat VirtualBox i podreu escriure:  
**http://192.168.18.163:8000**

![AccÃ©s a la Demo dins la mÃ quina virtual (guest) amb IP privada gestionada dins la xarxa local interna](assets/demo/demo_vbox_bridge.jpg)

#### Opcional - Aconseguir una IP EstÃ tica

**AtenciÃ³: La IP de la mÃ quina virtual pot canviar quan s'apaga** i es torna a engegar perquÃ¨ l'IP de la maquina Demo l'otorga el sistema DHCP de la xarxa interna, que entrega adre?eces IP a les mÃ quines de forma variable, Ã©s a dir, no sempre pot tenir la mateixa IP.

**Per mantenir la IP de forma estÃ tica** les Ãºniques instruccions amb les que he tingut Ã¨xit sÃ³n les que trobareu al blog de [voidnull.es](https://voidnull.es/netplan-configura-tu-red-de-forma-sencilla-con-yaml/)  

Les passes a seguir sÃ³n les segÃ¼ents:

1 - InstalÂ·lar netplan
```bash
sudo apt install netplan.io
```
2 - Editar el arxiu de configuraciÃ³ en format yaml
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```
3 - Crear l'arxiu en format `yaml` amb la configuraciÃ³ per a la IP estÃ tica que es vol.  

A l'exemple segÃ¼ent es mostra l'adreÃ§a IP del meu Gateway (Router) i estic definint com IP estÃ tica aquella que en un principi el servidor DNS de la meva xarxa local ja havia assignat a la mÃ quina Demo.

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [192.168.18.163/24] # IP estÃ tica que es vol configurar i mÃ scara
      routes:
        - to: default
          via: 192.168.18.1        # Gateway (IP del router)
      nameservers:
        addresses: [192.168.18.1, 8.8.8.8]  # IPs de DNS
```

4 - Aplicar els permisos corresponents a l'arxiu yaml

```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
```

5 - Habilita i Inicia el gestor de xarxes de Netplan, el servei `systemd-networkd`, i aplica canvis. Es pot reiniciar tambÃ© el sistema i comprobar, amb `IP a`, que tenim l'adreÃ§a configurada o que en tenim una de nova si hem decidit canviar-la

```bash
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd
```
En aquest moment, si tenies una connexiÃ³ SSH oberta s'haurÃ  perdut sempre i quan s'hagi canviat l'IP que tenies, de forma automÃ tica, per una altra estÃ tica nova difererent de l'anterior.

Aplica la configuraciÃ³ de Netplan

```bash
sudo netplan apply
```

Ara ja tens l'IP estÃ tica. Pots comprovar-ho amb `ip a` i reiniciant la mÃ quina virtual Demo.


### 4.3 InstalÂ·laciÃ³ de la Demo en un servidor pÃºblic amb accÃ©s extern (VPS)

Tot servidor a internet tÃ© una IP pÃºblica i Ã©s convenient definir un domini o subdomini per accedir-hi. Consulteu el document [Registres DNS](REGISTRES_DNS.md) si no recordeu com fer-ho. En aquest cas, s'han creat dos subdominis que apunten a l'IP pÃºblica del servidor VPS:  
> demo.djau.domini.cat  
> www.demo.djau.domini.cat

A mÃ©s a mÃ©s ha calgut buscar entre les opcions del panel de control del proveÃ¯dor del VPS allÃ² que en diuen *PolÃ­tiques de Firewall* per tal d'obrir el port 8000, que Ã©s el port que obrirem amb el servidor web per a proves de Django.

El procÃ©s per instalÂ·lar la Demo Ã©s el definit a l'apartat 1.1 i 1.2 i a l'hora d'aixecar el servidor de proves, si volem anar sobre segur, hem fet servir  :
```bash
python manage.py runserver 0.0.0.0:8000
```

Ara bÃ©, hem hagut d'editar l'arxiu common.py: 
```bash
nano django-aula/aula/settings_dir/common.py
```
I modificar la llista ALLOWED_HOSTS, de tal manera que hem afegit els dos subdominis creats i, a mÃ©s a mÃ©s, l'IP pÃºblica del servidor VPS.

`ALLOWED_HOSTS = ['demo.djau.domini.cat', 'www.demo.djau.domini.cat', '127.0.0.1', 'IP_PÃºBLICA_VPS',]`

De fet, el servidor de proves de Django el podriem aixecar perfectament posant l'IP pÃºblica del VPS, en comptes de 0.0.0.0
```bash
python manage.py runserver IP_PÃºBLICA_VPS:8000
```

D'aquesta senzilla manera, sense haver d'instalÂ·lar un servidor web Apache com per la versiÃ³ de l'aplicatiu per producciÃ³, podem servir la versiÃ³ Demo de l'aplicatiu a tot aquell, des de qualsevol ordinador a internet, com funciona Django-Aula, simplement:

http://[IP_DEL_TEU_SERVIDOR]:8000  
http://[subdomini]:8000

![AccÃ©s a la Demo instalÂ·lada en un VPS pÃºblic amb subdomini](assets/demo/pagina_principal_demo_vps.jpg)


### 4.4 Resum de les modificacions de la llista *ALLOWED_HOSTS* de l'arxiu *common.py*

| Entorn | ConfiguraciÃ³ de `ALLOWED_HOSTS` |
| :--- | :--- |
| **MÃ quina Virtual (VirtualBox NAT)** | `ALLOWED_HOSTS = ['127.0.0.1']` |
| **Xarxa Interna Local** | `ALLOWED_HOSTS = ['127.0.0.1', 'IP_DEL_GUEST']` |
| **VPS (AccÃ©s per Domini)** | `ALLOWED_HOSTS = ['127.0.0.1', 'IP_PÃºBLICA_VPS', 'demo.djau.domini.cat', 'www.demo.djau.domini.cat',]` |


## 5 Mantenir l'execucÃ­Ã³ indefinida en el temps del servidor de DemostraciÃ³

Normalmente accedim a la mÃ quina on hem instalÂ·lat la Demo des d'un terminal de la nostra mÃ quina personal, amb Linux o Windows, mitjan?ant el protocol SSH.

Ara bÃ©, **quan tanquem la connexiÃ³ SSH el procÃ©s** que genera el servidor (*python manage.py runserver*) **tambÃ© es tanca**, deixant de funcionar, i **la Demo de Django-Aula ja no Ã©s accessible**.

---

**Instruccions per l'execucÃ­Ã³ indefinida en el temps del servidor de DemostraciÃ³**

Si es vol que la Demo estigui disponible el temps que necessitem, mentre no s'apagui fÃ­sicament el servidor que l'estÃ  executant, la manera d'executar *python manage.py runserver* canvia. Ara haurem d'engegar el servidor *runserver* de la segÃ¼ent manera:

```bash
nohup python -u manage.py runserver IP_PÃºBLICA_VPS:8000 &
```

* **nohup** desconnecta el procÃ©s de la sessiÃ³ ssh (encara que si fem *ctrl-c* el procÃ©s s'aturarÃ  igualment).
* **-u** indica a python que s'executi en mode sense memÃ²ria intermÃ¨dia per no perdre cap sortida del procÃ©s.
* odeu afegir **&** desprÃ©s de l'ordre per empÃ¨nyer el procÃ©s immediatament a segon pla i recuperar el shell, mantenint l'Ãºs de *ctrl-c*.

Per tancar el servidor *runserver* de python tenim dues opcions:
1. Es pot reiniciar el servidor
2. Es pot buscar l'ID del procÃ©s i detenir-lo.

Per explorar la segona opciÃ³ cal buscar l'identificador del procÃ©s i *matar-lo*. El procÃ©s seria el segÃ¼ent:

1 - Mostrar totes les ordres python en execuciÃ³:
```bash
ps aux | grep python
```
2 - Trobar l'ID del procÃ©s de l'ordre que es vol aturar i desprÃ©s aturar-lo:
```bash
kill <id>
```
on cal substituir <id> amb l'ID del procÃ©s obtinguda mitjanÃ§ant `ps aux`.