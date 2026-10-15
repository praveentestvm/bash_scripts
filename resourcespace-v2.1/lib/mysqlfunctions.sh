#!/bin/bash
mysqlauthsocket() {
    if mysql -e "SELECT 1;" >/dev/null 2>&1; then
        info "connected to mysql using auth socket"
        mysql_cmd=(mysql)
    else
        error "failed to connect to mysql using auth socket, either root password is configured or service is not running. check and try again"
        return 1
    fi
}
mysqlroot() {
    read -rsp "enter your configured mysql root password for authentication: " rootpass
    echo
    if mysql -u root -p"$rootpass" -e "SELECT 1;" >/dev/null 2>&1; then
        info "connected to mysql using root password"
         mysql_cmd=(mysql -u root -p"$rootpass")
    else
        error "failed to authenticate with mysql using root password, please check your root password and retry again or service is not running"
        return 1
    fi
}
mysqlconfig() {
    local db dbname dbuser dbpass
    dbname="$1"
    dbuser="$2"
    dbpass="$3"
    if "${mysql_cmd[@]}" -e "SHOW DATABASES;" | grep -Fqx "$dbname"; then
        info "database '$dbname' already exists"
    else
        if "${mysql_cmd[@]}" -e "CREATE DATABASE IF NOT EXISTS ${dbname} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; then
            info "created database '$dbname' successfully"
        else
            error "failed to create database '$dbname'"
            return 1
        fi
    fi
    if "${mysql_cmd[@]}" -e "SELECT User FROM mysql.user WHERE User='${dbuser}' AND Host='localhost';" | grep -Fqx "$dbuser"; then
        info "user '$dbuser' already exists"
    else
        if "${mysql_cmd[@]}" -e "CREATE USER IF NOT EXISTS '${dbuser}'@'localhost' IDENTIFIED BY '${dbpass}';"; then
            info "user '$dbuser created successfully'"
            if "${mysql_cmd[@]}" -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'localhost';"; then
                info "privileges is updated to the user '$dbuser'"
            else
                error "failed to grant privileges to the user '$dbuser'"
                return 1
            fi
        else
            error "failed to created user '$dbuser'"
            return 1
        fi
    fi
}
