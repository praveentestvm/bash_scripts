#!/bin/bash
#version 2.0
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
    check "Before creating the user please check. Does user exist?"
    read -rp "Enter the username for checking does user exist already: " _username
        if user_check "$_username"; then
            info "user $_username exist, so not creating the user"
        else
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
        fi
    return 0
}

delete_user() {
    banner "DELETE USER"
    printf "\n"
    check "Before deleting the user please check. Does user exist"
    read -rp "Enter the username of the user you want to delete: " _delete_user
    if user_check "$_delete_user"; then
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
                exit 0
                ;;
            *) invalid ;;
        esac
    fi
}

lock_user() {
    banner "LOCK USER"
    printf "\n"
    check "Before locking the user please check. Does user exist"
    read -rp "Enter the username of the user you want to lock: " _lockuser
    if user_check "$_lockuser"; then
        read -rp "Do you want to continue locking the user $_lockuser (y/n): " _lock
        case "$_lock" in
            y|Y)
                warning "Locking the user $_lockuser"
                printf "\n"
                if passwd -l "$_lockuser" >/dev/null 2>&1; then
                    success "user $_lockuser locked successfully.."
                else
                    error "unable to lock the user $_lockuser. Please try again"
                    return 1
                fi
                ;;
            n|N)
                printf "You have selected (n) exiting...\n"
                exit 0
                ;;
            *) invalid ;;
        esac
    fi
}

unlock_user() {
    banner "UNLOCK USER"
    printf "\n"
    check "Before unlocking the user please check. Does user is locked.."
    read -rp "Enter the username of the user you want to unlock: " _unlockuser
    if passwd -S -a | awk '$2=="L" {print $1}' | grep -q "$_unlockuser"; then
        warning "$_unlockuser is a locked user"
        read -rp "Do you want to unlock (y/n): " _unlock
        case "$_unlock" in
            y|Y)
                if passwd -u "$_unlockuser" >/dev/null 2>&1; then
                    success "user $_unlockuser is unlocked successfully, you can login now"
                else
                    error "user $_unlockuser is unabled to unlock, please try again"
                    return 1
                fi
                ;;
            n|N)
                printf "You have selected (n) exiting...\n"
                exit 0
                ;;
            *) invalid ;;
        esac
    else
        info "$_unlockuser is not a locked user. exiting ..."
        return 0
    fi
}

reset_password() {
    banner "RESET PASSWORD"
    printf "\n"
    check "Before changing the user password please check. Does user exist?"
    read -rp "Enter the username for checking does user exist already: " _resetusername
        if user_check "$_resetusername"; then
            info "user $_resetusername exist, to reset the password plese follow the next steps"
            read -rp "Enter the username of user for resetting the password: " _resetuser
            read -rp "Enter your desired new password for the user: " _resetpassword
            if echo "$_resetuser:$_resetpassword" | chpasswd 2>/dev/null; then
                success "User $_resetuser password is changed successfully.. and the password is $_resetpassword"
            else
                error "Unable to chage user $_resetuser password. Please try again"
                return 1
            fi
        else
            info "User does not exist"
            return 1
        fi
}

user_information() {
    banner "USER INFORMATION"
    printf "\n"
    read -rp "Enter the username of the user you want to check the details: " _userinfo
    local _userid
    
    _userid=$(id "$_userinfo")

    printf "%-20s %-15s %15s\n" "UID" "GID" "GROUPS"
    paste -d ' '\
        <(printf '%s\n' "$_userid") 
}

list_logged_in_users() {
    banner "LIST LOGGED IN USERS"
    printf "\n"
    local _logged_user

    _logged_user=$(who | awk '{print $1, $2, $4}')
    printf "%-7s %-7    s %-5s\n" "USER" "TTY" "TIME" 
    paste -d ' '\
        <(printf '%s\n' "$_logged_user")
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

    if id "$_username" >/dev/null 2>&1; then
        return 0
    else
        info "user $_username does not exist."
        return 1
    fi
}

root() {
    if [[ "$(id -u)" != 0 ]]; then
        error "You must be root or use sudo to run the scipt"
        exit 1
    fi
}

root

main