#!/bin/bash
scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
envfile="$scriptdir/.env"
logfile="$scriptdir/resourcespace.log"
source "${scriptdir}"/lib/logfunctions.sh
if [ "$EUID" != 0 ]; then
    warning "you must use 'sudo' or 'sudo -i' or become root to run this script"
    exit 2
fi
if [ -f /etc/os-release ]; then
    source /etc/os-release
elif [ -f /usr/lib/os-release ]; then
    source /usr/lib/os-release
    if [ "$NAME" != "Ubuntu" ] || [ "$ID" != "ubuntu" ]; then
        warning "this script currently supports only ubuntu"
        warning "your server is '$NAME'"
        exit 1
    fi
else
    warning "we didn't found file 'os-release' in '/etc/' or  '/usr/lib/'"
    exit 1
fi
source "${scriptdir}"/lib/commonfunctions.sh
mainmenu
echo
echo "this script is going to change your existing setup of your mysql apache php if exist previously"
while :; do
    read -rp "Do you want to continue? (y/n): " userconfirmation
    case "$userconfirmation" in
        Y|y)
            info "going ahead...!"
            break
            ;;
        N|n)
            info "exiting the installer...!"
            exit 0
            ;;
        *)
            warning "invalid option please choose (y/n)"
    esac
done
source "${scriptdir}"/lib/mysqlfunctions.sh
if command -v mysql >/dev/null 2>&1; then
    info "we have found mysql installed already"
    mysqlauthsocket || mysqlroot || exit 1
fi
databasename=""
while :; do
    echo
    read -rp "default database name will be (resourcespace) do you want to change the name? (y/n): " userdatabasequestion
    case "$userdatabasequestion" in
        Y|y)
            read -rp "enter your preferred database name: " userdatabasename
            if [[ "$userdatabasename" =~ ^[a-z0-9]+$ ]]; then
                databasename="$userdatabasename"
                info "database name is set to ($databasename)"
                break
            else
                warning "invalid database name.." 
                warning "database name should not contain any symbols and capital alphabets, use (a-z & 0-9)"
            fi
            ;;
        N|n)
            databasename="resourcespace"
            info "database name set to default database name ($databasename)"
            break
            ;;
        *)
            echo "Invalid option please choose (y/n)"
            ;;
    esac
done
databaseuser=""
while :; do
    echo
    read -rp "default database user name will be (resourcespace_rw) do you want to change the name? (y/n): " userdatabaseusernamequestion
    case "$userdatabaseusernamequestion" in
        Y|y)
            read -rp "enter your preferred database user name: " userdatabaseusername
            if [[ "$userdatabaseusername" =~ ^[a-z]+$ ]]; then
                databaseuser="$userdatabaseusername"
                info "database username is set to ($databaseuser)"
                break
            else
                warning "invalid database username.."
                warning "database username should only contain (a-z)"
            fi
            ;;
        N|n)
            databaseuser="resourcespace_rw"
            info "database username set to default username ($databaseuser)"
            break
            ;;
        *)
            echo "Invalid option please choose (y/n)"
            ;;
    esac
done
databasepassword=""
echo
info "for securing database user, please enter the database user password"
while :; do
    read -rsp "enter your database password: " userdatabasepassword
    echo
    read -rsp "confirm your database password: " confirmdatabasepassword
    echo
    if [[ "${#confirmdatabasepassword}" -lt 8 ]]; then
        warning "password should be minimum 8 characters"
    else
        if [[ "$userdatabasepassword" != "$confirmdatabasepassword" ]]; then
            warning "password did not matched, please enter again.."
        else
            databasepassword="$confirmdatabasepassword"
            info "password is set successfully, please keep this password safely"
            info "password for the user is saved in (.env) file"
            echo "DB_PASSWORD=$confirmdatabasepassword" >> "$envfile"
            break
        fi
    fi
done
defaultversion="11.0"
downloadversion="$defaultversion"
while :; do
    echo
    read -rp "default resourcespace version is going to be downloaded is ($downloadversion). Do you want to change the download version? (y/n): " downloadquestion
    case "$downloadquestion" in
        Y|y)
            read -rp "Enter the version name like '11.0', '10.7' etc... : " userdownloadversion
            if [[ "$userdownloadversion" =~ ^[0-9]+\.[0-9]+ ]]; then
                highest="$(printf '%s\n' "$defaultversion" "$userdownloadversion" | sort -V | tail -n 1)"
                if [ "$highest" == "$downloadversion" ]; then
                    downloadversion="$userdownloadversion"
                    info "version downloaded will be ($userdownloadversion)"
                    break
                else
                    error "resourcespace download version cannot be higher than the latest version ($defaultversion)"
                fi
            else
                warning "invalid format. Please use format like '11.0' or '10.7'."
            fi
            ;;
        N|n)
            downloadversion="$defaultversion"
            info "default resourcespace downloaded version will be ($downloadversion)"
            break
            ;;
        *)
            echo "invalid option please choose (y/n)"
            ;;
    esac
done
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