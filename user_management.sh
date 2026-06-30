#!/bin/bash
#version 1.0
main() {
    while true; do
    banner "USER MANAGEMENT"
    menu c "CREATE USER"
    menu d "DELETE USER"
    menu l "LOCK USER"
    menu u "UNLOCK USER"
    menu r "RESET PASSWORD"
    menu i "USER INFORMATION"
    menu o "LIST LOGGED IN USERS"
    menu q "EXIT"
    read -rp "Please Enter you option: " user
        case "$user" in
            c|C) create_user ;;
            d|D) delete_user ;;
            l|L) lock_user ;;
            u|U) unlock_user ;;
            r|R) reset_password ;;
            i|I) user_information ;;
            o|O) list_logged_in_users ;;
            q|Q) quit ;;
            *) invalid ;;
        esac
    done
}

create_user() {
    banner "CREATE USER"
    printf "\n"
    check "If your exist"
    read -rp "Enter the username for checking does user exist already: " _username
        user_check "$_username" #we are checking the username, if already exist
        printf "\n"
        info "User does not exist creating user, please follow the next steps"
        read -rp "Enter the username of user: " _user
        read -rp "Enter you Desired Password for the user: " _password
        #Adding the user and giving the user /bin/bash shell
        #We are assigning the password at the same time
        if useradd -m -s /bin/bash "$_user" 2>/dev/null && echo "$_user:$_password" | chpasswd 2>/dev/null; then
            success "User $_user is created successfully.. and the password is $_password"
        else
            error "Unable to create user $_user. Please try again"
            return 1
        fi
    return 0
}

delete_user() {
    banner "DELETE USER"
    printf "\n"
    check "Before deleting the user please check. does user exist"
    read -rp "Enter the username of the user you want to delete: " _delete_user
    if ! user_check "$_delete_user"; then
    info "user $_delete_user exist"
    read -rp "Do you want to continue deleting user $_delete_user (y/n) " _delete
        case "$_delete" in
            y|Y)
                warning "Deleting user $_delete_user"
                printf "\n"
                #Here we have used userdel -r which is for removing home directory as well
                if userdel -r "$_delete_user" >/dev/null 2>&1; then
                    success "user $_delete_user deleted successfully"
                else
                    error "Unable to delete user $_delete_user. Please try again"
                    return 1
                fi
                ;;
            n|N)
                printf "You have select (n) exiting...\n"
                ;;
            *) invalid ;;
        esac
    fi
}

banner(){
    printf "#########################\n"
    printf "#%-23s #\n" "$1"
    printf "#########################\n"
}

menu() {
    local menu="$1"
    shift
    printf "(%s) %s\n" "$menu" "$*"
}

__print() {
    local test="$1"
    shift
    printf "[%s] %s\n" "$test" "$*"
}

error() {
    __print ERROR "$@"
}

warning() {
    __print WARNING "$@"
}

success() {
    __print SUCCESS "$@"
}

info() {
    __print INFO "$@"
}

check() {
    __print CHECKING "$@"
}
quit() {
    info "Exiting the Script"
    exit 0
}

invalid() {
    printf "Invalid option Please try again..\n"
}

user_check() {
    local _username
    _username="$1"

    if ! grep -q "^$_username:" /etc/passwd | cut -d ':' -f1; then
        info "username $_username does not exist.."
    fi
    return 1
}

root() {
    if [[ "$(id -u)" != 0 ]]; then
        error "You must be root or use sudo to run the scipt"
        exit 1
    fi
}

root

main
