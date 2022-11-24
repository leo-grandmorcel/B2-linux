#!/bin/bash
# Simple script that archives the database nextcloud into /srv/db_dumps.
# 18/11/2022
# Leo Grand-Morcel

# Variables
source db_pass
username="dumper"
basename="nextcloud"
ip_bd="localhost"

# Usage function 
function usage() 
{
  echo "Usage : tp3_db_dumps.sh [options]"
  echo "\t -D <name> Database name, nextcloud by default"
}

# Option management
while getopts ":d:h" option
do
    case "${option}" in
        d)
            basename="${OPTARG}"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done

file="db_${basename}_$(date +"%y%m%d_%H%m")"
dest_file_path="db_dumps/${file}"


# Dump of the database
/usr/bin/mysqldump -u "${username}" -p"${password}" -h "${ip_bd}" "${basename}" > "${dest_file_path}.sql"

# Archiving the file
/usr/bin/tar -zcf  "${dest_file_path}.tar.gz" --remove-files "${dest_file_path}.sql"