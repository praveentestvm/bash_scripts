#!/bin/bash
changeowner() {
    local directory
    directory="$1"
    info "changing user and group to 'www-data'"
    if chown -R 33:33 "$directory" >> "$logfile" 2>&1; then
        info "user and group of '$directory' changed to 'www-data'"
    else
        error "failed to change user and group of '$directory' to 'www-data' for details see ($logfile)"
        return 1
    fi
}
createwebdirectory() {
    webdirectory="/var/www/html/resourcespace"
    if [ -d "$webdirectory" ]; then
        info "directory '$webdirectory' already exists"
        return 0
    else
        info "could not find directory '$webdirectory' creating directory"
        if mkdir -p "$webdirectory" >> "$logfile" 2>&1; then
            info "directory '$webdirectory' created successfully"
        else
            error "failed to create directory '$webdirectory' for details see ($logfile)"
            return 1
        fi
    fi
}
createfilestoredirectory() {
    local filestoredirectory
    filestoredirectory="$webdirectory/filestore"
    if [ -d "$filestoredirectory" ]; then
        info "directory '$filestoredirectory' already exists"
        return 0
    else
        info "could not find directory'$filestoredirectory' creating directory"
        if mkdir -p "$filestoredirectory" >> "$logfile" 2>&1; then
            info "directory '$filestoredirectory' created successfully"
            changeowner "$filestoredirectory"
        else
            error "failed to create directory '$filestoredirectory' for details see ($logfile)"
            return 1
        fi
    fi
}
downloadresourcespace() {
    local url
    url="https://svn.resourcespace.com/svn/rs/releases/${downloadversion}"
    createwebdirectory
    if svn info "$webdirectory" >> "$logfile" 2>&1; then
        info "a valid svn repo found, for details check ($logfile)"
        return 0
    else
        if svn co "$url" "$webdirectory"; then
            info "resourcespace source code is downloaded successfully at '$webdirectory'"
            changeowner "$webdirectory"
            createfilestoredirectory
        else
            error "failed to download resourcespace source code at '$webdirectory' for details see ($logfile)"
            return 1
        fi
    fi
}