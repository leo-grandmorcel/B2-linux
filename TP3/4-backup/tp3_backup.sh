#!/bin/bash
# Simple script that archives config, data and themes folders from nextcloud into /srv/backup.
# 19/11/2022
# Leo Grand-Morcel

# Variables
file="nextcloud_$(date +"%y%m%d_%H%m%S")"
dest_file_path="backup/${file}"
path_conf="/var/www/tp2_nextcloud/"


# Archiving folders
/usr/bin/tar -czf "${dest_file_path}.tar.gz" -C "${path_conf}" config data themes