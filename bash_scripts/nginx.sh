#!/bin/bash
#This script checks whether nginx is running and able to listen on the mentioned ports

if [[ "$EUID" -ne 0 ]]; then
    echo "You must be root or use sudo to run this script"
    exit 1
fi

echo "#################################################"
echo "# nginx report                                  #"
echo "# Generated on $(date)  #"
echo "#################################################"
echo

if [[ $(which nginx) == /usr/sbin/nginx ]]; then
    echo "Nginx Package is installed"
else
    echo "Ngins Package is Not installed installing"
    apt install nginx -y
    echo
    echo "Nginx installed at $(which nginx)"
fi

if systemctl is-active nginx >/dev/null 2>&1; then
    echo "nginx server is running"
else
    echo "nginx server is not running trying to start again"
    systemctl start nginx
    systemctl is-active nginx >/dev/null 2>&1
    echo "nginx server is started and running"
fi

echo "Checking nginx configuration status"

if [[ "$(nginx -t)" -eq 0 ]] >/dev/null 2>&1; then
    echo "NGINX Configuration is correct"
else
    echo "WARNING: NGINX configuration had a problem please check"
    exit 1
fi

if [[ "$(ss -tlnp | grep :80 )" -eq 0 ]] >/dev/null 2>&1; then
    echo "Port 80 is listening"
else
    echo "Port 80 is Not listening Pleae check"
fi

if [[ "$(ss -tlnp | grep :443 )" -eq 0 ]] >/dev/null 2>&1; then
    echo "Port 443 is listening"
else
    echo "Port 443 is not listening Please check"
fi
