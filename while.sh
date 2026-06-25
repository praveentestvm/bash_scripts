#!/bin/bash
if [[ "$EUID" -ne 0 ]]; then
    echo "You must be root or use sudo to run this script"
    exit 1
fi
while true; do
echo "##########################"
echo "#     SYSTEM CHECKUP     #"
echo "##########################"
echo "(1) SERVICE MENU"
echo "(2) DISK USAGE"
echo "(3) PACKAGE SEARCH"
echo "(q) QUIT"
read -rp "Enter your option: " OPTION1
    case "$OPTION1" in
        1)
            while true; do
            echo "########################"
            echo "#     SERVICE MENU     #"
            echo "########################"
            echo "(a) status"
            echo "(s) start"
            echo "(t) stop"
            echo "(e) enable"
            echo "(d) disable"
            echo "(q) quit"
            read -rp "Enter service name: " SERVICE
            if systemctl list-unit-files --type=service | grep -q "^$SERVICE"; then
                echo "$SERVICE is listed"
            else
                echo "Invalid service $SERVICE"
                exit 1
            fi
            read -rp "Choose your option: " OPTION2
                case "$OPTION2" in
                    a|A)
                        echo "Checking $SERVICE is active"
                        if systemctl is-active --quiet "$SERVICE"; then
                            echo "$SERVICE is running"
                        else 
                            echo "$SERVICE is not running"
                        fi
                        ;;
                    s|S)
                        echo "Checking $SERVICE is active"
                        if systemctl is-active --quiet "$SERVICE"; then
                            echo "$SERVICE is already running"
                        else
                            echo "$SERVICE in not running. Starting now..."
                            if systemctl start "$SERVICE" 2>/dev/null; then
                                echo "$SERVICE is started successfully"
                            else
                                echo "$SERVICE is not able to start"
                            fi
                        fi
                        ;;
                    t|T)
                        echo "Checking $SERVICE.service is active?"
                        if ! systemctl is-active --quiet "$SERVICE"; then
                            echo "$SERVICE is currently not running"
                        else
                            echo "$SERVICE is already running"
                            if systemctl stop "$SERVICE" 2>/dev/null; then
                                echo "$SERVICE is stopped successfully"
                            else
                                echo "$SERVICE is failed to stop"
                            fi
                        fi
                        ;;
                    e|E)
                        echo "Checking $SERVICE is enabled"
                        if systemctl is-enabled --quiet "$SERVICE"; then
                            echo "$SERVICE is enabled"
                        else
                            echo "$SERVICE not enabled"
                            if systemctl enable "$SERVICE" 2>/dev/null; then
                                echo "$SERVICE is enabled"
                            else
                                echo "$SERVICE is failed to start"
                            fi
                        fi
                        ;;
                    d|D)
                        echo "Checking $SERVICE is disabled"
                        if ! systemctl is-enabled --quiet "$SERVICE"; then
                            echo "$SERVICE is already disabled"
                        else
                            echo "$SERVICE is enabled"
                            if systemctl disable "$SERVICE" 2>/dev/null; then
                                echo "$SERVICE is disabled"
                            else
                                echo "$SERVICE is failed to disable"
                            fi
                        fi
                        ;;
                    q|Q)
                        echo "Qutting the script"
                        break
                        ;;
                    *)
                        echo "Invalid option, Please try again..."
                        ;;
                esac
            done
            ;;
        2)
            while true; do
            echo "######################"
            echo "#     DISK USAGE     #"
            echo "######################"
            echo "(r) root diskusage"
            echo "(i) inode usage"
            echo "(p) percentage"
            echo "(q) quit"
            read -rp "Choose you option: " OPTION3
                case "$OPTION3" in
                    r|R)
                        echo "Checking root disk usage"
                        echo
                        df -h / | awk '{print $3, $4}'
                        ;;
                    i|I)
                        echo "Checking inodes of the system"
                        echo
                        df -i / | awk '{print $3, $4}'
                        ;;
                    p|P)
                        echo "Checking disk usage in percentage, warn is above threshold"
                        THRESHOLD=80
                        USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d "%")
                        if [[ "$USAGE" -gt "$THRESHOLD" ]]; then
                            echo "[WARNING]: Disk usage is High current usage is $USAGE%"
                        else
                            echo "[OK]: Disk usage is normal current usage is $USAGE%"
                        fi
                        ;;
                    q|Q)
                        echo "Quitting the script"
                        break
                        ;;
                    *)
                        echo "Invalid Option Please try again"
                        ;;
                esac
            done
            ;;
        3)
            while true; do
            echo "##########################"
            echo "#     PACKAGE-SEARCH     #"
            echo "##########################"
            echo "(l) LOCAL SEARCH"
            echo "(i) INSTALL"
            echo "(q) QUIT"
            read -rp "Enter you Option: " OPTION4
                case "$OPTION4" in
                    l|L)
                        read -rp "Enter Package Name: " PACKAGE
                        if dpkg -l | awk '{print $2}' | grep -q "$PACKAGE"; then
                            echo "$PACKAGE package is installed"
                        else
                            echo "$PACKAGE package not found"
                            read -rp "Do you want to install (y/n)" APT
                            case "$APT" in
                                y|Y)
                                    echo "Installing package..."
                                    if apt install "$PACKAGE" >/dev/null 2>&1; then
                                        echo "$PACKAGE package is installed"
                                    else
                                        echo "$PACKAGE package is failed to installed try again"
                                    fi
                                    ;;
                                n|N)
                                    echo "You have opted (n), quitting"
                                    ;;
                                *)
                                    echo "Invalid option Please try again"
                                    ;;
                            esac
                        fi
                        ;;
                    i|I)
                        read -rp "Enter the packge name you want to install: " APT2
                        if apt install "$APT2" >/dev/null 2>&1; then
                            echo "$APT2 package is installed successfully"
                        else
                            echo "Failed to intall package $APT2: Please try again"
                        fi
                        ;;
                    q|Q)
                        echo "Quitting the script"
                        break
                        ;;
                    *)
                        echo "Invalid option Please try again"
                        ;;
                esac
            done
            ;; 
        q|Q)
            echo "quitting the script"
            break
            ;;
        *)
            echo "Invalid option Please try again"
            ;;        
    esac
done