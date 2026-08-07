#!/bin/bash
#Currently this installer is designed for ubuntu.
#We add other distro support on future update.
#Sorry if your's is not ubuntu.

set -e
APP_NAME="Resourcespace Installer"
APP_VERSION="1.0.0"
AUTHOR="Praveen"
LOG_FILE="$(pwd)/resourcespace-installer.log"

readonly APP_NAME
readonly APP_VERSION
readonly AUTHOR
readonly LOG_FILE

ACTION=""
ROOT_PASS="root@123"
DB_NAME="resourcespace"
DB_USER="resourcespace_rw"
DB_PASS="$(tr -cd 'a-z' </dev/urandom | head -c 10)"
RESOURCESPACE_VERSION="11.0"
WEB_DIR="/var/www/html/resourcespace"
FILESTORE_DIR="$WEB_DIR/filestore"
version(){
    cat << EOF
$APP_NAME
Version     : $APP_VERSION
Author      : $AUTHOR
EOF
}

usage() {
    cat << EOF
usage:
-i, --install           installs all the required packages and configures apache php mysql

-r, --uninstall         uninstall all the installed packages, and dependencies of the
                        resourcespace, and removes source code of the resourcespace, and
                        removes filestore, and database as well

-u, --upgrade           upgrades the current version to latest version


-h, --help              displays help page
-v, --version           gives version information

[Options]

--root-pass <root-password>     specify root password (default: $ROOT_PASS)
--db-name <database name>       specify database name (default: $DB_NAME)
--db-user <database username>   specify database username (default: $DB_USER)
--db-password <database user    specify database password
    password>                   this is random password changes each time
                                specify so you don't get into trouble (random: $DB_PASS)
    
--download-version <version     specify version (defautl: $RESOURCESPACE_VERSION)
    of resourcespace>
--web-dir <web directory>       specify web directory (defult: $WEB_DIR)
EOF
}

do_install() {

    root_check

    #Checking dependencies
    checking_dependencies

    #install packages
    install_packages

    #Downloading resourcespace
    download_resourcespace

    #Configuring php.ini file
    php_config

    #Configuring apache
    apache_config
    
    #Configuring mysql
    mysql_config
}

REQUIRED_PACKAGES=(
        imagemagick
        apache2
        mysql-server
        subversion
        inkscape
        ghostscript
        postfix
        libimage-exiftool-perl
        cron
        wget
        php
        php-dev
        php-gd
        php-mysql
        php-mbstring
        php-zip
        php-intl
        php-curl
        php-dom
        libapache2-mod-php
        ffmpeg
        poppler-utils
    )

