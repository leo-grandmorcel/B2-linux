# Installation WebApp

La WebApp est codée en golang.
Celle-ci écoute en localhost sur le port 8080.
Actuellement le docker compose lance 3 dockers via la commande `scale`.

Les variables à modifier dans le [DockerFile](./Dockerfile) pour se connecter à la DB sont :

```
ENV USER_DB="forum"                   # Spécifier le nom du User accédant à la Database
ENV IP_DB="10.102.1.3"                # Spécifier l'Ip du serveur possèdant la Database
ENV PASSWORD_DB="thebestpassword123"  # Spécifier le mot de passe de l'utilisateur
ENV NAME_DB="forum"                   # Spécifier le nom de la Database à utiliser
```

Il vous faudra autoriser les port 8080/tcp 8081/tcp 8082/tcp sur votre machine.

Rocky Linux

```
sudo firewall-cmd --add-port 8080/tcp --permanent
sudo firewall-cmd --add-port 8081/tcp --permanent
sudo firewall-cmd --add-port 8082/tcp --permanent
sudo firewall-cmd --reload
```

Une fois les variables modifiées, il vous faudra construire l'image et lancer le service via :

```
sudo mkdir /srv/Avatar
cd forum/
docker build . -t forum
docker compose up -d
```
