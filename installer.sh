#!/bin/bash
#this is not for production or for using
#this script is only for my practice and
#pushing on the git.
#please feel free to correct, i am ready
#to accept my mistakes and want to
#improve as mush as possible
#thanks in advance

do_install() {
    if ! dpkg -s "$1" >/dev/null 2>&1; then
        if apt install -qq -y "$1"; then
            say "package '$1' is installed successfully"
        else
            error "failed to install package '$1'"
        fi
    else
        say "package '$1' is already installed"
    fi
}

menu() {
    printf "####################\n"
    printf "#   package menu   #\n"
    printf "####################\n"
}

install_menu() {
    local level
    level="$1"
    shift
    printf "%s) install %s\n" "$level" "$*" 
}

update_packages() {
    if apt update -qq >/dev/null 2>&1; then
        say "packages are updated successfully"
    else
        error "failed to updated packages"
        return 1
    fi
}

main() {
    local option
    root_check
    if ! update_packages; then
        return 1
    fi
    menu
    while true; do
        install_menu "1" "apache"
        install_menu "2" "nginx"
        install_menu "3" "mysql"
        install_menu "4" "redis"
        echo "5) exit"
        read -rp "choose your package to install: " option
        case "$option" in
            1) do_install apache2 ;;
            2) do_install nginx ;;
            3) do_install mysql-server ;;
            4) do_install redis ;;
            5) return 0 ;;
            *) echo "invalid option please choose from the menu"
        esac
    done
}

root_check() {
    if (( EUID != 0 )); then
        error "you must be root or use sudo to run this script"
        exit 1
    fi
}

__print() {
    local level
    level="$1"
    shift
    printf "[%s] %s\n" "$level" "$*" 
}

say() {
    __print "OK" "$@"
}

error() {
    __print "ERROR" "$@"
}

main