check_package() {
    if ! dpkg -s "$1" >>"$LOG_FILE" 2>&1; then
        MISSING_PACKAGES+=("$1")
    fi
}
checking_dependencies() {
    local pkg
    #These packages or dependencies are required by resourcespace
    #First we check them, then we install what are the packages are
    #unavailable in the server
    
    MISSING_PACKAGES=()

    info "checking required packages.."
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        check_package "$pkg"
    done
    #we have to check are there any missing packages
    #if found we install them
    if (( ${#MISSING_PACKAGES[@]} ==0 )); then
        say "all required packages are installed.."
        return 0
    fi

    warning "missing packages found.."
    printf ' - %s\n' "${MISSING_PACKAGES[@]}"
}

install_packages() {
    (( "${#MISSING_PACKAGES[@]}" == 0 )) && return 0

    info "updating package index.."
    apt update -qq >> "$LOG_FILE" 2>&1
    info "installing missing packages"
    printf ' - %s\n' "${MISSING_PACKAGES[@]}"
    if apt install -y "${MISSING_PACKAGES[@]}"; then
        say "all the missing packages are installed successfully"
    else
        error "failed to install required packages.."
        return 1
    fi
}

download_resourcespace() {
    local url
    local revision

    url="https://svn.resourcespace.com/svn/rs/releases/${RESOURCESPACE_VERSION}"
    revision="$(svn info "$WEB_DIR" | grep "^Revision" | cut -d ' ' -f2)"

    create_web_dir || return 0

    if svn info "$WEB_DIR" >> "$LOG_FILE" 2>&1; then
        info "A valid svn repo found, current revision is ($revision)"
    else
        if svn co -q "$url" "$WEB_DIR" >> "$LOG_FILE" 2>&1; then
            info "resourcespace code is downloaded in the path '$WEB_DIR'"
            create_filestore_dir
        else
            error "failed to download Resourcespace code in the path '$WEB_DIR'"
            return 1
        fi
    fi
    change_owner
}

change_owner() {
    #apache user is www-data so accessing the managing filestore
    #we have to change the user group is option but we change both
    info "changing the owner and group to www-data"
    if chown -R www-data:www-data "$WEB_DIR" >> "$LOG_FILE"; then
        info "owner and group of the web directory is changed to www-data"
    else
        error "failed to change owner and group of the web directory to www-data"
        return 1
    fi
}

create_web_dir() {
    if [ ! -d "$WEB_DIR" ]; then
        mkdir -p "$WEB_DIR"
        say "directory $WEB_DIR is created successfully, downloading the required files"
    else
        error "failed to create directory $WEB_DIR"
        return 1
    fi
}

create_filestore_dir() {
    if [ ! -d "$FILESTORE_DIR" ]; then
        info "$FILESTORE_DIR not found"
        info "creating folder filestore"
        if mkdir -p "$FILESTORE_DIR"; then
            info "folder filestore is created at path $FILESTORE_DIR"
        else
            error "failed to created folder filestore at the path $FILESTORE_DIR"
            return 1
        fi
    else
        return 0
    fi
}
apache_config() {
    local web
    local apache_file


    web="apache2.service"
    apache_file="/etc/apache2/sites-available/resourcespace.conf"

    services "$web"
    if touch "$apache_file" >> "$LOG_FILE"; then
        info "apache configuration file is create at $apache_file"
    else
        error "failed to create apache configuration file at $apache_file"
        return 1
    fi
cat << EOF > "$apache_file"
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $WEB_DIR

    <Directory $WEB_DIR>
        AllowOverride All
        Require all granted
        Options -Indexes
    </Directory>

    <Directory $WEB_DIR/batch>
        Require all denied
    </Directory>

    <Directory $WEB_DIR/include>
        Require all denied
    </Directory>

    <Directory $WEB_DIR/upgrade>
        Require all denied
    </Directory>

    <Directory $WEB_DIR/languages>
        Require all denied
    </Directory>

    <Directory $WEB_DIR/tests>
        Require all denied
    </Directory>

    <DirectoryMatch "^/.*/\.svn/">
        Require all denied
    </DirectoryMatch>

    ErrorLog /var/log/apache2/resourcespace_error.log
    CustomLog /var/log/apache2/resourcespace_access.log combined
</VirtualHost>
EOF
    if a2ensite resourcespace.conf >> "$LOG_FILE"; then
        say "config file resourcespace.conf if enabled successfully"
        info "disabling & removing default file 000-default.conf"
        if [ -f /etc/apache2/sites-available/000-default.conf ]; then
            if a2dissite 000-default.conf >> "$LOG_FILE"; then
                say "default config file is disabled successfully"
                if rm /etc/apache2/sites-available/000-default.conf >> "$LOG_FILE"; then
                    say "default config file is removed successfully"
                else
                    error "failed to remove default config file"
                    return 1
                fi
            else
                error "failed to disable default config file"
                return 1
            fi
        fi
    else
        error "failed to enable resourcespace.conf config file"
        return 1
    fi
    
    if apache2ctl configtest >>"$LOG_FILE" 2>&1; then
        info "apache configurations is successfull"
    else
        error "apache configuration file as an error, for more details view $LOG_FILE"
        return 1
    fi

    if systemctl restart "$web" >> "$LOG_FILE" 2>&1; then
        say "'$web' service is restarted successfully"
    else
        error "failed to restart '$web' service"
    fi
}

mysql_config() {
    local db
    local mysql_cmd


    db="mysql.service"
    services "$db"

    if mysql -e "SELECT 1;" >/dev/null 2>&1; then
        info "connected to mysql using auth_socket"
        mysql_cmd=(mysql)
    else
        warning "mysql root requires a password"
        if mysql -u root -p"$ROOT_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
            say "successfully authenticated as mysql root"
            mysql_cmd=(mysql -u root -p"$ROOT_PASS")
        else
            error "failed to authenticate with mysql as root"
            return 1
        fi
    fi
    
    if "${mysql_cmd[@]}" -N -e \
    "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${DB_NAME}';" \
    | grep -qx "$DB_NAME" >>"$LOG_FILE"; then
        info "database '$DB_NAME' already exists"
    else
        info "database '$DB_NAME' does not exists"
    fi

    if "${mysql_cmd[@]}" -N -e \
    "SELECT User FROM mysql.user WHERE User='${DB_USER}' AND HOST='localhost';" \
    | grep -qx "$DB_USER" >>"$LOG_FILE"; then
        info "user '$DB_USER' already exists"
    else
        info "user '$DB_USER' does not exists"
        info "creating resourcespace database and user"

        if "${mysql_cmd[@]}" <<EOF >>"$LOG_FILE" 2>&1
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';

GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';

FLUSH PRIVILEGES;
EOF
        then
            say "database '$DB_NAME' created successfully"
            say "database user '$DB_USER' created successfully"
            say "databas user password is '$DB_PASS' you can leave it or you can change it later installation"
        else
            error "failed to configure mysql. check $LOG_FILE for details"
            return 1
        fi
    fi
    return 0
}

services() {
    local service
    service="$1"
    #any how most of the time service is enabled and started once installed
    #but for automation checkup should be a good process
    if ! systemctl is-enabled "$service" >> "$LOG_FILE"; then
        warning "service $service is not enabled, enabling now..."
        if systemctl enable "$service" >> "$LOG_FILE"; then
            say "service $service is enabled successfully..."
        else
            error "failed to enable service $service"
            return 1
        fi
    fi

    if ! systemctl is-active "$service" >> "$LOG_FILE"; then
        warning "service $service is not active, starting now"
        if systemctl start "$service" >> "$LOG_FILE"; then
            say "service $service is started successfully.."
        else
            error "failed to start service $service"
            return 1
        fi
    fi
}

php_config() {
    local php_file
    local php_version

    php_version="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"
    php_file="/etc/php/${php_version}/apache2/php.ini"

    if [ -f "$php_file" ]; then
        sed -i -e 's/memory_limit\s*=.*/memory_limit = 1G/g' "$php_file"
        sed -i -e 's/post_max_size\s*=.*/post_max_size = 200M/g' "$php_file"
        sed -i -e 's/upload_max_filesize\s*=.*/upload_max_filesize = 200M/g' "$php_file"
        sed -i -e 's/max_execution_time\s*=.*/max_execution_time = 300/g' "$php_file"
        info "configured '$php_file' and set the required values."
        info "want to modify... edit the file '$php_file'"
    else
        error "failed to configre '$php_file'"
        return 1
    fi
}

version_le() {
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n 1)" == "$1" ]]
}

version_ge() {
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n 1)" == "$1" ]]
}

version_check() {
    current_ver="$(awk -F'"' '/productversion/ {split($2, a, " "); print a[2]}' "${WEB_DIR}"/include/version.php)"
    latest_ver="$(svn ls https://svn.resourcespace.com/svn/rs/releases/ | cut -d '/' -f1 | sort -V | tail -n 1)"
    if [[ "$current_ver" == "$latest_ver" ]]; then
        info "resourcespace is already running on the latest version ($current_ver)"
        return 2
    fi

    if version_le "$current_ver" "9.8"; then
        warning "Versions below 10.0 are currently not supported by this installer."
        info "resourcespace database has changed pre v.10 we will support for the same soon"
        return 1
    fi

    if version_ge "$current_ver" "10.0"; then
        info "your current version $current_ver can be upgraded to $latest_ver"
        return 0
    fi
}

svn_diff() {
    if [ ! -d "$WEB_DIR/.svn" ]; then
        warning "$WEB_DIR is not an svn working copy"
        return 1
    fi

    [[ ! -f "$WEB_DIR/diff.txt" ]]; {
        touch "$WEB_DIR/diff.txt"
    }

    svn diff > "$WEB_DIR/diff.txt" >>"$LOG_DIR" 2>&1
    if [[ -s "$WEB_DIR/diff.txt" ]] >>"$LOG_FILE" 2>&1; then
        info "local modifications have been saved at $WEB_DIR/diff.txt"
    else
        rm -f "$WEB_DIR/diff.txt"
        info "no local modifications detected"
    fi
}

svn_upgrade() {
    svn cleanup >>"$LOG_FILE" 2>&1 || {
        error "failed to clean svn working copy"
        return 1
    }
    
    if svn switch "^/releases/${latest_ver}" >>"$LOG_FILE" 2>&1; then
        say "your current version $current_ver is successfully upgraded to $latest_ver"
    else
        warning "failed to upgrade your current version $current_ver to $latest_ver"
        info "for more details check $LOG_FILE"
        return 1
    fi
}

do_upgrade() {

    if [ "$(pwd)" != "$WEB_DIR" ]; then
        cd "$WEB_DIR" || return 1
    fi

    #before upgrading we check current installed version
    #if the current installed version is below 10.0 we exit
    #the script as database tables and schema was changed
    #after v.10.0 so we only upgrade versions are above 10.0
    version_check
    case "$?" in
        0) ;;
        1) return 1 ;;
        2) return 0 ;;
    esac

    #after version check, we check any local code changes
    #if any code is changed locally we save this into a file
    #so they cannot loose the code changed locally after 
    #svn switch
    svn_diff || return 1

    #the actual upgrade happens now, from the current installed
    #version to the latest or user specific version
    svn_upgrade || return 1
}

