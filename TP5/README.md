# TP5 : Hébergement d'une solution libre et opensource

La solution est une application Web, un forum.
Le forum utilise une Database mysql, ainsi qu'un reverse proxy nginx.
Elle est accessible en HTTPS.
Durant ce TP5, j'ai mis en place deux reverses proxies afin de réaliser du load balancing entre les 3 WebApp lancées.
Ainsi qu'une Ip virtuelle via Keepalived qui permet d'alterner entre les deux reverses proxies.

## Installation de la solution

Afin de faciliter l'installation de la solution, chaque module a été Dockerisé.
Il est donc nécessaire d'installer Docker via ces commandes.

```
sudo dnf update -y
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
```

Afin de faciliter l'installation des modules, veillez à copier via une commande `scp` les dossiers ci-dessous sur les machines respectivent.
Chaque module possède ses instructions d'installation.

Machine Database :

- [db](./db/)

Machine Webapp :

- [forum](./forum/)

Machines Proxies :

- [proxy](./proxy/)
- [keepalived](./keepalived/)
