#!/bin/bash
scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
envfile="$scriptdir/.env"
logfile="$scriptdir/resourcespace.log"
scriptname="$(basename "$0")"
latest_version="11.0"
default_web_dir="/var/www/html/resourcespace"
source "${scriptdir}"/lib/logfunctions.sh
if [ "$EUID" != 0 ]; then
    warning "you must use 'sudo' or 'sudo -i' or become root to run this script"
    exit 2
fi
if [ -f /etc/os-release ]; then
    source /etc/os-release
elif [ -f /usr/lib/os-release ]; then
    source /usr/lib/os-release
else
    warning "we didn't found file 'os-release' in '/etc/' or  '/usr/lib/'"
    exit 1
fi
if [ "$NAME" != "Ubuntu" ] || [ "$ID" != "ubuntu" ]; then
        warning "this script currently supports only ubuntu"
        warning "your server is '$NAME'"
        exit 1
fi
source "${scriptdir}"/lib/commonfunctions.sh
if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
else
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --db-name)
                [[ -n "$2" && "$2" != -* ]] || { 
                    error "--db-name requires value"
                    exit 1
                } 
                databasename="$2"
                shift 2
                ;;
            --db-user)
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--db-user requires value"
                    exit 1
                }
                databaseuser="$2"
                shift 2
                ;;
            --db-password)
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--db-password requires value"
                    exit 1
                }
                databasepassword="$2"
                echo "DB_PASSWORD=$databasepassword" >> "$envfile"
                shift 2
                ;;
            --download-version)
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--download-version requires value"
                    exit 1
                }
                if [[ "$2" =~ ^[0-9]+\.[0.9]$ ]]; then
                    highest="$(printf '%s\n' "$latest_version" "$2" | sort -V | tail -n 1)"
                    if [[ "$highest" == "$latest_version" ]]; then
                        downloadversion="$2"
                    else
                        warning "download version '$2' cannot be higher than latest version ($latest_version)"
                        exit 1
                    fi
                else
                    warning "wrong version number input, please enter like (10.0, 10.1, 11.0, 9.1)"
                    exit 1
                fi
                shift 2
                ;;
            --*|-*|*)
                echo
                echo "Invalid option please refer to below help usage"
                echo
                usage
                exit 1
                ;;
        esac
    done
fi
[[ ! -z "$databasename" ]] || {
    error "--db-name must used and cannot be empty"
}
[[ ! -z "$databaseuser" ]] || {
    error "--db-user must be used and cannot be empty"
}
[[ ! -z "$databasepassword" ]] || {
    error "--db-password must used and cannot be empty"
    exit 1
}
[[ -z "$downloadversion" ]] && downloadversion="11.0"
mainmenu
source "${scriptdir}"/lib/mysqlfunctions.sh
if command -v mysql >/dev/null 2>&1; then
    info "we have found mysql installed already"
    mysqlauthsocket || mysqlroot || exit 2
fi
source "${scriptdir}"/lib/packagesfunctions.sh
source "${scriptdir}"/lib/apachefunctions.sh
source "${scriptdir}"/lib/downloadfunctions.sh
source "${scriptdir}"/lib/phpfunctions.sh
checkdependencies
installpackages || exit 2
downloadresourcespace || exit 2
phpconfig || exit 2
apacheconfig || exit 2
servicecheck "mysql.service" || exit 2
mysqlauthsocket || mysqlroot || exit 2
mysqlconfig "$databasename" "$databaseuser" "$databasepassword" || exit 2