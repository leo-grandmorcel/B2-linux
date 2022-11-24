# Module 1 : Reverse Proxy

Un reverse proxy est donc une machine que l'on place devant un autre service afin d'accueillir les clients et servir d'intermédiaire entre le client et le service.

## Sommaire

- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
  - [Sommaire](#sommaire)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)

# I. Setup

➜ **On utilisera NGINX comme reverse proxy**

```
[leo@proxy ~]$ sudo dnf install -y nginx
[...]
Installed:
  nginx-1:1.20.1-10.el9.x86_64                nginx-filesystem-1:1.20.1-10.el9.noarch
  rocky-logos-httpd-90.11-1.el9.noarch
[leo@proxy ~]$ sudo systemctl start nginx
[leo@proxy ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[leo@proxy ~]$ sudo ss -ltpn | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1354,fd=6),("nginx",pid=1353,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1354,fd=7),("nginx",pid=1353,fd=7))
[leo@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[leo@proxy ~]$ sudo firewall-cmd --reload
success
[leo@proxy ~]$ ps -ef | grep nginx
root        1353       1  0 15:30 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1354    1353  0 15:30 ?        00:00:00 nginx: worker process
leo         1406    1164  0 15:32 pts/0    00:00:00 grep --color=auto nginx
```

```
PS C:\Users\lgran> curl 10.102.1.13:80
StatusCode        : 200
StatusDescription : OK
```

➜ **Configurer NGINX**

```
[leo@proxy ~]$ cat /etc/nginx/nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;

[leo@proxy ~]$ cat /etc/nginx/conf.d/proxy.conf
server {
    listen 80;

    location / {
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://10.102.1.11:80;
    }
    location /.well-known/carddav {
    return 301 $scheme://$host/remote.php/dav;
    }
    location /.well-known/caldav {
    return 301 $scheme://$host/remote.php/dav;
    }
}
```

➜ **Configurer Nextcloud**

```
[leo@web ~]$ sudo cat /var/www/tp2_nextcloud/config/config.php
<?php
$CONFIG = array (
  'instanceid' => 'ock9fbrq3ay4',
  'passwordsalt' => '1y9Mrzu9/UaUbE3OD4DkwuL0G1ymaC',
  'secret' => 'xrQPnI3XoFxLWEaPq6/mRcj0/eXMM3/huRDbGe5A8A+QmZI0',
  'trusted_domains' =>
  array (
    0 => 'web.tp2.linux',
    1 => '10.102.1.13',
  ),
  'datadirectory' => '/var/www/tp2_nextcloud/data',
  'dbtype' => 'mysql',
  'version' => '25.0.0.15',
  'overwrite.cli.url' => 'https://web.tp2.linux',
  'overwritehost'     => 'web.tp2.linux',
  'overwriteprotocol' => 'https',
  'dbname' => 'nextcloud',
  'dbhost' => '10.102.1.12:3306',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'meow',
  'installed' => true,
);
```

➜ **Modifier votre fichier `hosts` de VOTRE PC**

```
PS C:\Users\lgran> cat C:\Windows\System32\drivers\etc\hosts
[...]
10.102.1.13 web.tp2.linux
```

✨ **Bonus** : rendre le serveur `web.tp2.linux` injoignable sauf depuis l'IP du reverse proxy.

```
[leo@web ~]$ cat /etc/sysctl.conf | tail -n 1
net.ipv4.icmp_echo_ignore_all = 1
[leo@web ~]$ sudo sysctl -p
net.ipv4.icmp_echo_ignore_all = 1
```

```
[leo@db ~]$ ping -c 2 10.102.1.11
PING 10.102.1.11 (10.102.1.11) 56(84) bytes of data.
^C
--- 10.102.1.11 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1037ms
```

# II. HTTPS

```
[leo@proxy tls]$ sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
[leo@proxy tls]$ sudo mv server.key private/
[leo@proxy tls]$ sudo mv server.crt  certs/
[leo@proxy tls]$ sudo chown nginx private/server.key
[leo@proxy ~]$ sudo cat /etc/nginx/conf.d/proxy.conf
server {
    listen 80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    ssl_certificate     "/etc/pki/tls/certs/server.crt";
    ssl_certificate_key "/etc/pki/tls/private/server.key";

    location / {
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.102.1.11;
    }

    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
[leo@proxy ~]$ sudo systemctl restart nginx
```
