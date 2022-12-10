# Installation Reverse Proxy nginx / HTTPS

Dans ce [DockerFile](./Dockerfile), vous trouverez l'IP des 3 WebApp lancées.
Celui-ci va créer un certificat SSL ainsi que sa clé via Openssl, qui seront stockés respectivement dans `/etc/ssl/certs` et `/etc/ssl/private`

Modifiez ces variables avec les IP respectives des WebApps et votre nom de serveur.

```
ENV WEB_IP1="10.102.1.2:8080"  # Spéficiez l'Ip de la docker 1
ENV WEB_IP2="10.102.1.2:8081"  # Spéficiez l'Ip de la dcoker 2
ENV WEB_IP3="10.102.1.2:8082"  # Spéficiez l'Ip de la docker 3
ENV SERVER_NAME="webapp.TP5"   # Spéficiez le nom de votre serveur
```

Il vous faudra autoriser les port 8080/tcp 8081/tcp 8082/tcp sur votre machine.

Rocky Linux

```
sudo firewall-cmd --add-port 443/tcp --permanent
sudo firewall-cmd --add-port 80/tcp --permanent
sudo firewall-cmd --reload
```

Une fois les variables modifiées, il vous faudra construire l'image et lancer le service via :

```
cd /proxy
docker build . -t proxy
docker compose up -d
```

Pour plus d'informations voici la doc officiel de [Nginx](https://nginx.org/en/docs/)
