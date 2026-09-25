#!/bin/bash
#Currently this installer is designed for ubuntu.
#We add other distro support on future update.
#Sorry if your's is not ubuntu.

set -e
APP_NAME="Resourcespace Installer"
APP_VERSION="1.1.0"
AUTHOR="Praveen"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/resourcespace-installer.log"

readonly APP_NAME
readonly APP_VERSION
readonly AUTHOR
readonly LOG_FILE

ACTION=""
DB_NAME="resourcespace"
DB_USER="resourcespace_rw"
DB_PASS="$(tr -cd 'a-z' </dev/urandom | head -c 10)"
RESOURCESPACE_VERSION="11.0"
WEB_DIR="/var/www/html/resourcespace"
FILESTORE_DIR="$WEB_DIR/filestore"
ENV="$SCRIPT_DIR/.env"

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
-h, --help              displays help page
-v, --version           gives version information

[Options]

--db-name <database name>       specify database name (default: $DB_NAME)
--db-user <database username>   specify database username (default: $DB_USER)
--db-password <database user    specify database password
    password>                   this is random password changes each time
                                specify so you don't get into trouble (for password check .env)
    
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
    if mysql_config; then
        touch "$ENV"
        echo "MYSQL USER PASSWORD = $DB_PASS" > "$ENV"
    fi
}

REQUIRED_PACKAGES=(
        imagemagick
        apache2
        mysql-server
        subversion
        inkscape
        ghostscript
        #postfix (for those who want to setup smtp server, you can uncomment and delete this entire line leaving 'postfix')
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

    url="https://svn.resourcespace.com/svn/rs/releases/${RESOURCESPACE_VERSION}"
    create_web_dir

    if svn co -q "$url" "$WEB_DIR" >> "$LOG_FILE" 2>&1; then
        info "resourcespace code is downloaded in the path '$WEB_DIR'"
        create_filestore_dir
    else
        error "failed to download Resourcespace code in the path '$WEB_DIR'"
        return 1
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
        if mkdir -p "$WEB_DIR"; then
            say "directory $WEB_DIR is created successfully, downloading the required files"
        else
            error "failed to create directory '$WEB_DIR'"
            return 1
        fi
    else
        info "'$WEB_DIR' already exists"
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

    <Directory $WEB_DIR/include>
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
        say "config file 'resourcespace.conf' is enabled successfully"
        info "disabling & removing default file 000-default.conf"
        if [ -f /etc/apache2/sites-available/000-default.conf ]; then
            if a2dissite 000-default.conf >> "$LOG_FILE"; then
                say "default config file is disabled successfully"
            else
                error "failed to disable default config file"
                return 1
            fi
        fi
    else
        error "failed to enable 'resourcespace.conf' config file"
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
        return 1
    fi
}

mysql_config() {
    local db mysql_cmd timer
    timer=5

    db="mysql.service"
    services "$db"

    if mysql -e "SELECT 1;" >/dev/null 2>&1; then
        info "connected to mysql using auth_socket"
        mysql_cmd=(mysql)
    else
        while true; do
            warning "mysql root requires a password, please enter root password to continue in $timer sec..."
            sleep "$timer"
            if mysql -u root -p -e "SELECT 1;" >/dev/null 2>&1; then
                say "successfully authenticated as mysql root"
                mysql_cmd=(mysql -u root -p)
                break
            else
                error "failed to authenticate with mysql as root exiting script"
                return 1
            fi
        done
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
            say "check '.env' file for database user password"
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

validate_value() {
    local value option
    option="$1"
    value="$2"
    [[ -n "$value" && "$value" != -* ]] || {
        error "$option requires value"
        exit 1
    }
    
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
        -v|--version)
            version
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --web-dir)
            validate_value "--web-dir" "$2"
            WEB_DIR="$2"
            FILESTORE_DIR="$WEB_DIR/filestore"
            shift 2
            ;;
        --download-version)
            validate_value "--download-version" "$2"
            RESOURCESPACE_VERSION="$2"
            shift 2
            ;;
        --db-name)
            validate_value "--db-name" "$2"
            DB_NAME="$2"
            shift 2
            ;;
        --db-user)
            validate_value "--db-user" "$2"
            DB_USER="$2"
            shift 2
            ;;
        --db-password)
            validate_value "--db-password" "$2"
            DB_PASS="$2"
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
    *)
        echo "Invalid option"
        ;;
esac