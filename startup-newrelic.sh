#!/bin/sh
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/var/www/html
PHP_EXT=/var/www/phpext

# Checking if newrelic variable is provided
if [ ! -z ${NEWRELICKEY+x} ]; 
then 
  if [ ! -z ${NEWRELICAPPNAME+x} ];
  then
    export NR_INSTALL_SILENT=true
    sed -i "s/newrelic.appname = .*/newrelic.appname = \"$NEWRELICAPPNAME\"/" /etc/php/7.1/fpm/conf.d/newrelic.ini
    sed -i "s/newrelic.license = .*/newrelic.license = \"$NEWRELICKEY\"/" /etc/php/7.1/fpm/conf.d/newrelic.ini
  fi
fi

set -e
chown -R www-data:www-data $DATA_DIR
/usr/bin/supervisord -n -c /etc/supervisord.conf
