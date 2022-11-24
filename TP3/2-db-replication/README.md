# Module 2 : Réplication de base de données

```
[leo@db ~]$ cat /etc/my.cnf
[client-server]
!includedir /etc/my.cnf.d
[mariadb]
log-bin
server_id=1
log-basename=master1
binlog-format=mixed
skip-networking=0
bind-address=0.0.0.0
[leo@db ~]$ sudo mysql -u root
MariaDB [(none)]> CREATE USER 'replication_user'@'10.102.1.14' IDENTIFIED BY '******';
Query OK, 1 row affected (0.001 sec)
[leo@db ~]$ sudo mariabackup --backup --target-dir=/srv/backup --user=root
```

✨ Bonus : Faire en sorte que l'utilisateur créé en base de données ne soit utilisable que depuis l'autre serveur de base de données

```
[leo@slave ~]$ cat /etc/my.cnf
[client-server]
!includedir /etc/my.cnf.d
[mariadb]
server_id=2
[leo@slave ~]$ sudo scp -r root@10.102.1.12:/srv/backup/* .
[leo@slave ~]$ sudo mariabackup --prepare --target-dir=backup/
[leo@slave ~]$ sudo systemctl stop mariadb
[leo@slave ~]$ sudo rm -rf /var/lib/mysql/*
[leo@slave ~]$ sudo mariabackup --copy-back --target-dir=backup/
[leo@slave ~]$ sudo chown -R mysql:mysql /var/lib/mysql/
MariaDB [(none)]> CHANGE MASTER TO
  MASTER_HOST='10.102.1.12',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='****',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='master1-bin.000096',
  MASTER_LOG_POS=848,
  MASTER_CONNECT_RETRY=10;
MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected, 1 warning (0.000 sec)
MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 10.102.1.12
                   Master_User: replication_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000009
           Read_Master_Log_Pos: 985
                Relay_Log_File: mariadb-relay-bin.000002
                 Relay_Log_Pos: 694
         Relay_Master_Log_File: master1-bin.000009
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
[...]
```
