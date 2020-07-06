#!/bin/sh
set -e

if [[ -d /tmp/config ]]; then
    echo "> Configure agendav"
    if [[ ! -d /var/www/agendav/web/config ]]; then
        mkdir /var/www/agendav/web/config
    fi
    mv /tmp/config/* /var/www/agendav/web/config/ || true
    chown -R apache:apache /var/www/agendav

    sed -i "s|app\['site.footer'\].*|app['site.footer'] = null;|" /var/www/agendav/web/config/settings.php
    sed -i "s|app\['site.logo'\].*|app['site.logo'] = null;|" /var/www/agendav/web/config/settings.php
    sed -i "s|app\['defaults.weekstart'\].*|app['defaults.weekstart'] = 1;|" /var/www/agendav/web/config/settings.php
    sed -i "s|app\['site.title'\].*|app['site.title'] = 'My Calendar';|" /var/www/agendav/web/config/settings.php

    sed -i "s|app\['defaults.timezone'\].*|app['defaults.timezone'] = '${TIMEZONE}';|" /var/www/agendav/web/config/settings.php
    sed -i "s|app\['caldav.baseurl'\].*|app['caldav.baseurl'] = '${DAV_URL}';|" /var/www/agendav/web/config/settings.php
    sed -i "s|app\['caldav.baseurl.public'\].*|app['caldav.baseurl.public'] = '${DAV_URL}';|" /var/www/agendav/web/config/settings.php
fi

echo "> Run agendav"
apachectl -DFOREGROUND
