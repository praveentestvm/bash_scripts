#!/bin/bash
testnetwork() {
    if ping -c 3 -W 5 8.8.8.8 >/dev/null; then
        info "network testing is completed successfully and reachable to internet"
    else
        error "network testing is failed, unable to reach internet, please check your internet connectiong and retry installing again."
        return 1
    fi
}
requiredpackages=(
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
checkpackages() {
    local pkg
    pkg="$1"
    if ! dpkg -s "$pkg" >> "$logfile" 2>&1; then
        missingpackages+=("$pkg")
    fi
}
checkdependencies() {
    local package
    missingpackages=()
    info "checking for missing packages"
    for package in "${requiredpackages[@]}"; do
        checkpackages "$package"
    done
    if (( ${#missingpackages[@]} == 0 )); then
        info "all the required dependencies are already installed"
    else
        warning "found missing packages"
        printf " - %s\n" "${missingpackages[@]}"
    fi
}
installpackages() {
    if (( ${#missingpackages[@]} == 0 )); then
        return 0
    else
        if ! testnetwork; then
            return 1
        fi
        info "updating apt packages repo"
        if apt-get update -qq >> "$logfile" 2>&1; then
            info "packages repo updated successfully"
            info "installing missing packages"
            if apt-get install -y "${missingpackages[@]}"; then
                info "all the missing packages are installed successfully"
            else
                error "failed to install missing packages"
                return 1
            fi
        else
            error "failed to update packages repo"
            return 1
        fi
    fi
}