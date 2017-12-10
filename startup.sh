#!/bin/sh
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/var/www/html
PHP_EXT=/var/www/phpext

set -e
chown -R www-data:www-data $DATA_DIR
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
