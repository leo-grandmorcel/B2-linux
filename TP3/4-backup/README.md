# Module 4 : Sauvegarde du système de fichiers

## Sommaire

- [Module 4 : Sauvegarde du système de fichiers](#module-4--sauvegarde-du-système-de-fichiers)
  - [Sommaire](#sommaire)
  - [I. Script de backup](#i-script-de-backup)
    - [1. Ecriture du script](#1-ecriture-du-script)
    - [2. Service et timer](#2-service-et-timer)
  - [II. NFS](#ii-nfs)
    - [1. Serveur NFS](#1-serveur-nfs)
    - [2. Client NFS](#2-client-nfs)

## I. Script de backup

### 1. Ecriture du script

➜ **Ecrire le script `bash`**

➜ **Utiliser des variables**

➜ **Commentez le script**

**[tp3_backup.sh](./tp3_backup.sh)**

➜ **Environnement d'exécution du script**

```
[leo@web ~]$ sudo useradd -d /srv/backup/ -s /usr/bin/nologin backup
useradd: Warning: missing or non-executable shell '/usr/bin/nologin'
[leo@web ~]$ sudo chown backup:backup /srv/tp3_backup.sh
[leo@web ~]$ sudo chmod 700 /srv/tp3_backup.sh
[leo@web ~]$ sudo usermod -aG apache backup
```

### 2. Service et timer

➜ **Créez un _service_**
**[backup.service](./backup.service)**

```
[leo@web ~]$ sudo systemctl status backup
○ backup.service - Start tp3_backup.sh to archive config, themes and data folders
     Loaded: loaded (/etc/systemd/system/backup.service; disabled; vendor preset: disabled)
     Active: inactive (dead)
[leo@web ~]$ sudo systemctl start backup
[leo@web ~]$ sudo ls /srv/backup/
nextcloud_221119_191145.tar.gz
```

➜ **Créez un _timer_**
**[backup.timer](./backup.timer)**

```
[leo@web ~]$ sudo systemctl daemon-reload
[leo@web ~]$ sudo systemctl start backup.timerd
[leo@web ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[leo@web ~]$ sudo systemctl status backup.timer
● backup.timer - Run backup.service once a day
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: disabled)
     Active: active (waiting) since Sat 2022-11-19 19:49:03 CET; 9s ago
      Until: Sat 2022-11-19 19:49:03 CET; 9s ago
    Trigger: Sun 2022-11-20 04:00:00 CET; 8h left
   Triggers: ● backup.service

Nov 19 19:49:03 web.tp2.linux systemd[1]: Started Run backup.service once a day.
```

## II. NFS

### 1. Serveur NFS

➜ **Préparer un dossier à partager**

```
[leo@storage ~]$ sudo mkdir /srv/nfs_shares
[leo@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp2.linux
[leo@storage ~]$ sudo mkdir /srv/nfs_shares/db.tp3.linux
```

➜ **Installer le serveur NFS**

```
[leo@storage ~]$ sudo dnf install -y nfs-utils
Installing:
 nfs-utils                          x86_64                     1:2.5.4-10.el9                       baseos                     422 k
[leo@storage ~]$ sudo nano /etc/exports
[leo@storage ~]$ cat /etc/exports
/srv/nfs_shares/web.tp2.linux/    10.102.1.11(rw,sync,no_root_squash,no_subtree_check)
/srv/nfs_shares/db.tp3.linux/    10.102.1.12(rw,sync,no_root_squash,no_subtree_check)
leo@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[leo@storage ~]$ sudo systemctl start nfs-server
[leo@storage ~]$ sudo firewall-cmd --add-port=2049/tcp --permanent
success
[leo@storage ~]$ sudo firewall-cmd --reload
success
```

### 2. Client NFS

➜ **Installer un client NFS sur `web.tp2.linux`**

```
[leo@web ~]$ sudo dnf install -y nfs-utils
[leo@db srv]$ sudo mount -t nfs 10.102.1.15:/srv/nfs_shares/web.tp2.linux/ /srv/backup/
[leo@web ~]$ df -h | tail -n 1
10.102.1.15:/srv/nfs_shares/web.tp2.linux  6.2G  1.2G  5.1G  20% /srv/backup
[leo@web ~]$ cat /etc/fstab | tail -n 1
10.102.1.15:/srv/nfs_shares/web.tp2.linux/ /srv/backup nfs defaults 0 0
```

➜ **Installer un client NFS sur `db.tp3.linux`**

```
[leo@db srv]$ sudo dnf install -y nfs-utils
[leo@db srv]$ sudo mount -t nfs 10.102.1.15:/srv/nfs_shares/db.tp3.linux/ /srv/db_dumps/
[sudo] password for leo:
[leo@db srv]$ df -h | tail -n 1
10.102.1.15:/srv/nfs_shares/db.tp3.linux  6.2G  1.2G  5.1G  20% /srv/db_dumps
[leo@storage ~]$ cat /etc/fstab | tail -n 1
10.102.1.15:/srv/nfs_shares/db.tp3.linux/ /srv/db_dumps nfs defaults 0 0
```

➜ **Tester la restauration des données**

```
[leo@web srv]$ sudo ls -l /srv/backup/
total 0
[leo@web srv]$ sudo -u backup ./tp3_backup.sh
[leo@web srv]$ sudo ls /srv/backup/
nextcloud_221119_201156.tar.gz
```

```
[leo@db srv]$ sudo ls -l db_dumps/
total 0
[leo@db srv]$ sudo -u dumper ./tp3_db_dump.sh
[leo@db srv]$ sudo ls db_dumps/
db_nextcloud_221119_201117.tar.gz
```

```
[leo@storage ~]$ sudo tree /srv/nfs_shares/
/srv/nfs_shares/
├── db.tp3.linux
│   └── db_nextcloud_221119_201117.tar.gz
└── web.tp2.linux
    └── nextcloud_221119_201156.tar.gz

2 directories, 2 files
```
