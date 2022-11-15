# TP2 : Gestion de service

# Sommaire

- [TP2 : Gestion de service](#tp2--gestion-de-service)
- [Sommaire](#sommaire)
- [I. Un premier serveur web](#i-un-premier-serveur-web)
  - [A. Installation](#a-installation)
  - [B. Avancer vers la maîtrise du service](#b-avancer-vers-la-maîtrise-du-service)
- [II. Une stack web plus avancée](#ii-une-stack-web-plus-avancée)
  - [A. Base de données](#a-base-de-données)
  - [B. Serveur Web et NextCloud](#b-serveur-web-et-nextcloud)
  - [C. Finaliser l'installation de NextCloud](#c-finaliser-linstallation-de-nextcloud)

# I. Un premier serveur web

## A. Installation

🖥️ **VM web.tp2.linux**

| Machine         | IP            | Service     |
| --------------- | ------------- | ----------- |
| `web.tp2.linux` | `10.102.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

```
[leo@web ~]$ sudo dnf install httpd -y
Installing:
 httpd                      x86_64          2.4.51-7.el9_0          appstream          1.4 M
[...]
Complete!
```

🌞 **Démarrer le service Apache**

```
[leo@web ~]$ sudo systemctl start httpd
[leo@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[leo@web ~]$ sudo ss -ltpn | tail -n 1
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=1548,fd=4),("httpd",pid=1547,fd=4),("httpd",pid=1546,fd=4),("httpd",pid=1544,fd=4))
[leo@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[leo@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **TEST**

- vérifier que le service est démarré
  ```
  [leo@web ~]$ systemctl is-active httpd
  active
  ```
- vérifier qu'il est configuré pour démarrer automatiquement
  ```
  [leo@web ~]$ systemctl is-enabled httpd
  enabled
  ```
- vérifier avec une commande `curl localhost` que vous joignez votre serveur web localement
  ```
  [leo@web ~]$ curl localhost
  <!doctype html>
  <html>
  [...]
  </html>
  ```
- vérifier avec votre navigateur (sur votre PC) que vous accéder à votre serveur web
  ```
  PS C:\Users\lgran> curl 10.102.1.11
  curl : HTTP Server Test Page
  [...]
  ```

## B. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[leo@web ~]$ cat /etc/systemd/system/multi-user.target.wants/httpd.service
[...]
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[leo@web ~]$ cat /etc/httpd/conf/httpd.conf | grep User | head -n 1
User apache

[leo@web ~]$ ps -ef | grep httpd
root        1826       1  0 14:31 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1827    1826  0 14:31 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1828    1826  0 14:31 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1829    1826  0 14:31 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1830    1826  0 14:31 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      2072    1826  0 14:35 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

```
[leo@web ~]$ ls -l /usr/share/testpage/
total 8
-rw-r--r--. 1 root root 7620 Jul  6 04:37 index.html
```

Lisible pour tous le monde, par rapport au dernier r.

🌞 **Changer l'utilisateur utilisé par Apache**

```
[leo@web ~]$ sudo useradd BetterApache -d /usr/share/httpd -s /sbin/nologin
[leo@web ~]$ cat /etc/httpd/conf/httpd.conf | grep User | head -n 1
User BetterApache
[leo@web ~]$ sudo systemctl restart httpd
[leo@web ~]$ ps -ef | grep httpd
root        2212       1  0 14:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
BetterA+    2213    2212  0 14:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
BetterA+    2214    2212  0 14:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
BetterA+    2215    2212  0 14:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
BetterA+    2216    2212  0 14:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```
[leo@web ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 8888
[leo@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[leo@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[leo@web ~]$ sudo firewall-cmd --reload
success
[leo@web ~]$ sudo systemctl restart httpd
[leo@web ~]$ systemctl is-active httpd
active
```

- Prouvez avec une commande `ss` que Apache tourne bien sur le nouveau port choisi
  ```
  [leo@web ~]$ sudo ss -ltpn | grep httpd
  LISTEN 0      511                *:8888            *:*    users:(("httpd",pid=2470,fd=4),("httpd",pid=2469,fd=4),("httpd",pid=2468,fd=4),("httpd",pid=2466,fd=4))
  ```
- vérifiez avec `curl` en local que vous pouvez joindre Apache sur le nouveau port
  ```
  [leo@web ~]$ curl localhost:8888
  <!doctype html>
  <html>
  [...]
  </html>
  ```
- vérifiez avec votre navigateur que vous pouvez joindre le serveur sur le nouveau port
  ```
  PS C:\Users\lgran> curl 10.102.1.11:8888
  curl : HTTP Server Test Page
  [...]
  ```

📁 **[Fichier `/etc/httpd/conf/httpd.conf`](httpd.conf)**

# II. Une stack web plus avancée

## A. Base de données

🌞 **Install de MariaDB sur `db.tp2.linux`**

- déroulez [la doc d'install de Rocky](https://docs.rockylinux.org/guides/database/database_mariadb-server/)

  ```
  [leo@db ~]$ sudo dnf install mariadb-server -y
  [sudo] password for leo:
  Last metadata expiration check: 1:06:57 ago on Tue 15 Nov 2022 02:07:56 PM CET.
  Dependencies resolved.
  ============================================================================================= Package                           Arch        Version                  Repository      Size
  =============================================================================================Installing:
  mariadb-server                    x86_64      3:10.5.16-2.el9_0        appstream      9.4 M
  [...]
  Complete!
  [leo@db ~]$ sudo systemctl enable mariadb
  Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
  Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
  Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
  [leo@db ~]$ sudo systemctl start mariadb
  [leo@db ~]$ systemctl is-active mariadb
  active
  [leo@db ~]$ sudo mysql_secure_installation
  Enter current password for root (enter for none):
  OK, successfully used password, moving on...

  Setting the root password or using the unix_socket ensures that nobody
  can log into the MariaDB root user without the proper authorisation.

  You already have your root account protected, so you can safely answer 'n'.

  Switch to unix_socket authentication [Y/n] n
  ... skipping.

  You already have your root account protected, so you can safely answer 'n'.

  Change the root password? [Y/n] n
  ... skipping.

  By default, a MariaDB installation has an anonymous user, allowing anyone
  to log into MariaDB without having to have a user account created for
  them.  This is intended only for testing, and to make the installation
  go a bit smoother.  You should remove them before moving into a
  production environment.

  Remove anonymous users? [Y/n] Y
  ... Success!

  Normally, root should only be allowed to connect from 'localhost'.  This
  ensures that someone cannot guess at the root password from the network.

  Disallow root login remotely? [Y/n]
  ... Success!

  By default, MariaDB comes with a database named 'test' that anyone can
  access.  This is also intended only for testing, and should be removed
  before moving into a production environment.

  Remove test database and access to it? [Y/n]
  - Dropping test database...
  ... Success!
  - Removing privileges on test database...
  ... Success!

  Reloading the privilege tables will ensure that all changes made so far
  will take effect immediately.

  Reload privilege tables now? [Y/n]
  ... Success!

  Cleaning up...

  All done!  If you've completed all of the above steps, your MariaDB
  installation should now be secure.

  Thanks for using MariaDB!
  ```

- vous repérerez le port utilisé par MariaDB avec une commande `ss` exécutée sur `db.tp2.linux`
  ```
  [leo@db ~]$ sudo ss -ltpn | grep mariadb
  LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=3467,fd=15))
  [leo@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
  success
  [leo@db ~]$ sudo firewall-cmd --reload
  success
  ```

🌞 **Préparation de la base pour NextCloud**

- une fois en place, il va falloir préparer une base de données pour NextCloud :

  - connectez-vous à la base de données à l'aide de la commande `sudo mysql -u root -p`

    ```
    [leo@db ~]$ sudo mysql -u root -p
    Enter password:
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 16
    Server version: 10.5.16-MariaDB MariaDB Server

    Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    ```

  - exécutez les commandes SQL suivantes :

    ```
    MariaDB [(none)]> CREATE USER 'nextcloud'@'10.102.1.11' IDENTIFIED BY 'meow';
    Query OK, 0 rows affected (0.013 sec)

    MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    Query OK, 1 row affected (0.000 sec)

    MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.102.1.11';
    Query OK, 0 rows affected (0.012 sec)

    MariaDB [(none)]> FLUSH PRIVILEGES;
    Query OK, 0 rows affected (0.001 sec)
    ```

🌞 **Exploration de la base de données**

```
[leo@web ~]$ dnf provides mysql
[...]
Provide    : mysql = 8.0.30-3.el9_0
[leo@web ~]$ sudo dnf install mysql -y
Last metadata expiration check: 0:24:04 ago on Tue 15 Nov 2022 03:05:12 PM CET.
Dependencies resolved.
=============================================================================================
Package                          Architecture Version                 Repository       Size
=============================================================================================
Installing:
mysql                            x86_64       8.0.30-3.el9_0          appstream       2.8 M
Installing dependencies:
mariadb-connector-c-config       noarch       3.2.6-1.el9_0           appstream       9.8 k
mysql-common                     x86_64       8.0.30-3.el9_0          appstream        70 k
[...]
Complete!
```

- **donc vous devez effectuer une commande `mysql` sur `web.tp2.linux`**
  ```
  [leo@web ~]$ mysql -u nextcloud -h 10.102.1.12 -p
  Enter password:
  Welcome to the MySQL monitor.  Commands end with ; or \g.
  Your MySQL connection id is 17
  [...]
  ```
- une fois connecté à la base, utilisez les commandes SQL fournies ci-dessous pour explorer la base

  ```
  mysql> SHOW DATABASES;
  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | nextcloud          |
  +--------------------+
  2 rows in set (0.00 sec)

  mysql> USE nextcloud;
  Database changed
  mysql> SHOW TABLES;
  Empty set (0.00 sec)
  ```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
MariaDB [(none)]> SELECT User FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.001 sec)
```

## B. Serveur Web et NextCloud

🌞 **Install de PHP**

```
[leo@web ~]$ sudo dnf config-manager --set-enabled crb
[sudo] password for leo:
[leo@web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
 remi-release          noarch          9.0-6.el9.remi            @commandline           25 k
 yum-utils             noarch          4.0.24-4.el9_0            baseos                 36 k
[...]
Complete!
[leo@web ~]$ dnf module list php
[...]
[leo@web ~]$ sudo dnf module enable php:remi-8.1 -y
[...]
Complete!
[leo@web ~]$ sudo dnf install -y php81-php
[...]
Complete!
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```
[leo@web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Installing:
 php81-php-bcmath           x86_64         8.1.12-1.el9.remi         remi-safe          38 k
 php81-php-gd               x86_64         8.1.12-1.el9.remi         remi-safe          45 k
 php81-php-gmp              x86_64         8.1.12-1.el9.remi         remi-safe          36 k
 php81-php-intl             x86_64         8.1.12-1.el9.remi         remi-safe         155 k
 php81-php-mysqlnd          x86_64         8.1.12-1.el9.remi         remi-safe         147 k
 php81-php-pecl-zip         x86_64         1.21.1-1.el9.remi         remi-safe          58 k
 php81-php-process          x86_64         8.1.12-1.el9.remi         remi-safe          44 k
[...]
Complete!
```

🌞 **Récupérer NextCloud**

```
[leo@web ~]$ sudo mkdir /var/www/tp2_nextcloud/
```

- récupérer le fichier suivant avec une commande `curl` ou `wget` : https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
  ```
  [leo@web ~]$ sudo dnf install -y wget
  [...]
  Complete!
  [leo@web ~]$ wget https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
  [...]
  2022-11-15 15:47:26 (4.18 MB/s) - ‘nextcloud-25.0.0rc3.zip’ saved [176341139/176341139]
  ```
- extrayez tout son contenu dans le dossier `/var/www/tp2_nextcloud/` en utilisant la commande `unzip`
  - installez la commande `unzip` si nécessaire
    ```
    [leo@web ~]$ sudo dnf install unzip -y
    [...]
    Complete!
    ```
  - vous pouvez extraire puis déplacer ensuite, vous prenez pas la tête
    ```
    [leo@web ~]$ sudo unzip nextcloud-25.0.0rc3.zip -d /var/www/tp2_nextcloud/
    [leo@web ~]$ sudo mv /var/www/tp2_nextcloud/nextcloud/* /var/www/tp2_nextcloud/
    [leo@web ~]$ sudo rm -r /var/www/tp2_nextcloud/nextcloud/
    ```
  - contrôlez que le fichier `/var/www/tp2_nextcloud/index.html` existe pour vérifier que tout est en place
    ```
    [leo@web ~]$ ls /var/www/tp2_nextcloud/ | grep index.html
    index.html
    ```
- assurez-vous que le dossier `/var/www/tp2_nextcloud/` et tout son contenu appartient à l'utilisateur qui exécute le service Apache
  ```
  [leo@web ~]$ sudo chown apache -R /var/www/tp2_nextcloud/
  [leo@web ~]$ sudo chgrp apache -R /var/www/tp2_nextcloud/
  [leo@web ~]$ ls -l /var/www/ | grep tp2
  drwxr-xr-x. 14 apache apache 4096 Nov 15 15:52 tp2_nextcloud
  ```

🌞 **Adapter la configuration d'Apache**

```
[leo@web ~]$ cat /etc/httpd/conf/httpd.conf | tail -n 1
IncludeOptional conf.d/*.conf
[leo@web ~]$ sudo nano /etc/httpd/conf.d/nextcloud.conf
[leo@web ~]$ cat /etc/httpd/conf.d/nextcloud.conf
<VirtualHost *:80>
# on indique le chemin de notre webroot
DocumentRoot /var/www/tp2_nextcloud/
# on précise le nom que saisissent les clients pour accéder au service
ServerName  web.tp2.linux

# on définit des règles d'accès sur notre webroot
<Directory /var/www/tp2_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
    Dav off
    </IfModule>
</Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache**

```
[leo@web ~]$ sudo systemctl restart httpd
[leo@web ~]$ systemctl is-active httpd
active
```

## C. Finaliser l'installation de NextCloud

🌞 **Exploration de la base de données**

```
[leo@web ~]$ mysql -u nextcloud -h 10.102.1.12 -p
Welcome to the MySQL monitor.  Commands end with ; or \g.
mysql> USE nextcloud;
mysql> SELECT FOUND_ROWS();
+--------------+
| FOUND_ROWS() |
+--------------+
|           95 |
+--------------+
```
