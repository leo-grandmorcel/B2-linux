# TP1 : (re)Familiaration avec un système GNU/Linux

## Sommaire

- [TP1 : (re)Familiaration avec un système GNU/Linux](#tp1--refamiliaration-avec-un-système-gnulinux)
  - [Sommaire](#sommaire)
  - [0. Préparation de la machine](#0-préparation-de-la-machine)
  - [I. Utilisateurs](#i-utilisateurs)
    - [1. Création et configuration](#1-création-et-configuration)
    - [2. SSH](#2-ssh)
  - [II. Partitionnement](#ii-partitionnement)
    - [1. Préparation de la VM](#1-préparation-de-la-vm)
    - [2. Partitionnement](#2-partitionnement)
  - [III. Gestion de services](#iii-gestion-de-services)
  - [1. Interaction avec un service existant](#1-interaction-avec-un-service-existant)
  - [2. Création de service](#2-création-de-service)
    - [A. Unité simpliste](#a-unité-simpliste)
    - [B. Modification de l'unité](#b-modification-de-lunité)

## 0. Préparation de la machine

🌞 **Setup de deux machines Rocky Linux configurées de façon basique.**

- **un accès internet (via la carte NAT)**

  - carte réseau dédiée
  - route par défaut
    ```
    [leo@node1 ~]$ ip route show
    default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
    ```
    ```
    [leo@node2 ~]$ ip route show
    default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
    ```

- **un accès à un réseau local** (les deux machines peuvent se `ping`) (via la carte Host-Only)

  - carte réseau dédiée (host-only sur VirtualBox)
  - les machines doivent posséder une IP statique sur l'interface host-only

    ```
    [leo@node1 ~]$ cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
    NAME=enp0s8
    DEVICE=enp0s8
    BOOTPROTO=static
    ONBOOT=yes
    IPADDR=10.101.1.11
    NETMASK=255.255.255.0
    DNS1=1.1.1.1
    ```

    ```
    [leo@node1 ~]$ ping -I enp0s8 -c 2 10.101.1.12
    PING 10.101.1.12 (10.101.1.12) from 10.101.1.11 enp0s8: 56(84) bytes of data.
    64 bytes from 10.101.1.12: icmp_seq=1 ttl=64 time=0.559 ms
    64 bytes from 10.101.1.12: icmp_seq=2 ttl=64 time=0.468 ms
    --- 10.101.1.12 ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1021ms
    rtt min/avg/max/mdev = 0.468/0.513/0.559/0.045 ms
    ```

- **vous n'utilisez QUE `ssh` pour administrer les machines**

  ```
    [leo@node1 ~]$ systemctl status sshd
  ● sshd.service - OpenSSH server daemon
      Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
      Active: active (running) since Mon 2022-11-14 16:06:18 CET; 7min ago
        Docs: man:sshd(8)
              man:sshd_config(5)
    Main PID: 688 (sshd)
        Tasks: 1 (limit: 11120)
      Memory: 7.1M
          CPU: 62ms
      CGroup: /system.slice/sshd.service
              └─688 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

  Nov 14 16:06:18 node1.tp1.b2 systemd[1]: Starting OpenSSH server daemon...
  Nov 14 16:06:18 node1.tp1.b2 sshd[688]: Server listening on 0.0.0.0 port 22.
  Nov 14 16:06:18 node1.tp1.b2 sshd[688]: Server listening on :: port 22.
  Nov 14 16:06:18 node1.tp1.b2 systemd[1]: Started OpenSSH server daemon.
  Nov 14 16:06:33 node1.tp1.b2 sshd[1147]: Accepted password for leo from 10.101.1.1 port 5958
  ```

- **les machines doivent avoir un nom**

  ```
  [leo@node1 ~]$ hostname
  node1.tp1.b2
  [leo@node1 ~]$ cat /etc/hostname
  node1.tp1.b2
  ```

  ```
  [leo@node2 ~]$ hostname
  node2.tp1.b2
  [leo@node2 ~]$ cat /etc/hostname
  node2.tp1.b2
  ```

- **utiliser `1.1.1.1` comme serveur DNS**

  - référez-vous au mémo
    ```
    [leo@node1 ~]$ cat /etc/resolv.conf
    search tp1.b2
    nameserver 1.1.1.1
    ```
  - vérifier avec le bon fonctionnement avec la commande `dig`

    - avec `dig`, demander une résolution du nom `ynov.com`

      ```
      [leo@node1 ~]$ dig ynov.com
      ; <<>> DiG 9.16.23-RH <<>> ynov.com
      ;; global options: +cmd
      ;; Got answer:
      ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43486
      ;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

      ;; OPT PSEUDOSECTION:
      ; EDNS: version: 0, flags:; udp: 1232
      ;; QUESTION SECTION:
      ;ynov.com. IN A

      ;; ANSWER SECTION:
      ynov.com. 300 IN A 104.26.11.233
      ynov.com. 300 IN A 172.67.74.226
      ynov.com. 300 IN A 104.26.10.233

      ;; Query time: 46 msec
      ;; SERVER: 1.1.1.1#53(1.1.1.1)
      ;; WHEN: Mon Nov 14 16:22:35 CET 2022
      ;; MSG SIZE rcvd: 85
      ```

    - mettre en évidence la ligne qui contient la réponse : l'IP qui correspond au nom demandé
      ```
      ynov.com. 300 IN A 104.26.11.233
      ynov.com. 300 IN A 172.67.74.226
      ynov.com. 300 IN A 104.26.10.233
      ```
    - mettre en évidence la ligne qui contient l'adresse IP du serveur qui vous a répondu
      ```
      SERVER: 1.1.1.1#53(1.1.1.1)
      ```

- **les machines doivent pouvoir se joindre par leurs noms respectifs**

  - fichier `/etc/hosts`
    ```
    [leo@node1 ~]$ cat /etc/hosts | tail -n 1
    10.101.1.12 node2.tp1.b2 node2
    ```
  - assurez-vous du bon fonctionnement avec des `ping <NOM>`

    ```
    [leo@node1 ~]$ ping node2 -c 2
    PING node2.tp1.b2 (10.101.1.12) 56(84) bytes of data.
    64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=1 ttl=64 time=0.510 ms
    64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=2 ttl=64 time=0.855 ms

    --- node2.tp1.b2 ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1018ms
    rtt min/avg/max/mdev = 0.510/0.682/0.855/0.172 ms
    ```

- **le pare-feu est configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires**
  - commande `firewall-cmd`
    ```
    [leo@node1 ~]$ sudo firewall-cmd --remove-service cockpit --permanent
    success
    [leo@node1 ~]$ sudo firewall-cmd --remove-service dhcpv6-client --permanent
    success
    ```
    ```
    [leo@node1 ~]$ sudo firewall-cmd --list-all
    public (active)
    target: default
    icmp-block-inversion: no
    interfaces: enp0s3 enp0s8
    sources:
    services: ssh
    ports:
    protocols:
    forward: yes
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
    ```

## I. Utilisateurs

### 1. Création et configuration

🌞 **Ajouter un utilisateur à la machine**, qui sera dédié à son administration

- précisez des options sur la commande d'ajout pour que :
  - le répertoire home de l'utilisateur soit précisé explicitement, et se trouve dans `/home`
  - le shell de l'utilisateur soit `/bin/bash`
  ```
  [leo@node1 ~]$ sudo useradd superuser -m -s /bin/bash
  [leo@node1 ~]$ sudo passwd superuser
  ```
- prouvez que vous avez correctement créé cet utilisateur
  - et aussi qu'il a le bon shell et le bon homedir
  ```
  [leo@node1 ~]$ cat /etc/passwd | tail -n 1
  superuser:x:1001:1001::/home/superuser:/bin/bash
  ```

🌞 **Créer un nouveau groupe `admins`** qui contiendra les utilisateurs de la machine ayant accès aux droits de `root` _via_ la commande `sudo`.

```
[leo@node1 ~]$ sudo groupadd admins
```

Pour permettre à ce groupe d'accéder aux droits `root` :

- il faut modifier le fichier `/etc/sudoers`
- on ne le modifie jamais directement à la main car en cas d'erreur de syntaxe, on pourrait bloquer notre accès aux droits administrateur
- la commande `visudo` permet d'éditer le fichier, avec un check de syntaxe avant fermeture
- ajouter une ligne basique qui permet au groupe d'avoir tous les droits (inspirez vous de la ligne avec le groupe `wheel`)

```
[leo@node1 ~]$ sudo cat /etc/sudoers | grep admins
%admins ALL=(ALL)       ALL
```

🌞 **Ajouter votre utilisateur à ce groupe `admins`**

```
[leo@node1 ~]$ sudo usermod -aG admins superuser
[leo@node1 ~]$ cat /etc/group |tail -n 1
admins:x:1002:superuser
```

> Essayez d'effectuer une commande avec `sudo` peu importe laquelle, juste pour tester que vous avez le droit d'exécuter des commandes sous l'identité de `root`. Vous pouvez aussi utiliser `sudo -l` pour voir les droits `sudo` auquel votre utilisateur courant a accès.

```
[leo@node1 ~]$ su - superuser
[superuser@node1 ~]$ sudo -l | tail -n 2
User superuser may run the following commands on node1:
    (ALL) ALL
```

### 2. SSH

🌞 **Pour cela...**

- il faut générer une clé sur le poste client de l'administrateur qui se connectera à distance (vous :) )
  - génération de clé depuis VOTRE poste donc
  - sur Windows, on peut le faire avec le programme `puttygen.exe` qui est livré avec `putty.exe`
- déposer la clé dans le fichier `/home/<USER>/.ssh/authorized_keys` de la machine que l'on souhaite administrer
  - vous utiliserez l'utilisateur que vous avez créé dans la partie précédente du TP
  - on peut le faire à la main
  - ou avec la commande `ssh-copy-id`
  ```
   C:\Users\lgran> ssh-keygen -t rsa -b 4096
  Generating public/private rsa key pair.
  Enter file in which to save the key (C:\Users\lgran/.ssh/id_rsa):
  Enter passphrase (empty for no passphrase):
  Enter same passphrase again:
  Your identification has been saved in C:\Users\lgran/.ssh/id_rsa.
  Your public key has been saved in C:\Users\lgran/.ssh/id_rsa.pub.
  ```
  ```
  [superuser@node1 ~]$ cat .ssh/authorized_keys
  ssh-rsa [BLABLA je sais que c'est une clé publique mais je l'enlève quand même]
  ```

🌞 **Assurez vous que la connexion SSH est fonctionnelle**, sans avoir besoin de mot de passe.

```
PS C:\Users\lgran> ssh node1
Last login: Mon Nov 14 17:33:15 2022 from 10.101.1.1
[superuser@node1 ~]$ e
```

## II. Partitionnement

[Il existe une section dédiée au partitionnement dans le cours](../../cours/part/)

### 1. Préparation de la VM

⚠️ **Uniquement sur `node1.tp1.b2`.**

Ajout de deux disques durs à la machine virtuelle, de 3Go chacun.

### 2. Partitionnement

⚠️ **Uniquement sur `node1.tp1.b2`.**

🌞 **Utilisez LVM**

- agréger les deux disques en un seul _volume group_
  ```
  [superuser@node1 ~]$ sudo pvcreate /dev/sdb
    Physical volume "/dev/sdb" successfully created.
  [superuser@node1 ~]$ sudo pvcreate /dev/sdc
    Physical volume "/dev/sdc" successfully created.
  [superuser@node1 ~]$ sudo pvs
    PV         VG Fmt  Attr PSize PFree
    /dev/sdb      lvm2 ---  3.00g 3.00g
    /dev/sdc      lvm2 ---  3.00g 3.00g
  [superuser@node1 ~]$ sudo vgcreate grosdisque /dev/sdb
    Volume group "grosdisque" successfully created
  [superuser@node1 ~]$ sudo vgextend grosdisque /dev/sdc
    Volume group "grosdisque" successfully extended
  [superuser@node1 ~]$ sudo vgs
    VG         #PV #LV #SN Attr   VSize VFree
    grosdisque   2   0   0 wz--n- 5.99g 5.99g
  ```
- créer 3 _logical volumes_ de 1 Go chacun
  ```
  [superuser@node1 ~]$ sudo lvcreate -L 1G grosdisque -n ma_data_frere
  Logical volume "ma_data_frere" created.
  [superuser@node1 ~]$ sudo lvcreate -L 1G grosdisque -n ta_data_frere
    Logical volume "ta_data_frere" created.
  [superuser@node1 ~]$ sudo lvcreate -L 1G grosdisque -n sa_data_frere
    Logical volume "sa_data_frere" created.
  [superuser@node1 ~]$ sudo lvs
    LV            VG         Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
    ma_data_frere grosdisque -wi-a----- 1.00g
    sa_data_frere grosdisque -wi-a----- 1.00g
    ta_data_frere grosdisque -wi-a----- 1.00g
  ```
- formater ces partitions en `ext4`

  ```
  [superuser@node1 ~]$ sudo mkfs -t ext4 /dev/grosdisque/ma_data_frere
  mke2fs 1.46.5 (30-Dec-2021)
  Creating filesystem with 262144 4k blocks and 65536 inodes
  Filesystem UUID: fdd2defd-677a-4792-9573-2610c1abdd7f
  Superblock backups stored on blocks:
          32768, 98304, 163840, 229376

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (8192 blocks): done
  Writing superblocks and filesystem accounting information: done

  [superuser@node1 ~]$ sudo mkfs -t ext4 /dev/grosdisque/ta_data_frere
  mke2fs 1.46.5 (30-Dec-2021)
  Creating filesystem with 262144 4k blocks and 65536 inodes
  Filesystem UUID: 0b0afb78-c5f0-40b9-912e-6a48ee5fc2ac
  Superblock backups stored on blocks:
          32768, 98304, 163840, 229376

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (8192 blocks): done
  Writing superblocks and filesystem accounting information: done

  [superuser@node1 ~]$ sudo mkfs -t ext4 /dev/grosdisque/sa_data_frere
  mke2fs 1.46.5 (30-Dec-2021)
  Creating filesystem with 262144 4k blocks and 65536 inodes
  Filesystem UUID: 779f77e6-7180-45c5-9ddb-34b4a591e00f
  Superblock backups stored on blocks:
          32768, 98304, 163840, 229376

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (8192 blocks): done
  Writing superblocks and filesystem accounting information: done
  ```

- monter ces partitions pour qu'elles soient accessibles aux points de montage `/mnt/part1`, `/mnt/part2` et `/mnt/part3`.
  ```
  [superuser@node1 ~]$ sudo mkdir /mnt/part1
  [superuser@node1 ~]$ sudo mkdir /mnt/part2
  [superuser@node1 ~]$ sudo mkdir /mnt/part3
  [superuser@node1 ~]$ sudo mount /dev/grosdisque/ma_data_frer /mnt/part1
  [superuser@node1 ~]$ sudo mount /dev/grosdisque/ma_data_frere /mnt/part1
  [superuser@node1 ~]$ sudo mount /dev/grosdisque/ta_data_frere /mnt/part2
  [superuser@node1 ~]$ sudo mount /dev/grosdisque/sa_data_frere /mnt/part3
  [superuser@node1 ~]$ mount | tail -n 3
  /dev/mapper/grosdisque-ma_data_frere on /mnt/part1 type ext4 (rw,relatime,seclabel)
  /dev/mapper/grosdisque-ta_data_frere on /mnt/part2 type ext4 (rw,relatime,seclabel)
  /dev/mapper/grosdisque-sa_data_frere on /mnt/part3 type ext4 (rw,relatime,seclabel)
  ```

🌞 **Grâce au fichier `/etc/fstab`**, faites en sorte que cette partition soit montée automatiquement au démarrage du système.

```
[superuser@node1 ~]$ cat /etc/fstab | tail -n 3
/dev/grosdisque/ma_data_frere /mnt/part1 ext4 defaults 0 0
/dev/grosdisque/ta_data_frere /mnt/part2 ext4 defaults 0 0
/dev/grosdisque/sa_data_frere /mnt/part3 ext4 defaults 0 0
```

## III. Gestion de services

Au sein des systèmes GNU/Linux les plus utilisés, c'est _systemd_ qui est utilisé comme gestionnaire de services (entre autres).

Pour manipuler les services entretenus par _systemd_, on utilise la commande `systemctl`.

On peut lister les unités `systemd` actives de la machine `systemctl list-units -t service`.

**Référez-vous au mémo pour voir les autres commandes `systemctl` usuelles.**

## 1. Interaction avec un service existant

⚠️ **Uniquement sur `node1.tp1.b2`.**

Parmi les services système déjà installés sur Rocky, il existe `firewalld`. Cet utilitaire est l'outil de firewalling de Rocky.

🌞 **Assurez-vous que...**

- l'unité est démarrée
  ```
  [superuser@node1 ~]$ sudo systemctl is-active firewalld
  active
  ```
- l'unitée est activée (elle se lance automatiquement au démarrage)
  ```
  [superuser@node1 ~]$ sudo systemctl is-enabled firewalld
  enabled
  ```

## 2. Création de service

### A. Unité simpliste

⚠️ **Uniquement sur `node1.tp1.b2`.**

🌞 **Créer un fichier qui définit une unité de service**

- le fichier `web.service`
- dans le répertoire `/etc/systemd/system`

  ```
  [superuser@node1 ~]$ cat /etc/systemd/system/web.service
  [Unit]
  Description=Very simple web service

  [Service]
  ExecStart=/usr/bin/python3 -m http.server 8888

  [Install]
  WantedBy=multi-user.target
  ```

🌞 **Une fois le service démarré, assurez-vous que pouvez accéder au serveur web**

- avec un navigateur depuis votre PC
  ```
  C:\Users\lgran> curl 10.101.1.11:8888
  StatusCode        : 200
  StatusDescription : OK
  Content           : <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
                      <html>
                      <head>
                      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                      <title>Directory listing fo...
  [...]
  ```
- ou la commande `curl` depuis l'autre machine (je veux ça dans le compte-rendu :3)
  ```
  [superuser@node2 ~]$ curl 10.101.1.11:8888
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>Directory listing for /</title>
  </head>
  <body>
  <h1>Directory listing for /</h1>
  <hr>
  <ul>
  <li><a href="afs/">afs/</a></li>
  <li><a href="bin/">bin@</a></li>
  <li><a href="boot/">boot/</a></li>
  <li><a href="dev/">dev/</a></li>
  <li><a href="etc/">etc/</a></li>
  <li><a href="home/">home/</a></li>
  <li><a href="lib/">lib@</a></li>
  <li><a href="lib64/">lib64@</a></li>
  <li><a href="media/">media/</a></li>
  <li><a href="mnt/">mnt/</a></li>
  <li><a href="opt/">opt/</a></li>
  <li><a href="proc/">proc/</a></li>
  <li><a href="root/">root/</a></li>
  <li><a href="run/">run/</a></li>
  <li><a href="sbin/">sbin@</a></li>
  <li><a href="srv/">srv/</a></li>
  <li><a href="sys/">sys/</a></li>
  <li><a href="tmp/">tmp/</a></li>
  <li><a href="usr/">usr/</a></li>
  <li><a href="var/">var/</a></li>
  </ul>
  <hr>
  </body>
  </html>
  ```

### B. Modification de l'unité

🌞 **Préparez l'environnement pour exécuter le mini serveur web Python**

- créer un utilisateur `web`
  ```
  [superuser@node1 ~]$ sudo useradd web
  [superuser@node1 ~]$ sudo passwd web
  Changing password for user web.
  ```
- créer un dossier `/var/www/meow/`
  ```
  [superuser@node1 ~]$ sudo mkdir /var/www
  [superuser@node1 ~]$ sudo mkdir /var/www/meow/
  [superuser@node1 ~]$ sudo chown web /var/www/meow/
  [superuser@node1 ~]$ sudo chgrp web /var/www/meow/
  ```
- créer un fichier dans le dossier `/var/www/meow/` (peu importe son nom ou son contenu, c'est pour tester)
  ```
  [superuser@node1 ~]$ su - web
  [web@node1 ~]$ nano /var/www/meow/bonjour.txt
  ```
- montrez à l'aide d'une commande les permissions positionnées sur le dossier et son contenu

  ```
  [superuser@node1 ~]$ ls -Rl /var/www/
  /var/www/:
  total 0
  drwxr-xr-x. 2 web web 25 Nov 14 23:42 meow

  /var/www/meow:
  total 4
  -rw-r--r--. 1 web web 8 Nov 14 23:42 bonjour.txt
  ```

> Pour que tout fonctionne correctement, il faudra veiller à ce que le dossier et le fichier appartiennent à l'utilisateur `web` et qu'il ait des droits suffisants dessus.

🌞 **Modifiez l'unité de service `web.service` créée précédemment en ajoutant les clauses**

- `User=` afin de lancer le serveur avec l'utilisateur `web` dédié
- `WorkingDirectory=` afin de lancer le serveur depuis le dossier créé au dessus : `/var/www/meow/`
- ces deux clauses sont à positionner dans la section `[Service]` de votre unité

  ```
  [superuser@node1 ~]$ cat /etc/systemd/system/web.service
  [Unit]
  Description=Very simple web service

  [Service]
  User=web
  WorkingDirectory=/var/www/meow/
  ExecStart=/usr/bin/python3 -m http.server 8888

  [Install]
  WantedBy=multi-user.target
  [superuser@node1 ~]$ sudo systemctl daemon-reload
  [superuser@node1 ~]$ sudo systemctl restart web
  [superuser@node1 ~]$ sudo systemctl is-active web
  active
  ```

🌞 **Vérifiez le bon fonctionnement avec une commande `curl`**

```
[superuser@node2 ~]$ curl node1:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bonjour.txt">bonjour.txt</a></li>
</ul>
<hr>
</body>
</html>
```
