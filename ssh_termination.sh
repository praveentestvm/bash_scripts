#!/bin/bash
#version 2.2.1
set -e
#Checking if ssh.service is installed.
if ! systemctl list-unit-files --type=service | grep -q ssh.service; then
    echo "ssh.service is not installed"
    echo
    exit 1
fi
#Checking if ssh.service is active or running
if ! systemctl is-active --quiet ssh.service; then
    echo "ssh.service is inactive"
    echo
    exit 1
fi
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
                        echo "$KPID is terminated successfully"
                    else
                        echo "$KPID is unable to terminate please try again"
                    fi
                ;;
            n|N)
                echo "You have selected (n) quitting"
                break
                ;;
            *)
                echo "Invalid option please select (y/n)"
                ;;
        esac
    done
fi 