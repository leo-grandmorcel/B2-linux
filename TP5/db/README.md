# Installation de la Database mysql

La DB sera accessible via l'ip de la machine sur le port 3306.
Dans le [docker compose](./docker-compose.yml), vous pouvez modifier ces variables comme il vous semble.

```
MYSQL_ROOT_PASSWORD: beepbeepboop     # Spécifiez le mot de passe pour se connecter en root
MYSQL_DATABASE: forum                 # Spécifiez le nom de la base de données
MYSQL_USER: forum                     # Spécifiez le nom du User qui sera crée
MYSQL_PASSWORD: thebestpassword123    # Spécifiez le mot de passe de celui-ci
```

Note : Si vous les modifiez elles seront à modifier dans le [DockerFile](../forum/Dockerfile) de la WebApp.

Il vous faudra autoriser le port 3306/tcp sur votre machine.

Rocky Linux

```
sudo firewall-cmd --add-port 3306/tcp --permanent
sudo firewall-cmd --reload
```

Pour lancer le Docker :

```
cd db
docker compose up -d
```
