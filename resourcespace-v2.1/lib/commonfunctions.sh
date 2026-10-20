#!/bin/bash
servicecheck(){
    local service
    service="$1"
    if ! systemctl is-enabled "$service" >> "$logfile" 2>&1; then
        warning "service '$service' is not enabled."
        if systemctl enable --now "$service" >> "$logfile" 2>&1; then
            info "service '$service' is enabled successfully"
        else
            error "failed to enable service '$service', for details see '$logfile'"
            return 1
        fi
    else
        info "service '$service' is already enabled"
    fi
    if ! systemctl is-active "$service" >> "$logfile" 2>&1; then
        warning "service '$service' is not active"
        if systemctl start "$service" >> "$logfile" 2>&1; then
            info "service '$service' started successfully"
        else
            error "failed to start '$service', for details see '$logfile'"
            return 1
        fi
    else
        info "service '$service' is already active"
    fi
}
mainmenu(){
    cat << MENU
##################################################################
#                RESOURCESPACE INSTALLER WIZARD                  #
#                          v2.1                                  #
##################################################################

Author    : Praveen
Copyright : © 2026
License   : GNU General Public License (GPL)
            Free to modify, reuse, and resell.

This installer will automatically:
  * Install and configure Apache, MySQL, and PHP dependencies
  * Set up your MySQL database and privileged user securely
  * Download and deploy your specified ResourceSpace version

You will be guided through a few quick configuration prompts
(database name, username, password, and web directory).
────────────────────────────────────────────────────────────────

MENU
}
usage(){
    cat << USAGE
Resourcespace Installer 2.1

Usage: $scriptname [OPTIONS]

Options:
    -h, --help
            Print help
    --db-name
            specify database name
    --db-user
            specify database username
    --db-password
            specify database password
            specified password will be saved in $envfile
    --download-version
            specify download version
            default version downloaded will be the 
            latest version available at the time of
            running this scirpt else specify exactly how
            resourcespace expects like (10.0, 10.1, 10.7, 11.0)
USAGE
}