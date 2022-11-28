#!/bin/bash
# Script that setup your machine, and install Nextcloud
# 22/11/2022
# Leo Grand-Morcel

usage(){
        echo "Usage : tp3_automation_nextcloud.sh [OPTION]
        Setup your nextcloud server
        -h            Prints help message (this message)
        -n hostname   Change the name of your machine.
        -w name       Name of your web server."
}

namer(){
        hostname "${newname}"
        lastname=$(cat /etc/hostname)
        sed -i "s/${lastname}/${newname}/g" /etc/hostname
        sed -i "s/localhost/${newname}/g" /etc/hosts
        echo "Hostname changed from ${lastname} to ${newname}"
}

apache(){
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    firewall-cmd --add-port=80/tcp --permanent
    firewall-cmd --reload
}

nextcloud(){
    dnf config-manager --set-enabled crb 
    dnf install -y httpd unzip mysql 
    dnf install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm
    dnf module enable php:remi-8.1 -y
    dnf install -y php81-php
    dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
    curl --output nextcloud.zip https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
    unzip nextcloud.zip -d /var/www/
    rm nextcloud.zip
    chown apache:apache -R /var/www/nextcloud/
    touch /etc/httpd/conf.d/nextcloud.conf
    sed -i "s/\!\!\!hostname\!\!\!/${webname}/g" .nextcloud.conf.skeleton
    cat .nextcloud.conf.skeleton > /etc/httpd/conf.d/nextcloud.conf
    rm .nextcloud.conf.skeleton
    systemctl restart httpd
}


if [[ "${EUID}" -ne 0 ]]
then 
    echo "Please run as root."
    exit 1
fi

webname=$(cat /etc/hostname)

while getopts ":hn:w:" option
do
    case "${option}" in
        h)
            usage
            exit 0
        ;;
        n)
            newname="${OPTARG}"
            namer
        ;;
        w)
            webname="${OPTARG}"
        ;;
        *)
            echo "Option ${option} not recognized." 
            usage
            exit 1
        ;;
    esac
done

if ! ping -c 1 1.1.1.1
then
    echo "No internet connexion."
    exit 1
fi

if ! ping -c 1 google.com
then
    echo "No resolution name."
    exit 1
fi

if [[ ! -e .nextcloud.conf.skeleton ]]
then
    echo "You need to copy <.nextcloud.conf.skeleton> from repo."
    exit 1
fi

if [[ ! -r .nextcloud.conf.skeleton ]]
then
    echo "File <.nextcloud.conf.skeleton> need to be readable."
    exit 1
fi

echo "Starting installation..."
dnf update -y

apache
nextcloud

echo "Installation completed, don't forget to setup the DB for nextcloud.
Your server is running on $(cat /etc/sysconfig/network-scripts/ifcfg-enp0s8 | grep -oP "IPADDR=\K.*"):80."
exit 0