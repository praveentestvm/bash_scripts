#!/bin/bash

log_file="/var/log/installer.log"

log_time_stamp() {
    local timestamp
    timestamp="$(date +%c)"
    cat << EOF >> "$log_file"

===============($timestamp)===============

EOF
}
usage() {
    cat << EOF
Usage:
  --install <package>         Install a package
  --remove <package>          Remove a package
  --purge <package>           Remove a package and its configuration files
  --update                    Update package lists
  --upgrade                   Upgrade installed packages
  --list-installed            List installed packages
  --help                      Show this help message
  --version                   Version information
EOF
}

version() {
    local app_name app_version author
    app_name="Package Manager"
    app_version="1.3"
    author="Praveen"
    cat << EOF
$app_name
Version     : $app_version 
Author      : $author
EOF
}

root_check() {
    if (( EUID != 0 )); then
        error "you must be root or use sudo to run this script"
        exit 1
    fi
}

is_installed() {
    local package="$1"
    dpkg -s "$package" >/dev/null 2>&1
}

pkg_update() {
    if apt-get update >>"$log_file" 2>&1; then
        say "package list has been updated"
    else
        error "failed to update package list for details check ($log_file)"
        return 1
    fi
}

pkg_upgrade() {
    apt list --upgradable >>"$log_file" 2>&1
    if apt-get full-upgrade -y >>"$log_file" 2>&1; then
        say "packages have been upgraded, for details check ($log_file)"
    else
        error "failed to upgrade packages, for details check ($log_file)"
        return 1
    fi
}

pkg_install() {
    local package="$1"
    if is_installed "$package"; then
        say "package '$package' is already installed"
    else
        if apt-get install -y "$package" >>"$log_file" 2>&1; then
            say "package '$package' is installed successfully"
        else
            error "failed to install package: $package"
            error "see '$log_file'"
            return 1
        fi
    fi
}

pkg_remove() {
    local package="$1"
    if is_installed "$package"; then
        if apt-get remove -y "$package" >>"$log_file" 2>&1; then
            say "package '$package' removed successfully"
        else
            error "failed to remove package '$package' for details check ($log_file)"
            return 1
        fi
    else
        error "package '$package' is not installed"
        return 1
    fi
}

pkg_purge() {
    local package="$1"
    if is_installed "$package"; then
        if apt-get purge -y "$package" >>"$log_file" 2>&1; then
            say "package '$package' and its files removed successfully"
        else
            error "failed to remove '$package' and its files, for details check ($log_file)"
            return 1
        fi
    else
        error "package '$package' is not installed"
        return 1
    fi
}

pkg_list() {
    local file="/tmp/list.txt"

    if dpkg-query -W >"$file" 2>&1; then
        say "packages installed list has be saved at '$file'"
    else
        error "failed to list the installed packages"
        return 1
    fi
}

do_install() {
    pkg_update || return 1

    pkg_install "$1" || return 1
}

invalid() {
    error "invalid option '$1' please use '($0 --help)' for usage"
}

__print() {
    local level="$1"
    shift
    printf "[%s] %s\n" "$level" "$*"
}

say() {
    __print OK "$@"
}

error() {
    __print ERROR "$@"
}

if (( $# == 0 )); then
    printf "%s\n" "usage: $0 --options"
    printf "%s\n" "for details use $0 [--help]"
    exit 1
fi

log_time_stamp

while (( $# > 0 )); do
    case "$1" in
        --install)
            root_check
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--install require a value"
                    exit 1
                }
            do_install "$2"
            shift 2
                ;;
        --remove)
            root_check
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--remove require a value"
                    exit 1
                }
            pkg_remove "$2"
            shift 2
            ;;
        --purge)
            root_check
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--purge require a value"
                    exit 1
                }
            pkg_purge "$2"
            shift 2
            ;;
        --update)
            root_check
            pkg_update
            shift 1
                ;;
        --upgrade)
            root_check
            pkg_update
            pkg_upgrade
            shift 1
            ;;
        --list-installed)
            pkg_list
            shift 1
            ;;
        --help)
            usage
            exit 0
            ;;
        --version)
            version
            exit 0
            ;;
        *) 
            invalid "$1"
            shift 1
            exit 1
            ;;
    esac
done