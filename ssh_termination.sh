#!/bin/bash
#In my view this script is version 1.
#In future updates we automate everything.
#For now we will identify active sessions.
set -e
active_session=$(pgrep -af sshd | awk '/pts/')
user=$(who | awk '/pts/')
#Till here we have got the active session and users with ip's
#I have tested with multiple session, we are getting all the 
#session's PID's and User names with IP's, In future update
#I try to modify the script and make automate.
echo "$active_session"
echo
echo "$user"