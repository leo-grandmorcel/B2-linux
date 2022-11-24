# Module 7 : Fail2Ban

➜ **Mettre en place Fail2Ban**
```
[leo@db ~]$ sudo dnf install epel-release -y
Installed:
  epel-release-9-4.el9.noarch
[leo@db ~]$ sudo dnf install fail2ban fail2ban-firewalld -y
Installed:
  esmtp-1.2-19.el9.x86_64                     fail2ban-1.0.1-2.el9.noarch               fail2ban-firewalld-1.0.1-2.el9.noarch
  fail2ban-sendmail-1.0.1-2.el9.noarch        fail2ban-server-1.0.1-2.el9.noarch        libesmtp-1.0.6-24.el9.x86_64
  liblockfile-1.14-9.el9.x86_64               python3-systemd-234-18.el9.x86_64
[leo@db ~]$ sudo systemctl start fail2ban
[leo@db ~]$ sudo systemctl enable fail2ban
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service → /usr/lib/systemd/system/fail2ban.service.
[leo@db ~]$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
[leo@db ~]$ sudo nano /etc/fail2ban/jail.local
[leo@db ~]$ sudo mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local
[leo@db ~]$ sudo systemctl restart fail2ban
[leo@db ~]$ sudo nano /etc/fail2ban/jail.d/sshd.local
[leo@db ~]$ sudo cat /etc/fail2ban/jail.d/sshd.local | tail -n 7
[sshd]
enabled = true
bantime = 1d
maxretry = 3
[leo@db ~]$ sudo systemctl restart fail2ban
```

➜ **Test it**
```
[leo@web ~]$ ssh leo@10.102.1.12
leo@10.102.1.12's password:
Permission denied, please try again.
leo@10.102.1.12's password:
Permission denied, please try again.
leo@10.102.1.12's password:
leo@10.102.1.12: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
[leo@web ~]$ ssh leo@10.102.1.12
ssh: connect to host 10.102.1.12 port 22: Connection refused
```

```
[leo@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   10.102.1.11
[leo@db ~]$ sudo firewall-cmd --list-all | tail -n 2
  rich rules:
        rule family="ipv4" source address="10.102.1.11" port port="ssh" protocol="tcp" reject type="icmp-port-unreachable"
[leo@db ~]$ sudo fail2ban-client unban 10.102.1.11
1
```


