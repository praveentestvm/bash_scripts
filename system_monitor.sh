#!/bin/bash

main() {
    while true; do 
    banner "SYSTEM CHECKUP"
    menu 1 "SERVICE MENU"
    menu 2 "DISK USGAE"
    menu 3 "PACKAGE SERACH"
    menu q "QUIT"
    read -rp "Enter you Option: " system_checkup
        case "$system_checkup" in
            1) service_menu ;;
            2) disk_usage ;;
            3) package_search ;;
            q) quit 
                break 
                ;;
            *) invalid ;;
        esac
    done
}

service_menu() {
    while true; do
    banner "SERVICE MENU"
    menu a "status"
    menu s "start"
    menu t "stop"
    menu e "enable"
    menu d "disable"
    menu q "quit"
    read -rp "Enter the Service name: " "SERVICE_MENU"
    if systemctl list-unit-files --type=service | grep -q "^$SERVICE_MENU.service"; then
        info "$SERVICE_MENU is listed"
    else
        info "Unknown service name $SERVICE_MENU"
        return 1
    fi
    read -rp "Choose the state you want to check: " "SERVICE"
        case "$SERVICE" in
            a|A)
                check "if $SERVICE_MENU is active"
                if systemctl is-active --quiet "$SERVICE_MENU"; then
                    succ "$SERVICE_MENU is running"
                else
                    err "$SERVICE_MENU is not running"
                fi
                ;;
            s|S)
                check "if $SERVICE_MENU is active"
                if systemctl is-active --quiet "$SERVICE_MENU"; then
                    info "$SERVICE_MENU is already running"
                else
                    info "$SERVICE_MENU is not running. Starting now..."
                    if systemctl start "$SERVICE_MENU" 2>/dev/null; then
                        info "$SERVICE_MENU is started successfully"
                    else
                        err "$SERVICE_MENU is not able to start"
                    fi
                fi
                ;;
            t|T)
                check "if $SERVICE_MENU is active?"
                if ! systemctl is-active --quiet "$SERVICE_MENU"; then
                    err "$SERVICE_MENU is not running"
                else
                    info "$SERVICE_MENU is already running."
                    if systemctl stop "$SERVICE_MENU" 2>/dev/null; then
                        succ "$SERVICE_MENU stopped successfully..."
                    else
                        err "$SERVICE_MENU is failed to stop"
                    fi
                fi
                ;;
            e|E)
                check "if $SERVICE_MENU is enabled"
                if systemctl is-enabled --quiet "$SERVICE_MENU"; then
                    info "$SERVICE_MENU is already enabled"
                else
                    info "$SERVICE_MENU not enabled"
                    if systemctl enabled "$SERVICE_MENU" 2>/dev/null; then
                        succ "$SERVICE_MENU is enabled successfully"
                    else
                        err "Unable to enable $SERVICE_MENU"
                    fi
                fi
                ;;
            d|D)
                check "if $SERVICE_MENU is disabled"
                if ! systemctl is-enabled --quiet "$SERVICE_MENU"; then
                    info "$SERVICE_MENU is already disabled"
                else
                    info "$SERVICE_MENU is enabled"
                    if systemctl disable "$SERVICE_MENU" 2>/dev/null; then
                        succ "$SERVICE_MENU is disabled successfully"
                    else
                        err "Failed to disable $SERVICE_MENU"
                    fi
                fi
                ;;
            q|Q) quit 
                break
                ;;
            *) invalid ;;
        esac

    done
}

disk_usage() {
    while true; do
    banner "DISK USAGE"
    menu r "root diskusage"
    menu i "inode usage"
    menu p "percentage"
    menu q "quit"
    read -rp "Choose you option: " DISK_USAGE
        case "$DISK_USAGE" in
            r|R)
                check "root disk usage"
                echo
                df -h / | awk '{print $3, $4}'
                ;;
            i|I)
                check "inodes of the system"
                echo
                df -i / | awk '{print $3, $4}'
                ;;
            p|P)
                check "disk usage in percentage, warning if above threshold"
                THRESHOLD=80
                USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d "%")
                if [[ "$USAGE" -gt "$THRESHOLD" ]]; then
                    warn "Disk usage is High current usage is $USAGE%"
                else
                    info "Disk usage is normal current usage is $USAGE%"
                fi
                ;;
            q|Q) quit 
                break
                ;;
            *)
                invalid
                ;;
        esac
    done
}

package_search() {
    while true; do
    banner "PACKAGE SEARCH"
    menu l "LOCAL SEARCH"
    menu i "INSTALL"
    menu o "Online Search"
    menu q "QUIT"
    read -rp "Enter you Option: " package
        case "$package" in
            l|L)
                read -rp "Enter Package Name: " PACKAGE
                if dpkg -l | awk '{print $2}' | grep -q "$PACKAGE"; then
                    succ "$PACKAGE package is installed"
                else
                    err "$PACKAGE package not found"
                    read -rp "Do you want to install (y/n)" APT
                    case "$APT" in
                        y|Y)
                            info "Installing package..."
                            if apt install -y "$PACKAGE" >/dev/null 2>&1; then
                                succ "$PACKAGE package is installed"
                            else
                                err "$PACKAGE package is failed to installed try again"
                            fi
                            ;;
                        n|N)
                            info "You have opted (n), quitting"
                            ;;
                        *)
                            invalid
                            ;;
                    esac
                fi
                ;;
            i|I)
                read -rp "Enter the packge name you want to install: " APT2
                if apt install -y "$APT2" >/dev/null 2>&1; then
                    succ "$APT2 package is installed successfully"
                else
                    err "Failed to intall package $APT2: Please try again"
                fi
                ;;
            o|O)
                read -rp "Enter the package name you want to search: " online
                echo
                if apt show -a "$online"; then
                    echo
                    succ "Package ound uccessfully"
                else
                    err "Enter the correct Package name"
                fi
                ;;
            q|Q) quit 
                break
                ;;
            *)
                invalid
                ;;
        esac
    done
}

banner() {
    printf "#########################\n"
    printf "# %-21s #\n" "$1"
    printf "#########################\n"
}

menu() {
    local level="$1"
    shift
    printf "(%s) %s\n" "$level" "$*"
}
print() {
    local level="$1"
    shift
    printf "[%s]: %s\n" "$level" "$*"
}

err() {
    print ERROR "$@"
}

warn() {
    print WARNING "$@"
}

info() {
    print INFO "$@"
}

check() {
    print CHECKING "$@"
}

succ() {
    print SUCCESS "$@"
}

quit() {
    info "quitting the script"
}

invalid() {
    info "Invalid Option Please try again"
}

root() {
    if [[ "$EUID" != 0 ]]; then 
    err "You must be root or use sudo to run the script"
    exit 1
    fi
}

root

main