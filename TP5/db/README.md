# Installation de la Database mysql

La DB sera accessible via l'ip de la machine sur le port 3306.
Dans le [docker compose](./docker-compose.yml), vous pouvez modifier ces variables comme il vous semble.

```
MYSQL_ROOT_PASSWORD: beepbeepboop
MYSQL_DATABASE: forum
MYSQL_USER: forum
MYSQL_PASSWORD: thebestpassword123
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
