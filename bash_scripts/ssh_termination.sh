#!/bin/bash
#version 2.3.2
set -e

main() {
    ssh.service_check
    #Checking session of ssh
    active_session=$(pgrep -af sshd | awk '/pts/ {print $1, $3}')
    user=$(who | awk '/pts/ {print $5}')
    session=$(pgrep -a sshd | awk '/pts/' | wc -l)
    #Till here we have got the active session and users with ip's
    #I have tested with multiple session, we are getting all the 
    #session's PID's and User names with IP's.
    if [[ "$session" -gt 0 ]]; then
        while true; do
            printf "%-6s %-20s %-15s\n" "PID" "USER" "IP"
            paste -d ' '\
                <(printf '%s\n' "$active_session") \
                <(printf '%s\n' "$user")
            read -rp "Do you want to close the session (y/n): " SESSION
            case "$SESSION" in
                y|Y)
                    read -rp "Enter the PID of the session you want to kill: " KPID
                        if kill "$KPID" >/dev/null 2>&1; then
                            success "$KPID is terminated successfully"
                        else
                            error "$KPID is unable to terminate please try again"
                        fi
                    ;;
                n|N)
                    info "You have selected (n) quitting"
                    break
                    ;;
                *)
                    invalid
                    ;;
            esac
        done
    fi
}

ssh.service_check() {
    #Checking if ssh.service is installed.
    if ! systemctl status ssh.service >/dev/null 2>&1; then
        error "ssh.service is not installed"
        echo
        exit 1
    fi
    #Checking if ssh.service is active or running
    if ! systemctl is-active --quiet ssh.service; then
        error "ssh.service is inactive"
        echo
        exit 1
    fi
}

__print() {
    local state="$1"
    shift
    printf "[%s] %s\n" "$state" "$*"
}

error() {
    __print ERROR "$@"
}

success() {
    __print SUCCESS "$@"
}

info() {
    __print INFO "$@"
}

invalid() {
    printf "%s\n" "Invalid Option Please select (y/n)"
}

main