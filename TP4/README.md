# TP4 : Conteneurs

# Sommaire

- [TP4 : Conteneurs](#tp4--conteneurs)
- [Sommaire](#sommaire)
- [I. Docker](#i-docker)
  - [1. Install](#1-install)
  - [2. Lancement de conteneurs](#2-lancement-de-conteneurs)
- [II. Images](#ii-images)
- [III. `docker-compose`](#iii-docker-compose)

# I. Docker

## 1. Install

🌞 **Installer Docker sur la machine**

```
[leo@docker1 ~]$ sudo dnf install -y dnf-utils
[...]
Installed:
  yum-utils-4.0.24-4.el9_0.noarch
Complete!
[leo@docker1 ~]$ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
Adding repo from: https://download.docker.com/linux/centos/docker-ce.repo
[leo@docker1 ~]$ sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
[...]
Installed:
  checkpolicy-3.3-1.el9.x86_64                                   container-selinux-3:2.188.0-1.el9_0.noarch
  containerd.io-1.6.10-3.1.el9.x86_64                            docker-ce-3:20.10.21-3.el9.x86_64
  docker-ce-cli-1:20.10.21-3.el9.x86_64                          docker-ce-rootless-extras-20.10.21-3.el9.x86_64
  docker-compose-plugin-2.12.2-3.el9.x86_64                      docker-scan-plugin-0.21.0-3.el9.x86_64
  fuse-common-3.10.2-5.el9.0.1.x86_64                            fuse-overlayfs-1.9-1.el9_0.x86_64
  fuse3-3.10.2-5.el9.0.1.x86_64                                  fuse3-libs-3.10.2-5.el9.0.1.x86_64
  libslirp-4.4.0-7.el9.x86_64                                    policycoreutils-python-utils-3.3-6.el9_0.noarch
  python3-audit-3.0.7-101.el9_0.2.x86_64                         python3-libsemanage-3.3-2.el9.x86_64
  python3-policycoreutils-3.3-6.el9_0.noarch                     python3-setools-4.4.0-4.el9.x86_64
  python3-setuptools-53.0.0-10.el9.noarch                        slirp4netns-1.2.0-2.el9_0.x86_64
  tar-2:1.34-3.el9.x86_64
Complete!
[leo@docker1 ~]$ sudo systemctl start docker
[sudo] password for leo:
[leo@docker1 ~]$ sudo systemctl is-active docker
active
[leo@docker1 ~]$ sudo usermod -aG docker $(whoami)
```

## 2. Lancement de conteneurs

🌞 **Utiliser la commande `docker run`**

```
[leo@docker1 ~]$ docker run --name nginx -d -v /home/leo/html:/var/www/tp4 -v /home/leo/nginx/nginx.conf:/etc/nginx/conf.d/better.conf -p 6666:66 --cpus 0.5 -h nginx -m 7000000 nginx
05cdc9648d359054d7106e4d806d06d1de764031ee37cefc770da45da733637f
[leo@docker1 ~]$ curl 172.17.0.2:66
<!doctype html>
<html>
  <head>
    <title>TP4, from Eole</title>
  </head>
  <body>
    <p>This is an example paragraph. Anything in the <strong>body</strong> tag will appear on the page, just like this <strong>p</strong> tag and its contents.</p>
  </body>
</html>
```

# II. Images

🌞 **Construire votre propre image**

```
[leo@docker1 work]$ docker build . -t my_own_nginx
[leo@docker1 work]$ docker run -d --name test -p 6666:80 my_own_nginx
```

📁 [**`Dockerfile`**](./DockerFile)

# III. `docker-compose`

🌞 **Conteneurisez votre application**

```
[leo@docker1 ~]$ mkdir app && cd app
[leo@docker1 app]$ git clone https://github.com/leo-grandmorcel/forum
[leo@docker1 app]$ ls
docker-compose.yml  Dockerfile  forum
[leo@docker1 app]$ docker build . -t forum
[leo@docker1 app]$ docker compose up
[+] Running 1/0
 ⠿ Container go-forum-1  Created                                                                                                0.1s
Attaching to go-forum-1
go-forum-1  | Listening at http://:8080
```

📁 [**`app/Dockerfile`**](./app/DockerFile)

📁 [**`app/docker-compose.yml`**](./app/docker-compose.yml)
