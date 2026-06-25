#!/bin/bash
#This script is for checking docker

if [[ "$EUID" -ne 0 ]]; then
    echo "You must be root or use sudo to run this script"
    exit 1
fi

echo "Checking status of docker..."

SERVICE="docker"

if systemctl is-active --quiet "$SERVICE"; then
    echo "$SERVICE service is active"
else
    echo "$SERVICE service is not active Starting..."
    if systemctl start "$SERVICE"; then
        echo "$SERVICE service is started"
    else
        echo "$SERVICE is failed to start"
        exit 1
    fi
fi

#If docker is running and want to stop
read -rp "Do you want to stop the $SERVICE (y/n): " ANSWER

case "$ANSWER" in
    y|Y)
        echo "$SERVICE service is stopping"
        systemctl stop "$SERVICE" 2>/dev/null
        if systemctl is-active --quiet "$SERVICE"; then
            echo "$SERVICE Failed to stop"
        else
            echo "$SERVICE stopped successfully"
        fi
        ;;
    n|N)
        echo "$SERVICE is contine to run"
        ;;
    *)
        echo "Invalid option please choose (y/n)"
        ;;
esac

read -sp "Enter password: " PASSWORD
echo
echo "Password is: $PASSWORD"