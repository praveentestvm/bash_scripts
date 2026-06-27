#!/bin/bash
#version 1.2.1
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
user=$(who | awk '/pts/ {print $2, $5}')
pts_session_who=$(who | awk '/pts/ {print $2}' | cut -d '/' -f2)
pgrep_pts=$(pgrep -af sshd | awk '/pts/ {print $3}' | cut -d '/' -f2)

#Till here we have got the active session and users with ip's
#I have tested with multiple session, we are getting all the 
#session's PID's and User names with IP's, In future update
#I try to modify the script and make automate.
echo "$active_session"
echo
echo "$user"

read -rp "Enter the PID of the session you want to kill: " KPID

if kill "$KPID"; then
    echo "$KPID is terminated successfully"
else
    echo "$KPID is unable to terminate please try again"
fi  