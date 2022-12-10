# Installation Keepalived

Rappel Keepalived est utile lorsque vous avez deux proxies.
Keepalived créera une IP virtuelle et permettre de créer une relation MASTER/BACKUP entre les proxies.
Il va de soi que Keepalived doit être installé sur les deux proxies.

Les variables à modifier sur le [DockerFile](./Dockerfile) sont :

```
ENV STATE="MASTER"
ENV INTERFACE="enp0s8"
ENV ROUTER_ID="51"
ENV PRIORITY="100"
ENV PASSWORD="PASSWORD"
ENV VIRTUAL_IP="10.102.1.100\/24"
```

State : Spécifier l'état (MASTER/BACKUP)
Interface : Spécifier l'interface réseau sur laquelle l'instance doit s'exécuter
Router_Id : Spécifier à quel identifiant de routeur VRRP l'instance appartient
Priority : Spécifier la priorité de l'instance dans le routeur VRRP
Password : Spécifiez le mot de passe à utiliser
Virtual_IP : Spécifiez l'ip Virtuel

Une fois les variables modifiées, il vous faudra construire l'image et lancer le service via :

```
cd /keepalived
docker build . -t keepalived
docker compose up -d
```

Pour plus d'informations voici la doc officiel de [KeepAlived](https://keepalived.readthedocs.io/en/latest/introduction.html)