uninstall_packages() {
    local package

    for package in "${REQUIRED_PACKAGES[@]}"; do
        if apt --purge autoremove -y "$package" >>"$LOG_FILE" 2>&1; then
            info "$package package is uninstalled successfully"
        else
            error "failed to uninstall package $package"
            continue 1
        fi
    done

    apt autopurge -y >>"$LOG_FILE" 2>&1
    apt autoremove -y >>"$LOG_FILE" 2>&1
    apt autoclean -y >>"$LOG_FILE" 2>&1
}

DIRECTORIES=(
    "$WEB_DIR"
    /var/log/mysql/
)
check_directory_leftovers() {
    if [[ -d "$1" ]]; then
        info "found a leftover directory $1"
        return 0
    fi
    return 1
}

remove_leftovers() {
    local dir

    for dir in "${DIRECTORIES[@]}"; do
        if check_directory_leftovers "$dir"; then
            rm -rf -- "$dir"
            info "removed directory $dir"
        else
            error "failed to delete directory $dir"
            return 1
       fi
    done
}

do_uninstall() {
    #uninstlling all the installed packages
    uninstall_packages

    #removing all the leftovers
    remove_leftovers
}

SCRIPT_HOSTNAME="$(hostname)"
#SERVER_IP="$(hostname -I | awk '{print $1}')"

