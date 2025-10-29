# 👥 Creació d'un Nou Usuari amb Permisos 'sudo'

Aquesta guia detalla el procediment per crear un nou usuari del sistema (no root) i assignar-li els permisos necessaris per executar tasques administratives (`sudo`).

**És una pràctica de seguretat fonamental utilitzar un usuari amb permisos limitats en lloc d'accedir directament amb 'root'.**

### 1. Requisits

* Accés al servidor mitjançant SSH amb l'usuari **`root`**.

### 2. Passos per a la Creació de l'Usuari 'djau'

Utilitzarem **`djau`** com a exemple del nom d'usuari per a l'aplicació.

| Pas | Comanda | Propòsit |
| :--- | :--- | :--- |
| **1. Crear l'usuari** | `useradd -m djau` | Crea l'usuari i el seu directori personal (`-m`) a `/home/djau`. |
| **2. Assignar contrasenya** | `passwd djau` | Defineix la contrasenya per al nou usuari. |
| **3. Afegir al grup `sudo`** | `usermod -aG sudo djau` | Afegeix l'usuari al grup `sudo`, atorgant-li privilegis administratius. |
| **4. Verificar permisos (Opcional)** | `id djau` | Confirma que el grup **`sudo`** apareix a la llista de grups de l'usuari. |

#### Exemple de Verificació

Si la comanda `id djau` s'ha executat correctament, la sortida ha d'incloure el grup `sudo`:

```bash
uid=1001(djau) gid=1001(djau) grups=1001(djau),27(sudo)
```

La presència del grup sudo (id 27 en aquest exemple) confirma que l'usuari djau pot executar comandes elevades.

#### Ús del Nou Usuari
Ara podeu sortir de la sessió de root i iniciar sessió directament amb el nou usuari (djau), que serà l'usuari amb el que fareu la instal·lació de l'aplicatiu Django-Aula.

Podeu provar d'executar una comanda amb privilegis administratius, simplement prefixeu-la amb sudo:

```bash
sudo apt update
```

A partir d'aquest moment podreu accedir al servidor mitjançant SSH amb l'usuari **`djau`**.