#!/bin/bash
#In my view this script is version 1.1
#In future updates we automate everything.
#For now we will identify active sessions.
set -e
#Checking if ssh.service is installed.
if systemctl list-unit-files --type=service | grep -q ssh.service; then
    echo "ssh.service installed"
    echo
else
    echo "ssh.service is not installed"
    echo
    exit 1
fi
#Checking if ssh.service is active or running
if systemctl is-active --quiet ssh.service; then
    echo "ssh.service is active"
    echo
else
    echo "ssh.service is inactive"
    echo
    exit 1
fi
#Checking session of ssh
active_session=$(pgrep -af sshd | awk '/pts/')
user=$(who | awk '/pts/')
#Till here we have got the active session and users with ip's
#I have tested with multiple session, we are getting all the 
#session's PID's and User names with IP's, In future update
#I try to modify the script and make automate.

