#!/bin/bash
__print() {
    local level message
    level="$1"
    shift
    message="$(printf "%s [%s]: %s\n" \
        "$(date "+%c")" \
        "$level" \
        "$*")"

    printf '%s\n' "$message"
    printf '%s\n' "$message" >> "$logfile"
}
info() {
    __print "INFO" "$@"
}
error() {
    __print "ERROR" "$@"
}
warning() {
    __print "WARNING" "$@"
}