__print() {
    local level="$1"
    shift

    local message
    message=$(printf "%s %s [%s]: %s\n" \
    "$(date +%c)" \
    "$SCRIPT_HOSTNAME" \
    "$level" \
    "$*")

    printf "%s\n" "$message"
    printf "%s\n" "$message" >> "$LOG_FILE"
}

error() {
    __print ERROR "$@"
}

info() {
    __print INFO "$@"
}

say() {
    __print SUCCESS "$@"
}

warning() {
    __print WARNING "$@"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

need_cmd() {
    if ! check_command "$1"; then
        warning "need '$1' (command not found)"
    fi
}

scriptname="$(basename "$0")"
if [[ "$#" = 0 ]]; then
    echo "usage $scriptname --options"
    echo
    echo "for details use $scriptname [-h|--help]"
    exit 1
fi

root_check() {
    if [ "$(id -u)" != 0 ]; then
        error "this script must be run by root or use sudo or 'sudo -i'"
    exit 1
    fi
}

#Check if running on linux
if [ "$(uname -s | tr '[:upper:]' '[:lower:]')" != "linux" ]; then
    error "currently we have support only for linux"
    exit 1
fi
#Check if running on ubuntu
if [[ -f /etc/os-release ]]; then
    . /etc/os-release

    if [ "$ID" != "ubuntu" ]; then
        error "sorry currently we support only for ubuntu.."
        exit 1
    fi
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--install)
            ACTION="install"
            shift 1
            ;;
        -r|--uninstall)
            ACTION="uninstall"
            shift 1
            ;;
        -u|--upgrade)
            ACTION="upgrade"
            shift 1
            ;;
        -v|--version)
            version
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --web-dir)
            WEB_DIR="$2"
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--web-dir requires a value"
                    exit 1
                }
            shift 2
            ;;
        --download-version)
            RESOURCESPACE_VERSION="$2"
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--download-verion requires a value"
                    exit 1
                }
            shift 2
            ;;
        --root-password)
            ROOT_PASS="$2"
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--root-password requires a value"
                    exit 1
                }
            shift 2
            ;;
        --db-name)
            DB_NAME="$2"
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--db-name requries a value"
                    exit 1
                }
            shift 2
            ;;
        --db-user)
            DB_USER="$2"
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--db-user requires a value"
                    exit 1
                }
            shift 2
            ;;
        --db-password)
            DB_PASS="$2"
                [[ -n "$2" && "$2" != -* ]] || {
                    error "--db-password requires a value"
                    exit 1  
                }
            shift 2
            ;;
        *)
            echo "Invalid option, Please choose correct one"
            exit 1
            ;;
    esac
done
    
case "$ACTION" in
    install)
        do_install
        ;;
    upgrade)
        do_upgrade
        ;;
    uninstall)
        do_uninstall
        ;;
    *)
        echo "Invalid option Please choose the correct one"
        exit 1
        ;;
esac
