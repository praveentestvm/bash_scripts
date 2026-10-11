#!/bin/bash
phpconfig() {
    local php_file php_version
    php_version="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"
    php_file="/etc/php/${php_version}/apache2/php.ini"
    if [ -f "$php_file" ]; then
        sed -i -e 's/memory_limit\s*=.*/memory_limit = 1G/g' "$php_file"
        sed -i -e 's/post_max_size\s*=.*/post_max_size = 200M/g' "$php_file"
        sed -i -e 's/upload_max_filesize\s*=.*/upload_max_filesize = 200M/g' "$php_file"
        sed -i -e 's/max_execution_time\s*=.*/max_execution_time = 300/g' "$php_file"
        info "configured '$php_file' and updated required limits"
        info "for futher modifications as per you requirement change file '$php_file'"
    else
        error "failed to configure '$php_file' or file not exist"
    fi
}