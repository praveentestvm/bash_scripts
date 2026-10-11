#!/bin/bash
apacheconfig() {
    local web configfile defaultconfigfile
    web="apache2.service"
    configfile="/etc/apache2/sites-available/resourcespace.conf"
    configfilename="$(basename "$configfile")"
    defaultconfigfile="/etc/apache2/sites-available/000-default.conf"
    defaultconfigfilename="$(basename "$defaultconfigfile")"
    servicecheck "$web"
    if [ -f "$defaultconfigfile" ]; then
        info "config file '$defaultconfigfile' exist"
        if a2dissite "$defaultconfigfilename" >> "$logfile" 2>&1; then
            info "successfully disabled '$defaultconfigfilename' file"
        else
            error "failed to disable '$defaultconfigfilename' file, for details see ($logfile)"
            return 1
        fi
        if touch "$configfile"; then
            info "resourcespace config file '$configfile' created successfully"
            cat << APACHE > "$configfile"
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $webdirectory

    <Directory $webdirectory>
        AllowOverride All
        Require all granted
        Options -Indexes
    </Directory>

    <Directory $webdirectory/include>
        Require all denied
    </Directory>

    <DirectoryMatch "^/.*/\.svn/">
        Require all denied
    </DirectoryMatch>

    ErrorLog /var/log/apache2/resourcespace_error.log
    CustomLog /var/log/apache2/resourcespace_access.log combined
</VirtualHost>
APACHE
            if a2ensite "$configfilename" >> "$logfile" 2>&1; then
                info "site enabled successfully '$configfilename'"
            else
                error "failed to enable site '$configfilename' for details see ($logfile)"
                return 1
            fi
        else
            error "failed to create file '$configfile' for details see ($logfile)"
            return 1
        fi
    else
        error "did not find the file '$defaultconfigfile'"
        return 1
    fi
    if apache2ctl configtest >> "$logfile" 2>&1; then
        info "apache2 configuration is successfull"
    else
        error "apache2 configuration is failed for details see ($logfile)"
        return 1
    fi
    if systemctl restart "$web" >> "$logfile" 2>&1; then
        info "'$web' service restarted successfully"
    else
        error "'$web' service failed to restart"
        return 1
    fi
}