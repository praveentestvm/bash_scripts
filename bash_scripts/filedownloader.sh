#!/bin/bash
# Just got an idea how to replace or remove if statements, this is an 
# experiement of removing the if statements
__print() {
    local level print_date
    print_date="$(date "+%c")"
    level="$1"
    shift
    printf "%s [%s]: %s\n" "$print_date" "$level" "$@"
}

success() {
    __print "OK" "$*"
}

error() {
    __print "ERROR" "$*"
}

dir() {
    local directory file jpg
    directory="$1"
    file="$2"
    jpg="$1/JPG"
    { mkdir -p "$directory" && success "'$directory' directory created successfully"; } || { error "'$directory' failed to created directory" && return 1; }
    { mkdir -p "$jpg" && success "'$jpg' sub-directory created successfully"; } || { error "'$jpg' failed to created sub-directory" && return 1; }
    { mv "$file" "$directory" && success "'$file' moved successfully to the directory '$directory'"; } || { error "'$file' failed to move to the directory '$directory'" && return 1; }
}

downloader() {
    local link file_name create_directory destination
    link="$1"
    file_name="$2"
    create_directory="$3"
    destination="$create_directory/$file_name"
    { [[ -f "$destination" ]] && success "file exists at the directory '$destination'"; } || {
    { curl -fsS "$link" -o "$file_name" && success "'$file_name' downloaded successfully" && dir "$create_directory" "$file_name"; } || { error "'$file_name' failed to download" && return 1; }
    }
}

main() {
    downloader "url here" "filename here" "directory name here"
}

main