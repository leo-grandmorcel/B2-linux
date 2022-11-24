# Module 5 : Monitoring

➜ **Je vous laisse suivre la doc pour le mettre en place**

```
[leo@web ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
--2022-11-21 15:30:30--  https://my-netdata.io/kickstart.sh
[leo@web ~]$ sudo systemctl start netdata
[leo@web ~]$ sudo systemctl enable netdata
[leo@web ~]$ sudo ss -ltpn | grep netdata | head -n 2 | tail -n 1
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=4780,fd=6))
[leo@web ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[leo@web ~]$ sudo firewall-cmd --reload
success
```

```
[leo@db ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
--2022-11-21 15:30:30--  https://my-netdata.io/kickstart.sh
--2022-11-21 16:01:35--  https://my-netdata.io/kickstart.sh
[leo@db ~]$ sudo systemctl start netdata
[leo@db ~]$ sudo systemctl enable netdata
[leo@db ~]$ sudo ss -ltpn | grep netdata | head -n 2 | tail -n 1
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=1971,fd=6))
[leo@db ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[leo@db ~]$ sudo firewall-cmd --reload
success
```

➜ **Configurer Netdata pour qu'il vous envoie des alertes**

```
[leo@web ~]$ cat /etc/netdata/health_alarm_notify.conf | head -n 597 | tail -n 17
#------------------------------------------------------------------------------
# discord (discordapp.com) global notification options

# multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1044276684892950639/C_ZnIPk2Me8c0DxcOUo9t4Da5YUCWc1mz6mii9gLoDG8N5CGpm6_-fLOzV1mVBEUeQWr"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="général"
[leo@web ~]$ sudo ./edit-config health.d/cpu.conf
```

```
[leo@db ~]$ cat /etc/netdata/health_alarm_notify.conf | head -n 598 | tail -n 18
#------------------------------------------------------------------------------
# discord (discordapp.com) global notification options

# multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhook

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1044276684892950639/C_ZnIPk2Me8c0DxcOUo9t4Da5YUCWc1mz6mii9gLoDG8N5CGpm6_-fLOzV1mVBEUeQWr"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="db"
```

➜ **Vérifier que les alertes fonctionnent**

```
[leo@web ~]$ sudo -u netdata /usr/libexec/netdata/plugins.d/alarm-notify.sh test
# SENDING TEST WARNING ALARM TO ROLE: sysadmin
2022-11-21 16:50:02: alarm-notify.sh: INFO: sent discord notification for: web.tp2.linux test.chart.test_alarm is WARNING to 'général'
# OK

# SENDING TEST CRITICAL ALARM TO ROLE: sysadmin
2022-11-21 16:50:02: alarm-notify.sh: INFO: sent discord notification for: web.tp2.linux test.chart.test_alarm is CRITICAL to 'général'
# OK

# SENDING TEST CLEAR ALARM TO ROLE: sysadmin
2022-11-21 16:50:03: alarm-notify.sh: INFO: sent discord notification for: web.tp2.linux test.chart.test_alarm is CLEAR to 'général'
# OK
```

```
[leo@db ~]$ sudo -u netdata /usr/libexec/netdata/plugins.d/alarm-notify.sh test
# SENDING TEST WARNING ALARM TO ROLE: sysadmin
2022-11-21 17:06:44: alarm-notify.sh: INFO: sent discord notification for: db.tp2.linux test.chart.test_alarm is WARNING to 'db'
# OK

# SENDING TEST CRITICAL ALARM TO ROLE: sysadmin
2022-11-21 17:06:44: alarm-notify.sh: INFO: sent discord notification for: db.tp2.linux test.chart.test_alarm is CRITICAL to 'db'
# OK

# SENDING TEST CLEAR ALARM TO ROLE: sysadmin
2022-11-21 17:06:45: alarm-notify.sh: INFO: sent discord notification for: db.tp2.linux test.chart.test_alarm is CLEAR to 'db'
# OK
```
