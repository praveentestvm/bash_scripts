#!/bin/bash
#This script is used for checking the service is active or inactive or etc

if [[ "$EUID" -ne 0 ]]; then
    echo "You must be root or use sudo run this script"
    exit 1
fi

echo "Enter the service name to check the status"
echo

read -p "Enter the service name:" SYSTEMSERVICE
echo 

check_status() {
    local SERVICE
    local STATE

    SERVICE=$1
    STATE=$(systemctl is-active "$SERVICE" 2>/dev/null)

    case "$STATE" in
        active) echo "$SERVICE: is active" ;;
        inactive) echo "$SERVICE: has inactive" ;;
        *) echo "Invalid service name $SERVICE" ;;
    esac
}

check_status "$SYSTEMSERVICE"   