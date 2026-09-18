#!/bin/bash
#This is one of my real project where i have to download n number of pdf's
#and move them to their respective folder and split them into jpg
#for every pdf there will be uniqe link i have to download for now i managed
#to build this, i try to automate totally.

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

    if mkdir -p "$directory"; then
        success "'$directory' directory created successfully"
        if mkdir -p "$jpg"; then
            success "'$jpg' sub-directory created successfully"
        else
            error "'$jpg' failed to created sub-directory"
        fi
    else
        error "'$directory' failed to created directory"
        return 1
    fi

    if mv "$file" "$directory"; then
        success "'$file' moved successfully to the directory '$directory'"
    else
        error "'$file' failed to move to the directory '$directory'"
        return 1
    fi
}

downloader() {
    local link file_name create_directory
    link="$1"
    file_name="$2"
    create_directory="$3"

    if curl -fsS "$link" -o "$file_name"; then
        success "'$file_name' downloaded successfully"
        dir "$create_directory" "$file_name"
    else
        error "'$file_name' failed to download"
        return 1
    fi 
}

main() {
    downloader "#url here" "#file name here" "#folder name here"
}

main

